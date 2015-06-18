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
#import "NetworkConfig.h"

typedef NS_ENUM(unsigned int, CloudEndpointConnectionStatus) {
    CloudEndpointConnectionStatus_uninitialized = 1,
    CloudEndpointConnectionStatus_connecting,
    CloudEndpointConnectionStatus_established,
    CloudEndpointConnectionStatus_failed,
    CloudEndpointConnectionStatus_shutting_down,
    CloudEndpointConnectionStatus_shutdown,
};

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

@property(nonatomic, readonly) enum CloudEndpointConnectionStatus connectionState;

@end


@implementation CloudEndpoint

+ (instancetype)endpointWithConfig:(NetworkConfig *)config {
    return [[self alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(NetworkConfig *)config {
    self = [super init];
    if (self) {
        _networkConfig = config;

        [self markConnectionState:CloudEndpointConnectionStatus_uninitialized];

        _syncLocker = [NSObject new];
        _backgroundQueue = dispatch_queue_create("socket_queue", DISPATCH_QUEUE_CONCURRENT);
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
    [self markConnectionState:CloudEndpointConnectionStatus_connecting];

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

            DLog(@"Initializing sockets");

            CFReadStreamRef readStream;
            CFWriteStreamRef writeStream;

            NSString *server = configurator.host;
            CFStringRef host = (__bridge CFStringRef) server;
            UInt32 port = configurator.port;
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

            DLog(@"Secheduling in run loop");

            [block_self.inputStream scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
            [block_self.outputStream scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];

            DLog(@"Opening streams");

            [block_self.inputStream open];
            [block_self.outputStream open];

            DLog(@"Streams open and entering run loop");

            [self markConnectionState:CloudEndpointConnectionStatus_established];
            [block_self.delegate networkEndpointDidConnect:block_self];

            while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && block_self.isStreamConnected) {
//                DLog(@"Streams entered run loop");
            }

            [block_self.inputStream removeFromRunLoop:runLoop forMode:NSDefaultRunLoopMode];
            [block_self.outputStream removeFromRunLoop:runLoop forMode:NSDefaultRunLoopMode];
        }
        else {
            NSLog(@"Stream already opened");
        }

        DLog(@"Streams exited run loop");
        [self markConnectionState:CloudEndpointConnectionStatus_shutdown];
        [block_self.delegate networkEndpointDidDisconnect:block_self];
    });

}

- (void)shutdown {
    NSLog(@"Shutting down CloudEndpoint Network");

    // Take weak reference to prevent retain cycles
    __weak CloudEndpoint *block_self = self;

    dispatch_sync(self.backgroundQueue, ^(void) {
        NSLog(@"[%@] CloudEndpoint is shutting down", block_self.debugDescription);

        // Signal shutdown
        //
        [block_self markConnectionState:CloudEndpointConnectionStatus_shutting_down];

        // Synchronize access: wait for other readers/writers before tearing down the sockets
        //
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
    });

    // Tell delegate of shutdown
    [self.delegate networkEndpointDidDisconnect:self];
}

#pragma mark - state

- (BOOL)isStreamConnected {
    enum CloudEndpointConnectionStatus status = self.connectionState;

    switch (status) {
        case CloudEndpointConnectionStatus_connecting:
        case CloudEndpointConnectionStatus_established:
            return YES;

        case CloudEndpointConnectionStatus_uninitialized:
        case CloudEndpointConnectionStatus_failed:
        case CloudEndpointConnectionStatus_shutting_down:
        case CloudEndpointConnectionStatus_shutdown:
        default:
            return NO;
    }
}

- (void)markConnectionState:(enum CloudEndpointConnectionStatus)status {
    _connectionState = status;

    switch (status) {
        case CloudEndpointConnectionStatus_uninitialized:
            NSLog(@"Connection State: uninitialized");
            break;
        case CloudEndpointConnectionStatus_connecting:
            NSLog(@"Connection State: connecting");
            break;
        case CloudEndpointConnectionStatus_established:
            NSLog(@"Connection State: established");
            break;
        case CloudEndpointConnectionStatus_failed:
            NSLog(@"Connection State: failed");
            break;
        case CloudEndpointConnectionStatus_shutting_down:
            NSLog(@"Connection State: shutting_down");
            break;
        case CloudEndpointConnectionStatus_shutdown:
            NSLog(@"Connection State: shutdown");
            break;
    }

}

#pragma mark - NSStreamDelegate methods

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

    if (!self.partialData) {
        _partialData = [[NSMutableData alloc] init];
    }

    NSString *startTagString = @"<root>";
    NSData *startTag = [startTagString dataUsingEncoding:NSUTF8StringEncoding];

    NSString *endTagString = @"</root>";
    NSData *endTag = [endTagString dataUsingEncoding:NSUTF8StringEncoding];

    switch (streamEvent) {
        case NSStreamEventOpenCompleted: {
            break;
        }

        case NSStreamEventHasBytesAvailable:
            if (theStream == self.inputStream) {
                // Multiple response payloads in one callback is possible
                while (self.isStreamConnected && [self.inputStream hasBytesAvailable]) {
                    uint8_t inputBuffer[4096];

                    NSInteger bufferLength = [self.inputStream read:inputBuffer maxLength:sizeof(inputBuffer)];
                    if (bufferLength > 0) {
                        //Append received data to partial buffer
                        [self.partialData appendBytes:&inputBuffer[0] length:(NSUInteger) bufferLength];

                        // Range of current data buffer
                        NSRange endTagRange = NSMakeRange(0, [self.partialData length]);
                        while (endTagRange.location != NSNotFound) {
                            endTagRange = [self.partialData rangeOfData:endTag options:0 range:endTagRange];

                            if (endTagRange.location != NSNotFound) {
                                // Look for <root> tag in [0 to endTag]
                                NSRange startTagRange = NSMakeRange(0, endTagRange.location);

                                startTagRange = [self.partialData rangeOfData:startTag options:0 range:startTagRange];

                                if (startTagRange.location == NSNotFound) {
                                    NSLog(@"%s: Serious error !!! should not come here// Invalid command /// without startRootTag", __PRETTY_FUNCTION__);
                                }
                                else {
/*
                                    unsigned int payloadLength;
                                    NSRange payloadLengthRange = NSMakeRange(0, 4);
                                    [self.partialData getBytes:&payloadLength range:payloadLengthRange];
                                    payloadLength = NSSwapBigIntToHost(payloadLength);
                                    NSLog(@"Payload is %i bytes long", payloadLength);
*/

                                    unsigned int commandType;
                                    NSRange commandTypeRange = NSMakeRange(4, 4);
                                    [self.partialData getBytes:&commandType range:commandTypeRange];
                                    commandType = NSSwapBigIntToHost(commandType);
                                    DLog(@"%s: Response Received: %d TIME => %f ", __PRETTY_FUNCTION__, commandType, CFAbsoluteTimeGetCurrent());

                                    // Process a single command response at a time
                                    id responsePayload = nil;

                                    switch (commandType) {
                                        // these are the only command responses so far that uses a JSON payload; we special case them for now
                                        case CommandType_NOTIFICATIONS_SYNC_RESPONSE:
                                        case CommandType_NOTIFICATIONS_COUNT_RESPONSE:
                                        case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE:
                                        case CommandType_DEVICELOG_RESPONSE: {
                                            // we only want the JSON wrapped inside the <root></root> pair
                                            NSUInteger start_loc = startTagRange.location + startTagRange.length;
                                            NSRange jsonParseRange = NSMakeRange(start_loc, endTagRange.location - start_loc);
                                            NSData *buffer = [self.partialData subdataWithRange:jsonParseRange];
                                            DLog(@"Partial Buffer : %@", [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]);

                                            if (commandType == CommandType_NOTIFICATIONS_SYNC_RESPONSE) {
                                                responsePayload = [NotificationListResponse parseNotificationsJson:buffer];
                                            }
                                            else if (commandType == CommandType_NOTIFICATIONS_COUNT_RESPONSE) {
                                                responsePayload = [NotificationCountResponse parseJson:buffer];
                                            }
                                            else if (commandType == CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE) {
                                                responsePayload = [NotificationClearCountResponse parseJson:buffer];
                                            }
                                            else {
                                                // CommandType_DEVICELOG_RESPONSE
                                                responsePayload = [NotificationListResponse parseDeviceLogsJson:buffer];
                                            }

                                            break;
                                        };

                                            // All others are XML
                                        default: {
                                            NSRange xmlParserRange = NSMakeRange(startTagRange.location, (endTagRange.location + endTagRange.length - 8));
                                            NSData *buffer = [self.partialData subdataWithRange:xmlParserRange];
                                            DLog(@"Partial Buffer : %@", [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]);

                                            CommandParser *parser = [CommandParser new];
                                            GenericCommand *temp = (GenericCommand *) [parser parseXML:buffer];
                                            responsePayload = temp.command;

                                            // important to pull command type from the parsed payload because the underlying
                                            // command that we dispatch on can be different than the "container" carrying it
                                            commandType = temp.commandType;
                                        }

                                            break;
                                    }

                                    // Remove 8 bytes from received command
                                    [self.partialData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

                                    // Tell the world the connection is up and running
                                    [self tryPostNetworkUpNotification];

                                    // Process the request by passing it to the delegate
                                    [self.delegate networkEndpoint:self dispatchResponse:responsePayload commandType:(CommandType) commandType];

                                    // Advance the buffer
                                    [self.partialData replaceBytesInRange:NSMakeRange(0, endTagRange.location + endTagRange.length - 8 /* Removed 8 bytes before */) withBytes:NULL length:0];

                                    // Regenerate NSRange
                                    endTagRange = NSMakeRange(0, [self.partialData length]);
                                }
                            }
                        }
                    }
                }

                break;
            }

        case NSStreamEventErrorOccurred: {
            if (theStream == self.outputStream) {
                NSLog(@"Output stream error: %@", theStream.streamError.localizedDescription);
                [self shutdown];
            }

            break;
        }

        case NSStreamEventHasSpaceAvailable: {
            // Evaluate the SSL connection
            if (self.networkConfig.enableCertificateValidation && !self.certificateTrusted) {
                BOOL trusted = [self isTrustedCertificate:theStream];
                if (!trusted) {
                    NSLog(@"%s: SSL Cert is not trusted. Issuing shutdown.", __PRETTY_FUNCTION__);
                    [self shutdown];
                }
                self.certificateTrusted = trusted;
            }

            break;
        }

        case NSStreamEventEndEncountered: {
            if (theStream == self.inputStream) {
                DLog(@"%s: SESSION ENDED CONNECTION BROKEN TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                [self shutdown];
            }

            break;
        }

        default: {
            DLog(@"%s: Unhandled event: %li", __PRETTY_FUNCTION__, (long) streamEvent);
        }
    }
}

- (void)tryPostNetworkUpNotification {
    if (self.connectionState != CloudEndpointConnectionStatus_established) {
        return;
    }
    if (!self.networkUpNoticePosted) {
        self.networkUpNoticePosted = YES;
        [self.delegate networkEndpointDidConnect:self];
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
    if (!self.isStreamConnected) {
        DLog(@"SendCommand failed: CloudEndpoint is not connected");
        *outError = [self makeError:@"SubmitCommand failed: CloudEndpoint is not connected"];
        return NO;
    }

    return [self internalSendToCloud:self command:command error:outError];
}

- (BOOL)internalSendToCloud:(CloudEndpoint *)socket command:(id)sender error:(NSError **)outError {
    @synchronized (self.syncLocker) {
        GenericCommand *obj = (GenericCommand *) sender;
        DLog(@"Sending command, cmd:%@", obj.debugDescription);

        unsigned int commandType = htonl(obj.commandType);;
        NSString *commandPayload;

        @try {
            switch (obj.commandType) {
                case CommandType_LOGIN_COMMAND:
                case CommandType_LOGIN_TEMPPASS_COMMAND:
                case CommandType_LOGOUT_ALL_COMMAND:
                case CommandType_SIGNUP_COMMAND:
                case CommandType_AFFILIATION_CODE_REQUEST:
                case CommandType_DEVICE_DATA_HASH:
                case CommandType_DEVICE_DATA:
                case CommandType_DEVICE_VALUE:
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
                case CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST: {
                    id <SecurifiCommand> cmd = obj.command;
                    commandPayload = [cmd toXml];
                    break;
                }

                    // Commands that transfer in Command 61 container
                case CommandType_ALMOND_NAME_CHANGE_REQUEST:
                case CommandType_ALMOND_MODE_CHANGE_REQUEST:
                case CommandType_DEVICE_DATA_FORCED_UPDATE_REQUEST: {
                    id <SecurifiCommand> cmd = obj.command;
                    //Send as Command 61
                    commandType = (unsigned int) htonl(CommandType_MOBILE_COMMAND);
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
                case CommandType_USER_PROFILE_REQUEST: //PY 150914 Accounts
                case CommandType_ME_AS_SECONDARY_USER_REQUEST:
                case CommandType_ALMOND_AFFILIATION_DATA_REQUEST:
                case CommandType_ALMOND_LIST: {
                    commandPayload = ALMOND_LIST_REQUEST_XML; //Refractor - Can be used for commands with no input <root> </root>
                    break;
                }

                case CommandType_DEVICELOG_REQUEST: {
                    NSData *data = obj.command;
                    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                    commandType = (unsigned int) htonl(CommandType_DEVICELOG_REQUEST);
                    commandPayload = [NSString stringWithFormat:@"<root>%@</root>", json];
                    break;
                };

                default:
                    break;
            } // end switch

            NSData *sendCommandPayload = [commandPayload dataUsingEncoding:NSUTF8StringEncoding];
            unsigned int commandLength = (unsigned int) htonl([sendCommandPayload length]);

            DLog(@"Sending payload: %@", commandPayload);

            NSOutputStream *outputStream = socket.outputStream;
            if (outputStream == nil) {
                DLog(@"%s: Output stream is nil, out=%@", __PRETTY_FUNCTION__, outputStream);
                *outError = [self makeError:@"Securifi - Output stream is nil"];
                return NO;
            }

            // Wait until socket is open
            NSStreamStatus type;
            do {
                type = [outputStream streamStatus];
            } while (type == NSStreamStatusOpening);

//            if (socket.isStreamConnected) {
//                [outputStream streamStatus];
//            }

            if (socket.isStreamConnected && outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [outputStream write:(uint8_t *) &commandLength maxLength:4]) {
                    goto socket_failure_handler;
                }
            }

            if (socket.isStreamConnected && outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [outputStream write:(uint8_t *) &commandType maxLength:4]) {
                    goto socket_failure_handler;
                }
            }

            if (socket.isStreamConnected && outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [outputStream write:[sendCommandPayload bytes] maxLength:[sendCommandPayload length]]) {
                    goto socket_failure_handler;
                }
            }

            DLog(@"%s: Exiting sync block", __PRETTY_FUNCTION__);

            if (!socket.isStreamConnected) {
                DLog(@"%s: Output stream is not connected, out=%@", __PRETTY_FUNCTION__, outputStream);
                *outError = [self makeError:@"Securifi - Output stream is not connected"];
                return NO;
            }
            else if (outputStream.streamStatus == NSStreamStatusError) {
                DLog(@"%s: Output stream has error status, out=%@", __PRETTY_FUNCTION__, outputStream);
                *outError = [self makeError:@"Securifi - Output stream has error status"];
                return NO;
            }
            else {
                DLog(@"%s: sent command to cloud: TIME => %f ", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                return YES;
            }

            socket_failure_handler:
            {
                DLog(@"Socket failure handler invoked");

                [socket markConnectionState:CloudEndpointConnectionStatus_failed];

                *outError = [self makeError:@"Securifi Payload - Send Error"];

                return NO;
            }//label socket_failure_handler
        }
        @catch (NSException *e) {
            NSLog(@"%s: Exception : %@", __PRETTY_FUNCTION__, e.reason);
            @throw;
        } //try-catch
    }//synchronized
}

- (NSError *)makeError:(NSString *)description {
    NSDictionary *details = @{NSLocalizedDescriptionKey : description};
    return [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];
}


@end

