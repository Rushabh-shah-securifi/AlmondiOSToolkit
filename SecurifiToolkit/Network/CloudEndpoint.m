//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "CloudEndpoint.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "Commandparser.h"
#import "NotificationListResponse.h"
#import "NotificationCountResponse.h"
#import "NotificationClearCountResponse.h"
#import "Network.h"
#import "ConnectionStatus.h"
#import "AlmondModeChangeRequest.h"

typedef NS_ENUM(unsigned int, CloudEndpointSocketError) {
    CloudEndpointSocketError_notConnectedState          = 200,
    CloudEndpointSocketError_unsupportedCommand         = 201,
    CloudEndpointSocketError_outputStreamNil            = 202,
    CloudEndpointSocketError_outputStreamWriteFailure   = 203,
};

#define COMMAND_HEADER_LEN_BYTES 8

@interface CloudEndpoint () <NSStreamDelegate>
@property(nonatomic, readonly) NSObject *syncLocker;
@property(nonatomic, readonly) NetworkConfig *networkConfig;

@property(nonatomic) SecCertificateRef certificate;
@property(nonatomic) BOOL certificateTrusted;

@property(nonatomic, readonly) NSMutableData *partialData;
@property(nonatomic) BOOL networkUpNoticePosted;

@property(nonatomic, readonly) dispatch_queue_t backgroundQueue;        // queue on which the streams are managed
@property(nonatomic) NSInputStream *inputStream;
@property(nonatomic) NSOutputStream *outputStream;

@end


@implementation CloudEndpoint

