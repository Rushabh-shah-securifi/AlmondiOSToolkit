//  SingleTon.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//


#import "SingleTon.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "Commandparser.h"
#import "SUnit.h"
#import "NotificationListResponse.h"
#import "NotificationCountResponse.h"
#import "NotificationClearCountResponse.h"

@interface SingleTon ()
@property(nonatomic, readonly) NSObject *syncLocker;

@property(atomic) NSInteger currentUnitCounter;
@property(nonatomic) SUnit *currentUnit;

@property(nonatomic, readonly) dispatch_queue_t initializationQueue;    // serial queue to which network initialization commands submitted to the system are added
@property(nonatomic, readonly) dispatch_queue_t commandQueue;           // serial queue to which commands submitted to the system are added
@property(nonatomic, readonly) dispatch_queue_t backgroundQueue;        // queue on which the streams are managed
@property(nonatomic, readonly) dispatch_queue_t callbackQueue;          // queue used for posting notifications
@property(nonatomic, readonly) dispatch_queue_t dynamicCallbackQueue;          // queue used for posting notifications
@property(nonatomic, readonly) dispatch_semaphore_t network_established_latch;
@property(nonatomic, readonly) dispatch_semaphore_t cloud_initialized_latch;

@property(nonatomic) SecCertificateRef certificate;
@property(nonatomic) BOOL certificateTrusted;
@property(nonatomic, readonly) NSMutableData *partialData;
@property(nonatomic) BOOL networkShutdown;
@property(nonatomic) BOOL networkUpNoticePosted;
@property(nonatomic) NSInputStream *inputStream;
@property(nonatomic) NSOutputStream *outputStream;
@property(nonatomic) BOOL sendCommandFail;

@property(nonatomic, readonly) NSObject *almondTableSyncLocker;
@property(nonatomic, readonly) NSMutableSet *hashCheckedForAlmondTable;
@property(nonatomic, readonly) NSMutableSet *deviceValuesCheckedForAlmondTable;

@property(nonatomic, readonly) NSObject *willFetchDeviceListFlagSyncLocker;
@property(nonatomic, readonly) NSMutableSet *willFetchDeviceListFlag;

@property(nonatomic, readonly) NSObject *almondModeSynLocker;
@property(nonatomic, readonly) NSMutableDictionary *almondModeTable;

@end

@implementation SingleTon

+ (SingleTon *)newSingletonWithResponseCallbackQueue:(dispatch_queue_t)callbackQueue dynamicCallbackQueue:(dispatch_queue_t)dynamicCallbackQueue {
    return [[SingleTon alloc] initWithQueue:callbackQueue dynamicCallbackQueue:dynamicCallbackQueue];
}

- (id)initWithQueue:(dispatch_queue_t)callbackQueue dynamicCallbackQueue:(dispatch_queue_t)dynamicCallbackQueue {
    self = [super init];
    if (self) {
        self.isLoggedIn = NO;
        self.isStreamConnected = NO;
        self.sendCommandFail = NO;
        self.networkShutdown = NO;
        self.connectionState = SDKCloudStatusUninitialized;
        _syncLocker = [NSObject new];
        
        _initializationQueue = dispatch_queue_create("cloud_init_command_queue", DISPATCH_QUEUE_SERIAL);
        _commandQueue = dispatch_queue_create("command_queue", DISPATCH_QUEUE_SERIAL);
        
        _backgroundQueue = dispatch_queue_create("socket_queue", DISPATCH_QUEUE_CONCURRENT);
        _callbackQueue = callbackQueue;
        _dynamicCallbackQueue = dynamicCallbackQueue;
        
        _network_established_latch = dispatch_semaphore_create(0);
        _cloud_initialized_latch = dispatch_semaphore_create(0);
        
        _almondTableSyncLocker = [NSObject new];
        _hashCheckedForAlmondTable = [NSMutableSet new];
        _deviceValuesCheckedForAlmondTable = [NSMutableSet new];
        
        _willFetchDeviceListFlagSyncLocker = [NSObject new];
        _willFetchDeviceListFlag = [NSMutableSet new];
        
        _almondModeSynLocker = [NSObject new];
        _almondModeTable = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)initNetworkCommunication:(BOOL)useProductionCloud {
    NSLog(@"Initialzing network communication");
    
    __strong SingleTon *block_self = self;
    
    dispatch_async(self.backgroundQueue, ^(void) {
        if (block_self.inputStream == nil && block_self.outputStream == nil) {
            [block_self postData:NETWORK_CONNECTING_NOTIFIER data:nil];
            
            // Load certificate
            //
            if (self.config.enableCertificateValidation) {
                DLog(@"Loading certificate");
                [block_self loadCertificate];
            }
            
            DLog(@"Initializing sockets");
            
            CFReadStreamRef readStream;
            CFWriteStreamRef writeStream;
            
            NSString *server = useProductionCloud ? self.config.productionCloudHost : self.config.developmentCloudHost;
            CFStringRef host = (__bridge CFStringRef) server;
            UInt32 port = self.config.cloudPort;
            CFStreamCreatePairWithSocketToHost(NULL, host, port, &readStream, &writeStream);
            
            block_self.inputStream = (__bridge_transfer NSInputStream *) readStream;
            block_self.outputStream = (__bridge_transfer NSOutputStream *) writeStream;
            
            block_self.inputStream.delegate = block_self;
            block_self.outputStream.delegate = block_self;
            
            [block_self.inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
            [block_self.outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
            
            NSNumber *enableChainValidation = self.config.enableCertificateChainValidation ? @YES : @NO;
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
            
            // Signal to waiting socket writers that the network is up and then invoke the run loop to pump events
            block_self.isStreamConnected = YES;
            dispatch_semaphore_signal(block_self.network_established_latch);
            //
            [block_self.delegate singletTonCloudConnectionDidEstablish:block_self];
            //
            while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && !block_self.networkShutdown) {
                //                DLog(@"Streams entered run loop");
            }
            block_self.isStreamConnected = NO;
            
            [block_self.inputStream removeFromRunLoop:runLoop forMode:NSDefaultRunLoopMode];
            [block_self.outputStream removeFromRunLoop:runLoop forMode:NSDefaultRunLoopMode];
            
            DLog(@"Streams exited run loop");
            
            [block_self.delegate singletTonCloudConnectionDidClose:block_self];
        }
        else {
            NSLog(@"Stream already opened");
        }
        
        block_self.networkShutdown = YES;
    });
}

- (void)dealloc {
    if (_certificate) {
        CFRelease(_certificate);
        _certificate = nil;
    }
}

- (void)shutdown {
    NSLog(@"Shutting down network singleton");
    
    // Take weak reference to prevent retain cycles
    __weak SingleTon *block_self = self;
    
    dispatch_sync(self.backgroundQueue, ^(void) {
        NSLog(@"[%@] Singleton is shutting down", block_self.debugDescription);
        
        // Signal shutdown
        //
        block_self.networkShutdown = YES;
        block_self.isLoggedIn = NO;
        block_self.connectionState = SDKCloudStatusCloudConnectionShutdown;
        block_self.isStreamConnected = NO;
        
        // Clean up command queue
        //
        [block_self tryAbortUnit];
        dispatch_semaphore_signal(block_self.network_established_latch);
        dispatch_semaphore_signal(block_self.cloud_initialized_latch);
        
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
    [self.delegate singletTonCloudConnectionDidClose:self];
}

#pragma mark - Semaphores

// Called during command process need to use the output stream. Blocks until the connection is set up or fails.
// return YES when time out is reached; NO if connection established without timeout
// On time out, the SingleTon will shut itself down
- (BOOL)waitForConnectionEstablishment:(int)numSecsToWait {
    dispatch_semaphore_t latch = self.network_established_latch;
    NSString *msg = @"Giving up on connection establishment";
    
    BOOL timedOut = [self waitOnLatch:latch timeout:numSecsToWait logMsg:msg];
    if (self.isStreamConnected) {
        // If the connection is up by now, no need to worry about the timeout.
        return NO;
    }
    if (timedOut) {
        NSLog(@"%@. Issuing shutdown on timeout", msg);
        [self shutdown];
    }
    return timedOut;
}

// Called by commands submitted to the normal command queue that have to wait for the cloud initialization
// sequence to complete. Like network establishment procedures, this process can time out in which case the
// SingleTon is shutdown.
- (BOOL)waitForCloudInitialization:(int)numSecsToWait {
    dispatch_semaphore_t latch = self.cloud_initialized_latch;
    NSString *msg = @"Giving up on cloud initialization";
    
    BOOL timedOut = [self waitOnLatch:latch timeout:numSecsToWait logMsg:msg];
    if (timedOut) {
        NSLog(@"%@. Issuing shutdown on timeout", msg);
        [self shutdown];
    }
    return timedOut;
}

// Waits up to the specified number of seconds for the semaphore to be signalled.
// Returns YES on timeout waiting on the latch.
// Returns NO when the signal has been received before the timeout.
- (BOOL)waitOnLatch:(dispatch_semaphore_t)latch timeout:(int)numSecsToWait logMsg:(NSString *)msg {
    dispatch_time_t max_time = dispatch_time(DISPATCH_TIME_NOW, numSecsToWait * NSEC_PER_SEC);
    
    BOOL timedOut = NO;
    
    dispatch_time_t blockingSleepSecondsIfNotDone;
    do {
        if (self.networkShutdown) {
            NSLog(@"%@. Network was shutdown.", msg);
            break;
        }
        if (self.sendCommandFail) {
            NSLog(@"%@. Failed to send cmd.", msg);
            break;
        }
        if (self.connectionState == SDKCloudStatusInitialized) {
            NSLog(@"%@. Cloud is initialized.", msg);
            break;
        }
        
        const int waitMs = 5;
        blockingSleepSecondsIfNotDone = dispatch_time(DISPATCH_TIME_NOW, waitMs * NSEC_PER_MSEC);
        
        timedOut = blockingSleepSecondsIfNotDone > max_time;
        if (timedOut) {
            NSLog(@"%@. Timeout reached.", msg);
            break;
        }
    }
    while (0 != dispatch_semaphore_wait(latch, blockingSleepSecondsIfNotDone));
    
    // make sure...
    dispatch_semaphore_signal(latch);
    
    return timedOut;
}

#pragma mark - Logged In state

- (void)markLoggedInState:(BOOL)loggedIn {
    self.isLoggedIn = loggedIn;
    self.connectionState = loggedIn ? SDKCloudStatusLoggedIn : SDKCloudStatusNotLoggedIn;
}

#pragma mark - NSStreamDelegate methods

- (void)tryMarkUnitCompletion:(BOOL)success responseType:(CommandType)responseType {
    SUnit *unit = self.currentUnit;
    
    if (unit) {
        [unit markResponse:success];
        [self.delegate singletTonDidReceiveCommandResponse:self command:unit.command timeToCompletion:unit.timeToCompletionSuccess responseType:responseType];
        DLog(@"Marking response %i for unit: %@", responseType, unit.description);
    }
    else {
        [self.delegate singletTonDidReceiveCommandResponse:self command:nil timeToCompletion:0 responseType:responseType];
    }
}

- (void)tryAbortUnit {
    SUnit *unit = self.currentUnit;
    
    if (unit) {
        DLog(@"Marking unit as aborted: %@", unit.description);
        [unit abort];
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
                while (!self.networkShutdown && [self.inputStream hasBytesAvailable]) {
                    uint8_t inputBuffer[4096];
                    
                    NSInteger bufferLength = [self.inputStream read:inputBuffer maxLength:sizeof(inputBuffer)];
                    if (bufferLength > 0) {
                        //Append received data to partial buffer
                        [self.partialData appendBytes:&inputBuffer[0] length:(NSUInteger) bufferLength];
                        BOOL dataMayContainJSON = YES;
                        while (dataMayContainJSON) {
                            dataMayContainJSON = NO;
                            if (self.partialData.length > 8) {
                                unsigned int commandType;
                                NSRange commandTypeRange = NSMakeRange(4, 4);
                                [self.partialData getBytes:&commandType range:commandTypeRange];
                                commandType = NSSwapBigIntToHost(commandType);
                                DLog(@"%s:COMMAND Received: %d TIME => %f ", __PRETTY_FUNCTION__, commandType, CFAbsoluteTimeGetCurrent());
                                
                                
                                if (commandType == CommandType_LIST_SCENE_RESPONSE || commandType==CommandType_COMMAND_RESPONSE || commandType == CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE  || commandType==CommandType_WIFI_CLIENTS_LIST_RESPONSE || commandType==CommandType_DYNAMIC_CLIENT_UPDATE_REQUEST || commandType==1549 || commandType==1547 || commandType==1545 || commandType==1543 || commandType==1551  || commandType==99) {
                                    //MD01 ----means json / not xml -----------------
                                    if (commandType==1549 || commandType==1547 || commandType==1545 || commandType==1543 || commandType==1541 || commandType==1551) {
                                        //99 chgitenq inch command a
                                        
                                        int a=1;
                                    }
                                    
                                    NSRange payloadLenghtRange = NSMakeRange(0, 4);
                                    unsigned int payloadLenght;
                                    [self.partialData getBytes:&payloadLenght range:payloadLenghtRange];
                                    payloadLenght = NSSwapBigIntToHost(payloadLenght);
                                    
                                    if (self.partialData.length>=8+payloadLenght) {
                                        NSUInteger start_loc = 8;
                                        NSRange jsonParseRange = NSMakeRange(start_loc, payloadLenght);
                                        
                                        NSData *buffer = [self.partialData subdataWithRange:jsonParseRange];
                                        
                                        DLog(@"Partial Buffer : %@", [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]);
                                        //                                        id responsePayload = nil;
                                        
                                        //                                        responsePayload = [NotificationListResponse parseJson:buffer];
                                        
                                        // Remove 8 bytes from received command
                                        [self.partialData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
                                        
                                        // Tell the world the connection is up and running
                                        [self tryPostNetworkUpNotification];
                                        
                                        [self dispatchResponse:buffer commandType:(CommandType) commandType];
                                        
                                        [self.partialData replaceBytesInRange:NSMakeRange(0, payloadLenght /* Removed 8 bytes before */) withBytes:NULL length:0];
                                        if (self.partialData.length>8) {
                                            dataMayContainJSON = YES;
                                        }
                                    }
                                    
                                }
                                
                            }
                        }
                        
                        
                        
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
                                    
                                    // these are the only command responses so far that uses a JSON payload; we special case them for now
                                    if (commandType == CommandType_NOTIFICATIONS_SYNC_RESPONSE || commandType == CommandType_NOTIFICATIONS_COUNT_RESPONSE || commandType == CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE) {
                                        // we only want the JSON wrapped inside the <root></root> pair
                                        NSUInteger start_loc = startTagRange.location + startTagRange.length;
                                        NSRange jsonParseRange = NSMakeRange(start_loc, endTagRange.location - start_loc);
                                        NSData *buffer = [self.partialData subdataWithRange:jsonParseRange];
                                        DLog(@"Partial Buffer : %@", [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]);
                                        
                                        if (commandType == CommandType_NOTIFICATIONS_SYNC_RESPONSE) {
                                            responsePayload = [NotificationListResponse parseJson:buffer];
                                        }
                                        else if (commandType == CommandType_NOTIFICATIONS_COUNT_RESPONSE) {
                                            responsePayload = [NotificationCountResponse parseJson:buffer];
                                        }
                                        else {
                                            responsePayload = [NotificationClearCountResponse parseJson:buffer];
                                        }
                                    }
                                    else {
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
                                    
                                    // Remove 8 bytes from received command
                                    [self.partialData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
                                    
                                    // Tell the world the connection is up and running
                                    [self tryPostNetworkUpNotification];
                                    
                                    [self dispatchResponse:responsePayload commandType:(CommandType) commandType];
                                    
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
            if (self.config.enableCertificateValidation && !self.certificateTrusted) {
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
            DLog(@"%s: Unhandled event: %li", __PRETTY_FUNCTION__, (long)streamEvent);
        }
    }
}

- (void)dispatchResponse:(id)payload commandType:(CommandType)commandType {
    switch (commandType) {
        case CommandType_LOGIN_RESPONSE: {
            LoginResponse *obj = (LoginResponse *) payload;
            [self markLoggedInState:obj.isSuccessful];
            [self tryMarkUnitCompletion:obj.isSuccessful responseType:commandType];
            [self postData:LOGIN_NOTIFIER data:obj];
            break;
        }
            
        case CommandType_SIGNUP_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:SIGN_UP_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_KEEP_ALIVE: {
            break;
        }
            
        case CommandType_CLOUD_SANITY_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            break;
        }
            
        case CommandType_LOGOUT_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:LOGOUT_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_LOGOUT_ALL_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:LOGOUT_ALL_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_AFFILIATION_USER_COMPLETE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:AFFILIATION_COMPLETE_NOTIFIER data:payload];
            break;
        }
            //                                        case AFFILIATION_CODE_RESPONSE:
            //                                        {
            //                                            // [SNLog Log:@"%s: Received Affiliation Code", __PRETTY_FUNCTION__];
            //                                            AffiliationUserRequest *obj = (AffiliationUserRequest *)temp.command;
            //
            //                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
            //
            //                                            [[NSNotificationCenter defaultCenter] postNotificationName:AFFILIATION_CODE_NOTIFIER object:self userInfo:data];
            //                                            tempObj=nil;
            //                                            temp=nil;
            //                                        }
            //                                            break;
        case CommandType_ALMOND_LIST_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:ALMOND_LIST_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_DEVICE_DATA_HASH_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:DEVICEDATA_HASH_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_DEVICE_DATA_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:DEVICE_DATA_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_DEVICE_VALUE_LIST_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:DEVICE_VALUE_LIST_NOTIFIER data:payload];
            break;
        }
        case CommandType_MOBILE_COMMAND_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:MOBILE_COMMAND_NOTIFIER data:payload];
            break;
        }
        case CommandType_DYNAMIC_DEVICE_DATA: {
            [self postDataDynamic:DYNAMIC_DEVICE_DATA_NOTIFIER data:payload commandType:commandType];
            break;
        }
        case CommandType_DYNAMIC_DEVICE_VALUE_LIST: {
            [self postDataDynamic:DYNAMIC_DEVICE_VALUE_LIST_NOTIFIER data:payload commandType:commandType];
            break;
        }
        case CommandType_GENERIC_COMMAND_RESPONSE: {
            GenericCommandResponse *obj = (GenericCommandResponse *) payload;
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:GENERIC_COMMAND_NOTIFIER data:obj];
            break;
        }
        case CommandType_GENERIC_COMMAND_NOTIFICATION: {
            //                                            [self tryMarkUnitCompletion:YES responseType:GENERIC_COMMAND_NOTIFICATION];
            [self postData:GENERIC_COMMAND_CLOUD_NOTIFIER data:payload];
            break;
        }
        case CommandType_VALIDATE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:VALIDATE_RESPONSE_NOTIFIER data:payload];
            break;
        }
        case CommandType_RESET_PASSWORD_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:RESET_PWD_RESPONSE_NOTIFIER data:payload];
            break;
        }
        case CommandType_DYNAMIC_ALMOND_ADD: {
            [self postDataDynamic:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER data:payload commandType:commandType];
            break;
        }
        case CommandType_DYNAMIC_ALMOND_DELETE: {
            [self postDataDynamic:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER data:payload commandType:commandType];
            break;
        }
        case CommandType_SENSOR_CHANGE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:SENSOR_CHANGE_NOTIFIER data:payload];
            break;
        }
        case CommandType_DYNAMIC_ALMOND_NAME_CHANGE: {
            [self postDataDynamic:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER data:payload commandType:commandType];
            break;
        }
        case CommandType_DYNAMIC_ALMOND_MODE_CHANGE: {
            [self postDataDynamic:DYNAMIC_ALMOND_MODE_CHANGE_NOTIFIER data:payload commandType:commandType];
            break;
        }
            
        case CommandType_USER_PROFILE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:USER_PROFILE_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_CHANGE_PASSWORD_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:CHANGE_PWD_RESPONSE_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_DELETE_ACCOUNT_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:DELETE_ACCOUNT_RESPONSE_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_UPDATE_USER_PROFILE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:UPDATE_USER_PROFILE_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_ALMOND_AFFILIATION_DATA_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:ALMOND_AFFILIATION_DATA_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_UNLINK_ALMOND_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:UNLINK_ALMOND_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_USER_INVITE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:USER_INVITE_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_DELETE_SECONDARY_USER_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:DELETE_SECONDARY_USER_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_ALMOND_NAME_CHANGE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:ALMOND_NAME_CHANGE_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_ALMOND_MODE_CHANGE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:ALMOND_MODE_CHANGE_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_ALMOND_MODE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:ALMOND_MODE_RESPONSE_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_ME_AS_SECONDARY_USER_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:ME_AS_SECONDARY_USER_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_DELETE_ME_AS_SECONDARY_USER_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:DELETE_ME_AS_SECONDARY_USER_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_NOTIFICATION_REGISTRATION_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_REGISTRATION_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_NOTIFICATION_DEREGISTRATION_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_DEREGISTRATION_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_DYNAMIC_NOTIFICATION_PREFERENCE_LIST: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:DYNAMIC_NOTIFICATION_PREFERENCE_LIST_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_PREFERENCE_LIST_RESPONSE_NOTIFIER data:payload];
            break;
        }
        case CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_PREFERENCE_CHANGE_RESPONSE_NOTIFIER data:payload];
            break;
        }
        case CommandType_NOTIFICATIONS_SYNC_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_LIST_SYNC_RESPONSE_NOTIFIER data:payload];
            break;
        };
        case CommandType_NOTIFICATIONS_COUNT_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_COUNT_RESPONSE_NOTIFIER data:payload];
            break;
        };
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_CLEAR_COUNT_RESPONSE_NOTIFIER data:payload];
            break;
        };
        case CommandType_LIST_SCENE_RESPONSE: {
            //md01
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_GET_ALL_SCENES_NOTIFIER data:payload];
            break;
        };
        case CommandType_COMMAND_RESPONSE: {
            //md01
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER data:payload];
            break;
        };
        case CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE: {
            //md01
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE_NOTIFIER data:payload];
            break;
        };
        case CommandType_WIFI_CLIENTS_LIST_RESPONSE: {
            //md01
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_WIFI_CLIENTS_LIST_RESPONSE data:payload];
            break;
        };
        case CommandType_DYNAMIC_CLIENT_UPDATE_REQUEST: {
            //md01
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_DYNAMIC_CLIENT_UPDATE_REQUEST_NOTIFIER data:payload];
            break;
        };
        default:
            break;
    }
}