+ (instancetype)endpointWithConfig:(NetworkConfig *)config {
    return [[self alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(NetworkConfig *)config {
    self = [super init];
    if (self) {
        _networkConfig = config;
        _syncLocker = [NSObject new];
        _backgroundQueue = dispatch_queue_create("socket_queue", DISPATCH_QUEUE_CONCURRENT);
        
        _partialData = [NSMutableData new];
    }
    
    return self;
}

- (void)dealloc {
    if (_certificate) {
        CFRelease(_certificate);
        _certificate = nil;
    }
}

#pragma mark - NetworkEndpoint protocol methods

- (void)connect {
    NSLog(@"Initialzing CloudEndpoint communication");
    __strong CloudEndpoint *block_self = self;
    
    dispatch_async(self.backgroundQueue, ^(void) {
        if (block_self.inputStream == nil && block_self.outputStream == nil) {
            [block_self.delegate networkEndpointWillStartConnecting:block_self];
            
            NetworkConfig *configurator = self.networkConfig;
            
            // Load certificate
            //
            if (configurator.enableCertificateValidation) {
                DLog(@"Loading certificate");
                [block_self loadCertificate];
            }
            
            CFReadStreamRef readStream;
            CFWriteStreamRef writeStream;
            
            NSString *server = configurator.host;
            CFStringRef host = (__bridge CFStringRef) server;
            UInt32 port = (UInt32) configurator.port;
            CFStreamCreatePairWithSocketToHost(NULL, host, port, &readStream, &writeStream);
            
            block_self.inputStream = (__bridge_transfer NSInputStream *) readStream;
            block_self.outputStream = (__bridge_transfer NSOutputStream *) writeStream;
            
            block_self.inputStream.delegate = block_self;
            block_self.outputStream.delegate = block_self;
            
            [block_self.inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
            [block_self.outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
            
            NSNumber *enableChainValidation = configurator.enableCertificateChainValidation ? @YES : @NO;
            NSDictionary *settings = @{
                                       (__bridge id) kCFStreamSSLValidatesCertificateChain : enableChainValidation
                                       };
            
            CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef) settings);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef) settings);
            
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            
            DLog(@"Scheduling in run loop");
            
            [block_self.inputStream scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
            [block_self.outputStream scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
            
            DLog(@"Opening streams");
            
            [block_self.inputStream open];
            [block_self.outputStream open];
            
            DLog(@"Streams open and entering run loop");
            
            [block_self.delegate networkEndpointDidConnect:block_self];
            
            while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
            }
            
            [block_self.inputStream removeFromRunLoop:runLoop forMode:NSDefaultRunLoopMode];
            [block_self.outputStream removeFromRunLoop:runLoop forMode:NSDefaultRunLoopMode];
        }
        else {
            NSLog(@"Stream already opened");
        }
        
        DLog(@"Streams exited run loop");
        [block_self.delegate networkEndpointDidDisconnect:block_self];
    });
}
-(void) shutdownAndCallDelegate {
    [self.delegate networkEndpointDidDisconnect:self];
    [self shutdown];
}
- (void)shutdown {
    NSLog(@" Who is setting status CloudEndpoint - shutdown");
//    [self.delegate networkEndpointDidDisconnect:self];
    // Take weak reference to prevent retain cycles
    __strong CloudEndpoint *block_self = self;
    dispatch_async(self.backgroundQueue, ^(void) {
        NSLog(@"[%@] CloudEndpoint is shutting down", block_self.debugDescription);
        NSLog(@"before time interval");
        //[NSThread sleepForTimeInterval:3.0f];
        NSLog(@"after time interval");
        
        NSLog(@"disconnecting from cloud network");
        
        @synchronized (self.syncLocker) {
            NSInputStream *in_stream = block_self.inputStream;
            NSOutputStream *out_stream = block_self.outputStream;
            
            NSRunLoop *loop = [NSRunLoop currentRunLoop];
            
            if (out_stream != nil) {
                out_stream.delegate = nil;
                [out_stream close];
                [out_stream removeFromRunLoop:loop forMode:NSDefaultRunLoopMode];
                block_self.outputStream = nil;
            }
            
            if (in_stream != nil) {
                in_stream.delegate = nil;
                [in_stream close];
                [in_stream removeFromRunLoop:loop forMode:NSDefaultRunLoopMode];
                block_self.inputStream = nil;
            }
        }
        NSLog(@"disconnected from cloud network this %@",self.delegate);
        
        
    });
    
}

#pragma mark - state


#pragma mark - NSStreamDelegate methods

// for legacy JSON command responses;
// returns YES if the payload will be wrapped in <root></root>
- (BOOL)isWrappedJson:(CommandType)commandType {
    switch (commandType) {
        case CommandType_NOTIFICATIONS_SYNC_RESPONSE:
        case CommandType_NOTIFICATIONS_COUNT_RESPONSE:
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE:
        case CommandType_DEVICELOG_RESPONSE:
            return YES;
        default:
            return NO;
    }
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    /*
     sinclair 24 Mar 2015
     some notes from 'reverse engineering' the wire format...
     1. stream is continuous one of command responses.
     2. the cloud sends some data in chunks that will be delivered to this handler over multiple calls.
     3. we cumulate all bytes/chunks looking for the structures of a single command response and isolate that run
     4. a command response data stream is delimited into a [payload length][command type]<root>[payload]</root> segments
     5. <root> and </root> are literal values and serve as a common "envelope" wrapping either XML or JSON payloads
     6. payload length segment is stored in the first 4 bytes
     7. command type is stored in the next 4 bytes
     8. the command type is an unsigned int value that can be used to determine whether the payload is XML or JSON
     */
    
    NSMutableData *const dataBuffer = self.partialData;
    
    switch (streamEvent) {
        case NSStreamEventOpenCompleted: {
            break;
        }
            
        case NSStreamEventHasBytesAvailable:
            if (theStream == self.inputStream) {
                // Multiple response payloads in one callback is possible
                while ([self.inputStream hasBytesAvailable]) {
                    uint8_t inputBuffer[4096];
                    
                    NSInteger bufferLength = [self.inputStream read:inputBuffer maxLength:sizeof(inputBuffer)];
                    if (bufferLength > 0) {
                        // Append received data to partial buffer
                        
                        [dataBuffer appendBytes:&inputBuffer[0] length:(NSUInteger) bufferLength];
                        
                        while (dataBuffer.length > COMMAND_HEADER_LEN_BYTES) {
                            // number of bytes for the complete response
                            unsigned int payloadLength = 0;
                            [dataBuffer getBytes:&payloadLength range:NSMakeRange(0, 4)];
                            payloadLength = NSSwapBigIntToHost(payloadLength);
                            
                            // fail fast if we have not cumulateed enough data
                            if (dataBuffer.length < COMMAND_HEADER_LEN_BYTES + payloadLength) {
                                break; // command not completely received
                            }
                            
                            // the command type pertaining to the response
                            unsigned int commandType_raw;
                            [dataBuffer getBytes:&commandType_raw range:NSMakeRange(4, 4)];
                            commandType_raw = NSSwapBigIntToHost(commandType_raw);
                            
                            CommandType commandType = (CommandType) commandType_raw;
                            id responsePayload = nil;
                            BOOL parsedPayload = NO;
                            NSLog(@"cloudendpoint response: %d", commandType);
                            if (!securifi_valid_command_type(commandType)) {
                                NSLog(@"Ignoring payload, the command type is not known to this system, type:%i, payload:%@",
                                      commandType, [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding]);
                            }
                            else if (securifi_valid_json_command_type(commandType)) {
                                NSData *buffer = [dataBuffer subdataWithRange:NSMakeRange(COMMAND_HEADER_LEN_BYTES, payloadLength)];
                                // JSON payloads for Notifications are wrapped in <root></root>.
                                // All other JSON commands are NOT
                                if ([self isWrappedJson:commandType]) {
                                    // strip the <root></root> wrapper
                                    NSUInteger startLen = @"<root>".length;
                                    NSUInteger endLen = @"</root>".length;
                                    NSRange parseRange = NSMakeRange(COMMAND_HEADER_LEN_BYTES + startLen, payloadLength - endLen - startLen);
                                    
                                    buffer = [dataBuffer subdataWithRange:parseRange];
                                }
                                
                                NSString *response = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
                                NSLog(@"Cloud receive:  %@", [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]);
                                
                                switch (commandType) {
                                        // these are the only command responses so far that uses a JSON payload; we special case them for now
                                    case CommandType_NOTIFICATIONS_SYNC_RESPONSE:
                                        responsePayload = [NotificationListResponse parseNotificationsJson:buffer];
                                        parsedPayload = YES;
                                        break;
                                    case CommandType_NOTIFICATIONS_COUNT_RESPONSE:
                                        responsePayload = [NotificationCountResponse parseJson:buffer];
                                        parsedPayload = YES;
                                        break;
                                    case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE:
                                        responsePayload = [NotificationClearCountResponse parseJson:buffer];
                                        parsedPayload = YES;
                                        break;
                                    case CommandType_DEVICELOG_RESPONSE:
                                        responsePayload = [NotificationListResponse parseDeviceLogsJson:buffer];
                                        parsedPayload = YES;
                                        break;
                                    case CommandType_GET_ALL_SCENES:
                                    case CommandType_COMMAND_RESPONSE:
                                    case CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE:
                                    case CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST:
                                    case CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST:
                                    case CommandType_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE:
                                    case CommandType_DYNAMIC_WIFI_CLIENT_REMOVED_ALL:
                                    case CommandType_RULE_LIST:
                                    case CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES:
                                    case CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES:
                                    case CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES:
                                    case CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES:
                                    case CommandType_ROUTER_COMMAND_REQUEST_RESPONSE:
                                    case CommandType_NOTIFICATION_PREF_CHANGE_DYNAMIC_RESPONSE:
                                    case CommandType_DYNAMIC_ALMOND_NAME_CHANGE:
                                    case CommandType_MESH_COMMAND:

                                    case (CommandType) 99:
                                        // these commands are not wrapped; simply pass the JSON back
                                        responsePayload = buffer;
                                        parsedPayload = YES;
                                        break;
                                    default: {
                                        // should not happen
                                        NSString *name = securifi_command_type_to_string(commandType);
                                        NSLog(@"Warning: unhandled JSON command type, id=%i, name=%@", commandType, name);
                                        break;
                                    }
                                }
                            }
                            else {
                                // XML payloads
                                NSRange parseRange = NSMakeRange(COMMAND_HEADER_LEN_BYTES, payloadLength);
                                
                                NSInteger actual_length = dataBuffer.length;
                                NSInteger expected_length = parseRange.length - parseRange.location;
                                if (actual_length < expected_length) {
                                    NSLog(@"Ignoring payload, the buffer length is wrong, actual:%li, expected:%li", (long) actual_length, (long) expected_length);
                                    break;
                                }
                                
                                @try {
                                    NSData *buffer = [dataBuffer subdataWithRange:parseRange];
                                    //                                    DLog(@"Partial Buffer : %@", [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]);
                                    
                                    CommandParser *parser = [CommandParser new];
                                    NSLog(@"xml Cloud receive:  %@", [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]);
                                    GenericCommand *temp = (GenericCommand *) [parser parseXML:buffer];
                                    responsePayload = temp.command;
                                    
                                    // important to pull command type from the parsed payload because the underlying
                                    // command that we dispatch on can be different than the "container" carrying it
                                    commandType = temp.commandType;
                                    
                                    parsedPayload = YES;
                                }
                                @catch (NSException *ex) {
                                    NSString *buffer_str = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
                                    NSLog(@"Exception on parsing XML payload, ex:%@, data:'%@'", ex, buffer_str);
                                }
                            } // end if valid command, json, or xml
                            if (parsedPayload) {
                                // Tell the world the connection is up and running
                                //                                [self tryPostNetworkUpNotification];
                                // Process the request by passing it to the delegate
                                [self.delegate networkEndpoint:self dispatchResponse:responsePayload commandType:(CommandType) commandType];
                            }
                            
                            // clear out the consumed command payload; truncate the buffer
                            [dataBuffer replaceBytesInRange:NSMakeRange(0, COMMAND_HEADER_LEN_BYTES + payloadLength) withBytes:NULL length:0];
                        }
                    }
                }
                
                break;
            }
            
        case NSStreamEventErrorOccurred: {
            NSLog(@"NSStreamEventHasSpaceAvailable");
            if (theStream == self.outputStream) {
                NSLog(@"Output stream error: %@", theStream.streamError.localizedDescription);
                [self shutdownAndCallDelegate];
            }
            break;
        }
            
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"NSStreamEventHasSpaceAvailable");
            // Evaluate the SSL connection
            if (self.networkConfig.enableCertificateValidation && !self.certificateTrusted) {
                BOOL trusted = [self isTrustedCertificate:theStream];
                if (!trusted) {
                    NSLog(@"%s: SSL Cert is not trusted. Issuing shutdown.", __PRETTY_FUNCTION__);
                    [self shutdownAndCallDelegate];
                }
                self.certificateTrusted = trusted;
            }
            
            break;
        }
            
        case NSStreamEventEndEncountered: {
            NSLog(@"NSStreamEventHasSpaceAvailable");
            if (theStream == self.inputStream) {
                NSLog(@"%s: SESSION ENDED CONNECTION BROKEN TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                [self shutdownAndCallDelegate];
            }
            
            break;
        }
            
        default: {
            DLog(@"%s: Unhandled event: %li", __PRETTY_FUNCTION__, (long) streamEvent);
        }
        case NSStreamEventNone:break;
    }
}

#pragma mark - SSL certificates

- (void)loadCertificate {
    NSString *certFileName = self.networkConfig.certificateFileName;
    NSString *path = [[NSBundle mainBundle] pathForResource:certFileName ofType:@"der"];
    NSData *certData = [NSData dataWithContentsOfFile:path];
    
    SecCertificateRef oldCertificate = self.certificate;
    self.certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certData);
    if (oldCertificate) {
        CFRelease(oldCertificate);
    }
}

- (BOOL)isTrustedCertificate:(NSStream *)aStream {
    SecTrustRef secTrust = (__bridge SecTrustRef) [aStream propertyForKey:(NSString *) kCFStreamPropertySSLPeerTrust];
    if (secTrust == nil) {
        NSLog(@"%s: Unable to evaluate trust; stream did not return security trust ref", __PRETTY_FUNCTION__);
        return NO;
    }
    
    SecTrustResultType resultType;
    SecTrustGetTrustResult(secTrust, &resultType);
    
    switch (resultType) {
        case kSecTrustResultDeny:
        case kSecTrustResultRecoverableTrustFailure:
        case kSecTrustResultFatalTrustFailure:
        case kSecTrustResultOtherError:
            return NO;
            
        case kSecTrustResultInvalid:
        case kSecTrustResultProceed:
        case kSecTrustResultUnspecified:
        default:
            break;
    }
    
    if (resultType == kSecTrustResultInvalid) {
        NSLog(@"Cert test: kSecTrustResultInvalid");
        
        SecTrustResultType result;
        OSStatus status = SecTrustEvaluate(secTrust, &result);
        if (status != errSecSuccess) {
            NSLog(@"Cert test fail: kSecTrustResultInvalid !errSecSuccess");
            return NO;
        }
        
        switch (result) {
            case kSecTrustResultDeny:
            case kSecTrustResultRecoverableTrustFailure:
            case kSecTrustResultFatalTrustFailure:
            case kSecTrustResultOtherError:
                return NO;
                
            case kSecTrustResultInvalid: {
                NSLog(@"Cert test fail: kSecTrustResultInvalid again");
                return NO;
            }
                
            case kSecTrustResultProceed:
            case kSecTrustResultUnspecified:
            default:
                break;
        }
    }
    
    return [self evaluateCertificate:secTrust];
}