- (void)tryPostNetworkUpNotification {
    if (self.networkShutdown) {
        return;
    }
    if (!self.networkUpNoticePosted) {
        self.networkUpNoticePosted = YES;
        [self postData:NETWORK_UP_NOTIFIER data:nil];
    }
}

#pragma mark - Payload notification

- (void)postData:(NSString *)notificationName data:(id)payload {
    // An interesting behavior: notifications are posted mainly to the UI. There is an assumption built into the system that
    // the notifications are posted synchronously from the SDK. Change the dispatch queue to async, and the
    // UI can easily become confused. This needs to be sorted out.
    SLog(@"Posting %@", notificationName);
    [self post:notificationName payload:payload queue:self.callbackQueue];
}

- (void)postDataDynamic:(NSString *)notificationName data:(id)payload commandType:(CommandType)commandType {
    // An interesting behavior: notifications are posted mainly to the UI. There is an assumption built into the system that
    // the notifications are posted synchronously from the SDK. Change the dispatch queue to async, and the
    // UI can easily become confused. This needs to be sorted out.
    SLog(@"Posting dynamic %@", notificationName);
    [self post:notificationName payload:payload queue:self.dynamicCallbackQueue];
    [self.delegate singletTonDidReceiveDynamicUpdate:self commandType:commandType];
}

- (void)post:(NSString *)notificationName payload:(id)payload queue:(dispatch_queue_t)queue {
    __weak id block_payload = payload;
    
    dispatch_sync(queue, ^() {
        NSDictionary *data = nil;
        if (payload) {
            data = @{@"data" : block_payload};
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:data];
    });
}

#pragma mark - SSL certificates

- (void)loadCertificate {
    NSString *certFileName = self.config.certificateFileName;
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

#pragma mark - Hash value management

- (void)markHashFetchedForAlmond:(NSString *)aAlmondMac {
    @synchronized (self.almondTableSyncLocker) {
        [self.hashCheckedForAlmondTable addObject:aAlmondMac];
    }
}

- (BOOL)wasHashFetchedForAlmond:(NSString *)aAlmondMac {
    @synchronized (self.almondTableSyncLocker) {
        return [self.hashCheckedForAlmondTable containsObject:aAlmondMac];
    }
}

- (void)markWillFetchDeviceListForAlmond:(NSString *)aAlmondMac {
    if (aAlmondMac.length == 0) {
        return;
    }
    @synchronized (self.willFetchDeviceListFlagSyncLocker) {
        [self.willFetchDeviceListFlag addObject:aAlmondMac];
    }
}

- (BOOL)willFetchDeviceListFetchedForAlmond:(NSString *)aAlmondMac {
    if (aAlmondMac.length == 0) {
        return NO;
    }
    @synchronized (self.willFetchDeviceListFlagSyncLocker) {
        return [self.willFetchDeviceListFlag containsObject:aAlmondMac];
    }
}

- (void)clearWillFetchDeviceListForAlmond:(NSString *)aAlmondMac {
    if (aAlmondMac.length == 0) {
        return;
    }
    @synchronized (self.willFetchDeviceListFlagSyncLocker) {
        [self.willFetchDeviceListFlag removeObject:aAlmondMac];
    }
}

- (void)markDeviceValuesFetchedForAlmond:(NSString *)aAlmondMac {
    @synchronized (self.almondTableSyncLocker) {
        [self.deviceValuesCheckedForAlmondTable addObject:aAlmondMac];
    }
}

- (BOOL)wasDeviceValuesFetchedForAlmond:(NSString *)aAlmondMac {
    @synchronized (self.almondTableSyncLocker) {
        return [self.deviceValuesCheckedForAlmondTable containsObject:aAlmondMac];
    }
}

- (void)markModeForAlmond:(NSString *)aAlmondMac mode:(SFIAlmondMode)mode {
    if (aAlmondMac == nil) {
        return;
    }
    
    NSNumber *num = @(mode);
    @synchronized (self.almondModeSynLocker) {
        self.almondModeTable[aAlmondMac] = num;
    }
}

- (SFIAlmondMode)almondMode:(NSString *)aAlmondMac {
    if (aAlmondMac == nil) {
        return SFIAlmondMode_unknown;
    }
    
    @synchronized (self.almondModeSynLocker) {
        NSNumber *num = self.almondModeTable[aAlmondMac];
        
        if (num == nil) {
            return SFIAlmondMode_unknown;
        }
        
        return (SFIAlmondMode) [num unsignedIntValue];
    }
}

- (void)clearAlmondMode:(NSString *)aAlmondMac {
    if (aAlmondMac == nil) {
        return;
    }
    
    @synchronized (self.almondModeSynLocker) {
        [self.almondModeTable removeObjectForKey:aAlmondMac];
    }
}


#pragma mark - Command submission

- (NSInteger)nextUnitCounter {
    NSInteger next = self.currentUnitCounter + 1;
    self.currentUnitCounter = next;
    return next;
}

- (void)markCloudInitialized {
    SDKCloudStatus cloudStatus = self.connectionState;
    if (cloudStatus == SDKCloudStatusInitialized) {
        return;
    }
    if (cloudStatus == SDKCloudStatusCloudConnectionShutdown) {
        return;
    }
    
    // There may be other commands in the initialization queue still waiting for responses.
    // Let them complete or timeout before opening up the main command queue.
    // Therefore, queue a command to make the state change and start the main queue's processing.
    
    NSLog(@"Queuing cloud initialization completed command");
    
    __weak SingleTon *block_self = self;
    dispatch_async(self.initializationQueue, ^() {
        SDKCloudStatus status = block_self.connectionState;
        if (status == SDKCloudStatusInitialized) {
            return;
        }
        if (status == SDKCloudStatusCloudConnectionShutdown) {
            return;
        }
        
        block_self.connectionState = SDKCloudStatusInitialized;
        dispatch_semaphore_t latch = block_self.cloud_initialized_latch;
        if (latch) {
            NSInteger limit = self.currentUnitCounter;
            for (NSInteger i = 0; i < limit; i++) {
                dispatch_semaphore_signal(latch);
            }
            NSLog(@"Executed cloud initialization completed command");
        }
    });
}

- (BOOL)submitCloudInitializationCommand:(GenericCommand *)command {
    if (self.connectionState == SDKCloudStatusInitialized) {
        NSLog(@"Rejected cloud initialization command submission: already marked as initialized");
        return NO;
    }
    
    dispatch_queue_t queue = self.initializationQueue;
    BOOL waitForInit = NO;
    return [self internalSubmitCommand:command queue:queue waitForNetworkInitializedLatch:waitForInit waitAtMostSecs:5];
}

- (BOOL)submitCommand:(GenericCommand *)command {
    dispatch_queue_t queue = self.commandQueue;
    BOOL waitForInit = YES;
    
    switch (self.connectionState) {
        case SDKCloudStatusNetworkDown:
        case SDKCloudStatusCloudConnectionShutdown:
            // don't even queue; just get out
            return NO;
            
        case SDKCloudStatusInitialized:
            waitForInit = NO;
            break;
            
        case SDKCloudStatusUninitialized:
            break;
        case SDKCloudStatusInitializing:
            break;
        case SDKCloudStatusNotLoggedIn:
            break;
        case SDKCloudStatusLoginInProcess:
            break;
        case SDKCloudStatusLoggedIn:
            break;
    }
    
    return [self internalSubmitCommand:command queue:queue waitForNetworkInitializedLatch:waitForInit waitAtMostSecs:0];
}

// we manage two different queues, one for initializing the network, and one for normal network operation.
// this mechanism allows the initialization logic to be determined by the toolkit as responses are returned.
// when initializing, the normal command queue blocks on the network_initialized_latch semaphore
- (BOOL)internalSubmitCommand:(GenericCommand *)command queue:(dispatch_queue_t)queue waitForNetworkInitializedLatch:(BOOL)waitForNetworkInitializedLatch waitAtMostSecs:(int)waitAtMostSecs {
    if (self.networkShutdown) {
        DLog(@"SubmitCommand failed: network is shutdown");
        return NO;
    }
    
    DLog(@"Command Queue: queueing command: %@, wait:%@", command, waitForNetworkInitializedLatch ? @"YES" : @"NO");
    
    __weak SingleTon *block_self = self;
    dispatch_async(queue, ^() {
        if (block_self.networkShutdown) {
            SLog(@"Command Queue: aborting unit: network is shutdown");
            return;
        }
        if (waitForNetworkInitializedLatch) {
            int const timeOutSecs = 10;
            [block_self waitForCloudInitialization:timeOutSecs];
        }
        if (block_self.networkShutdown) {
            SLog(@"Command Queue: aborting unit: network is shutdown");
            return;
        }
        
        NSInteger tag = [block_self nextUnitCounter];
        
        SUnit *unit = [[SUnit alloc] initWithCommand:command];
        [unit markWorking:tag];
        block_self.currentUnit = unit;
        
        SLog(@"Command Queue: sending %ld (%@)", (long) tag, command);
        
        NSError *error;
        BOOL success = [block_self internalSendToCloud:block_self command:command error:&error];
        if (!success) {
            NSLog(@"Command Queue: send error: %@, tag:%ld", error.description, (long) tag);
            [unit markResponse:NO];
            return;
        }
        [block_self.delegate singletTonDidSendCommand:block_self command:command];
        
        SLog(@"Command Queue: waiting for response: %ld (%@)", (long) tag, command);
        
        //        int const waitAtMostSecs = 1;
        [unit waitForResponse:waitAtMostSecs];
        
        SLog(@"Command Queue: done waiting for response: %ld (%@)", (long) tag, command);
    });
    
    return YES;
}

- (BOOL)internalSendToCloud:(SingleTon *)socket command:(id)sender error:(NSError **)outError {
    DLog(@"%s: Waiting to enter sync block", __PRETTY_FUNCTION__);
    
    @synchronized (self.syncLocker) {
        DLog(@"%s: Entered sync block", __PRETTY_FUNCTION__);
        
        // Wait for connection establishment if need be.
        if (!socket.isStreamConnected) {
            DLog(@"Waiting for connection establishment");
            BOOL timedOut = [socket waitForConnectionEstablishment:20]; // wait 20 seconds
            DLog(@"Done waiting for connection establishment, timedOut=%@", timedOut ? @"YES" : @"NO");
            
            if (timedOut) {
                DLog(@"Timed out waiting to initialize connection");
                *outError = [self makeError:@"Securifi - Timed out waiting to initialize connection"];
                return NO;
            }
            
            if (!socket.isStreamConnected) {
                DLog(@"Stream died on connection");
                *outError = [self makeError:@"Securifi - Stream died on connection"];
                return NO;
            }
        }
        
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
                case CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST:
                {
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
                case CommandType_GET_ALL_SCENES:
                case CommandType_UPDATE_REQUEST:
                case CommandType_WIFI_CLIENTS_LIST_REQUEST:{
                    
                    commandType = (unsigned int) htonl(obj.commandType);
                    commandPayload = obj.command;
                    break;
                }
                default:
                    break;
            } // end switch
            
            NSData *sendCommandPayload = [commandPayload dataUsingEncoding:NSUTF8StringEncoding];
            unsigned int commandLength = (unsigned int) htonl([sendCommandPayload length]);
            
            DLog(@"@Payload being sent: %@", commandPayload);
            
            NSOutputStream *outputStream = socket.outputStream;
            if (outputStream == nil) {
                DLog(@"%s: Output stream is nil, out=%@", __PRETTY_FUNCTION__, outputStream);
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
                return NO;
            }
            else if (outputStream.streamStatus == NSStreamStatusError) {
                DLog(@"%s: Output stream has error status, out=%@", __PRETTY_FUNCTION__, outputStream);
                return NO;
            }
            else {
                DLog(@"%s: sent command to cloud: TIME => %f ", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                return YES;
            }
            
        socket_failure_handler:
            {
                DLog(@"Socket failure handler invoked");
                
                socket.isLoggedIn = NO;
                socket.sendCommandFail = YES;
                socket.isStreamConnected = NO;
                
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