- (BOOL)evaluateCertificate:(SecTrustRef)secTrust {
    CFIndex count = SecTrustGetCertificateCount(secTrust);
    if (count == 0) {
        NSLog(@"Cert test fail: zero certificate count");
        return NO;
    }
    
    NSMutableArray *streamCertificates = [NSMutableArray array];
    for (CFIndex index = 0; index < count; index++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(secTrust, index);
        id cert = (__bridge id) certificate;
        [streamCertificates addObject:cert];
    }
    
    SecPolicyRef policy = SecPolicyCreateSSL(YES, CFSTR("*.securifi.com")); // must be released
    
    SecTrustRef trust = NULL; // must be released
    OSStatus status;
    
    status = SecTrustCreateWithCertificates((__bridge CFArrayRef) streamCertificates, policy, &trust);
    if (status != errSecSuccess) {
        NSLog(@"%s: Failed to create trust with certs copy", __PRETTY_FUNCTION__);
        return NO;
    }
    
    SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) @[(id) self.certificate]);
    
    SecTrustResultType trustResultType = kSecTrustResultInvalid;
    status = SecTrustEvaluate(trust, &trustResultType);
    
    BOOL trusted;
    if (status == errSecSuccess) {
        if (trustResultType == kSecTrustResultUnspecified) {
            trusted = YES;
        }
        else {
            NSLog(@"%s: Certificate is not trusted. TrustResultType: %d", __PRETTY_FUNCTION__, trustResultType);
            trusted = NO;
        }
    }
    else {
        NSLog(@"%s: Unable to evaluate trust: %d", __PRETTY_FUNCTION__, (int) status);
        trusted = NO;
    }
    
    if (trust) {
        CFRelease(trust);
    }
    if (policy) {
        CFRelease(policy);
    }
    
    return trusted;
}


#pragma mark - Command submission

- (BOOL)sendCommand:(GenericCommand *)command error:(NSError **)outError {
    //if (![ConnectionStatus isStreamConnected]) {
    //DLog(@"SendCommand failed: CloudEndpoint is not connected");
    //        *outError = [self makeError:@"SubmitCommand failed: CloudEndpoint is not connected" errorCode:CloudEndpointSocketError_notConnectedState];
    //return NO;
    //}
    
    return [self internalSendToCloud:self command:command error:outError];
}

- (BOOL)internalSendToCloud:(CloudEndpoint *)cloudEndpoint command:(GenericCommand*)command error:(NSError **)outError {
    NSLog(@"internal send to cloud");
    if (!cloudEndpoint) {
        DLog(@"%s: aborting send. endoint is null", __PRETTY_FUNCTION__);
        return NO;
    }
    
    if (!command) {
        DLog(@"%s: aborting send. command is null", __PRETTY_FUNCTION__);
        return NO;
    }
    
    @synchronized (self.syncLocker) {
        DLog(@"Sending command, cmd:%@", command.debugDescription);
        
        CommandType commandType = command.commandType;
        id commandPayload;
        
        @try {
            switch (command.commandType) {
                case CommandType_LOGIN_COMMAND:
                case CommandType_LOGIN_TEMPPASS_COMMAND:
                case CommandType_LOGOUT_ALL_COMMAND:
                case CommandType_SIGNUP_COMMAND:
                case CommandType_AFFILIATION_CODE_REQUEST:
                case CommandType_MOBILE_COMMAND:
                case CommandType_VALIDATE_REQUEST:
                case CommandType_RESET_PASSWORD_REQUEST:
                case CommandType_SENSOR_CHANGE_REQUEST:
                case CommandType_GENERIC_COMMAND_REQUEST:
                case CommandType_CHANGE_PASSWORD_REQUEST:
                case CommandType_DELETE_ACCOUNT_REQUEST:
                case CommandType_UPDATE_USER_PROFILE_REQUEST:
                case CommandType_UNLINK_ALMOND_REQUEST:
                case CommandType_USER_INVITE_REQUEST:
                case CommandType_DELETE_SECONDARY_USER_REQUEST:
                case CommandType_DELETE_ME_AS_SECONDARY_USER_REQUEST:
                case CommandType_NOTIFICATION_REGISTRATION:
                case CommandType_NOTIFICATION_DEREGISTRATION:
                case CommandType_NOTIFICATION_PREF_CHANGE_REQUEST:
                case CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST:
                case CommandType_ALMOND_MODE_REQUEST:
                case CommandType_NOTIFICATIONS_SYNC_REQUEST:
                case CommandType_NOTIFICATIONS_COUNT_REQUEST:
                case CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST:{
                    id <SecurifiCommand> cmd = command.command;
                    commandPayload = [cmd toXml];
                    break;
                }
                    // Commands that transfer in Command 61 container
                case CommandType_ALMOND_MODE_CHANGE_REQUEST:
                case CommandType_ALMOND_NAME_CHANGE_REQUEST:
                case CommandType_DEVICE_DATA_FORCED_UPDATE_REQUEST: {
                    id <SecurifiCommand> cmd = command.command;
                    //Send as Command 61
                    commandType = CommandType_MOBILE_COMMAND;
                    commandPayload = [cmd toXml];
                    break;
                }
                    
                case CommandType_LOGOUT_COMMAND: {
                    commandPayload = LOGOUT_REQUEST_XML;
                    break;
                }
                    
                case CommandType_CLOUD_SANITY: {
                    commandPayload = CLOUD_SANITY_REQUEST_XML;
                    break;
                }
                    //PY 150914 Accounts
                case CommandType_ALMOND_LIST:
                case CommandType_USER_PROFILE_REQUEST: //PY 150914 Accounts
                case CommandType_ME_AS_SECONDARY_USER_REQUEST:
                case CommandType_ALMOND_AFFILIATION_DATA_REQUEST:{
                    commandPayload = ALMOND_LIST_REQUEST_XML; //Refractor - Can be used for commands with no input <root> </root>
                    break;
                }
                    
                case CommandType_DEVICELOG_REQUEST: {
                    NSData *data = command.command;
                    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    commandPayload = [NSString stringWithFormat:@"<root>%@</root>", json];
                    break;
                };
                    
                case CommandType_GET_ALL_SCENES:
                case CommandType_UPDATE_REQUEST:
                case CommandType_WIFI_CLIENTS_LIST_REQUEST:
                case CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES:
                case CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES:
                case CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES:
                case CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES:
                case CommandType_ROUTER_COMMAND_REQUEST_RESPONSE:
                case CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST:
                case CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST:
                case CommandType_RULE_LIST:{
                    commandPayload = command.command;
                    break;
                }
                    
                default: {
                    NSString *description = [NSString stringWithFormat:@"%s: Aborting write, unsupported command, cmd=%@", __PRETTY_FUNCTION__, command.command];
//                    *outError = [self makeError:description errorCode:CloudEndpointSocketError_unsupportedCommand];
                    return NO;
                }
            }
            
            NSData *write_payload = [commandPayload isKindOfClass:NSData.class] ? commandPayload : [commandPayload dataUsingEncoding:NSUTF8StringEncoding];
            unsigned int header_payloadLength = (unsigned int) htonl([write_payload length]);
            unsigned int header_commandType = (unsigned int) htonl(commandType);

            NSLog(@"Sending payload: %@, \nType: %d", commandPayload, commandType);
            
            if([commandPayload isKindOfClass:[NSData class]]){
                NSLog(@"Sending payload: %@, \nType: %d", [[NSString alloc] initWithData:commandPayload encoding:NSUTF8StringEncoding], commandType);
            }else{
                NSLog(@"Sending payload: %@, \nType: %d", commandPayload, commandType);
            }
            
            NSOutputStream *outputStream = cloudEndpoint.outputStream;
            if (outputStream == nil) {
                DLog(@"%s: Output stream is nil, out=%@", __PRETTY_FUNCTION__, outputStream);
                //*outError = [self makeError:@"Securifi - Output stream is nil" errorCode:CloudEndpointSocketError_outputStreamNil];
                return NO;
            }
            
            // Wait until socket is open
            NSStreamStatus streamStatus;
            do {
                streamStatus = [outputStream streamStatus];
            } while (streamStatus == NSStreamStatusOpening);
            
            switch (streamStatus) {
                case NSStreamStatusNotOpen:
                case NSStreamStatusAtEnd:
                case NSStreamStatusClosed:
                case NSStreamStatusError:
                    DLog(@"%s: Aborting write, stream status = %li", (long) streamStatus);
                    goto socket_failure_handler;
                    
                default:
                    // pass through and continue processing
                    break;
            }
            
            //if ([ConnectionStatus isStreamConnected] && outputStream.streamStatus != NSStreamStatusError)
            if (outputStream.streamStatus != NSStreamStatusError){
                if (-1 == [outputStream write:(uint8_t *) &header_payloadLength maxLength:4]) {
                    DLog(@"%s: Failed writing 'payload length' 4 bytes");
                    goto socket_failure_handler;
                }
            }
            
            //if ([ConnectionStatus isStreamConnected] && outputStream.streamStatus != NSStreamStatusError)
            if (outputStream.streamStatus != NSStreamStatusError){
                if (-1 == [outputStream write:(uint8_t *) &header_commandType maxLength:4]) {
                    DLog(@"%s: Failed writing 'command type' 4 bytes");
                    goto socket_failure_handler;
                }
            }
            
            //if ([ConnectionStatus isStreamConnected] && outputStream.streamStatus != NSStreamStatusError)
            if (outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [outputStream write:[write_payload bytes] maxLength:[write_payload length]]) {
                    DLog(@"%s: Failed writing 'payload' %i bytes", sendCommandPayload.length);
                    goto socket_failure_handler;
                }
            }
            
            DLog(@"%s: Exiting sync block", __PRETTY_FUNCTION__);
            
            //if (![ConnectionStatus isStreamConnected]) {
            //DLog(@"%s: Output stream is not connected, out=%@", __PRETTY_FUNCTION__, outputStream);
            //*outError = [self makeError:@"Securifi - Output stream is not connected" /errorCode:CloudEndpointSocketError_notConnectedState];
            //return NO;
            //}
            if (outputStream.streamStatus == NSStreamStatusError) {
                DLog(@"%s: Output stream has error status, out=%@, err=%@", __PRETTY_FUNCTION__, outputStream, outputStream.streamError);
                *outError = outputStream.streamError;
                return NO;
            }
            else {
                DLog(@"%s: sent command to cloud: TIME => %f ", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                return YES;
            }
            
        socket_failure_handler:
            {
                NSLog(@"Socket failure handler invoked");
                
                streamStatus = [outputStream streamStatus];
                NSString *description = [NSString stringWithFormat:@"Securifi Payload - Send Error, stream status=%li", (long) streamStatus];
                return NO;
            }//label socket_failure_handler
        }
        @catch (NSException *e) {
            NSLog(@"%s: Exception : %@", __PRETTY_FUNCTION__, e.reason);
            @throw;
        } //try-catch
    }//synchronized
}

- (NSError *)makeError:(NSString *)description errorCode:(enum CloudEndpointSocketError)errorCode {
    NSDictionary *details = @{NSLocalizedDescriptionKey : description};
    return [NSError errorWithDomain:@"Securifi" code:errorCode userInfo:details];
}

@end

