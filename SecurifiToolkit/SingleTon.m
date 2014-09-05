//  SingleTon.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//


#import "SingleTon.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "Commandparser.h"
#import "PrivateCommandTypes.h"
#import "LoginTempPass.h"
#import "SUnit.h"

@interface SingleTon ()
@property (nonatomic, readonly) NSObject *syncLocker;

@property (atomic) NSInteger currentUnitCounter;
@property (atomic) SUnit *currentUnit;

@property(nonatomic, readonly) dispatch_queue_t initializationQueue;    // serial queue to which network initialization commands submitted to the system are added
@property(nonatomic, readonly) dispatch_queue_t commandQueue;           // serial queue to which commands submitted to the system are added
@property(nonatomic, readonly) dispatch_queue_t backgroundQueue;        // queue on which the streams are managed
@property(nonatomic, readonly) dispatch_queue_t callbackQueue;          // queue used for posting notifications
@property(nonatomic, readonly) dispatch_queue_t dynamicCallbackQueue;          // queue used for posting notifications
@property(nonatomic, readonly) dispatch_semaphore_t network_established_latch;
@property(nonatomic, readonly) dispatch_semaphore_t cloud_initialized_latch;

@property(nonatomic) SecCertificateRef certificate;
@property BOOL certificateTrusted;
@property(nonatomic) unsigned int command;
@property(nonatomic, readonly) NSMutableData *partialData;
@property(nonatomic) BOOL networkShutdown;
@property(nonatomic) BOOL networkUpNoticePosted;
@property(nonatomic) NSInputStream *inputStream;
@property(nonatomic) NSOutputStream *outputStream;
@property BOOL sendCommandFail;

@property(nonatomic, readonly) NSObject *almondTableSyncLocker;
@property(nonatomic, readonly) NSMutableSet *hashCheckedForAlmondTable;
@property(nonatomic, readonly) NSMutableSet *deviceValuesCheckedForAlmondTable;

@property(nonatomic, readonly) NSObject *willFetchDeviceListFlagSyncLocker;
@property(nonatomic, readonly) NSMutableSet *willFetchDeviceListFlag;

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
    }
    
    return self;
}

- (void)initNetworkCommunication {
    NSLog(@"Initialzing network communication");

    __strong SingleTon *block_self = self;
    
    dispatch_async(self.backgroundQueue, ^(void) {
        if (block_self.inputStream == nil && block_self.outputStream == nil) {
            [block_self postData:NETWORK_CONNECTING_NOTIFIER data:nil];

            // Load certificate
            //
            DLog(@"Loading certificate");

            [block_self loadCertificate];

            DLog(@"Initializing sockets");

            CFReadStreamRef readStream;
            CFWriteStreamRef writeStream;

            CFStringRef host = (__bridge CFStringRef) CLOUD_SERVER;
            UInt32 port = 1028;
            CFStreamCreatePairWithSocketToHost(NULL, host, port, &readStream, &writeStream);

            block_self.inputStream = (__bridge_transfer NSInputStream *) readStream;
            block_self.outputStream = (__bridge_transfer NSOutputStream *) writeStream;

            block_self.inputStream.delegate = block_self;
            block_self.outputStream.delegate = block_self;

            [block_self.inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
            [block_self.outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];

            //[SSLOptions setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsExpiredRoots];
            //[SSLOptions setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsExpiredCertificates];
            //[SSLOptions setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
            //[SSLOptions setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
            //[SSLOptions setObject:@"test.domain.com:443" forKey:(NSString *)kCFStreamSSLPeerName];
            //[SSLOptions setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString*)kCFStreamSSLLevel];
            //[SSLOptions setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString*)kCFStreamPropertySocketSecurityLevel];
            //[SSLOptions setObject:myCerts forKey:(NSString *)kCFStreamSSLCertificates];
            //[SSLOptions setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLIsServer];

            NSDictionary *settings = @{
                    (__bridge id) kCFStreamSSLAllowsExpiredRoots : @NO,
                    (__bridge id) kCFStreamSSLAllowsExpiredCertificates : @NO,
                    (__bridge id) kCFStreamSSLAllowsAnyRoot : @NO,
                    (__bridge id) kCFStreamSSLValidatesCertificateChain : @YES
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
- (BOOL)waitOnLatch:(dispatch_semaphore_t)latch timeout:(int)numSecsToWait logMsg:(NSString*)msg {
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

#pragma mark - NSStreamDelegate methods

- (void)tryMarkUnitCompletion:(BOOL)success responseType:(unsigned int)responseType {
    SUnit *unit = self.currentUnit;

    if (unit) {
        DLog(@"Marking response %i for unit: %@", responseType, unit.description);
        [unit markResponse:success];
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
    if (!self.partialData)
    {
        _partialData = [[NSMutableData alloc] init];
    }

    NSString *endTagString = @"</root>";
    NSData *endTag = [endTagString dataUsingEncoding:NSUTF8StringEncoding];

    NSString *startTagString = @"<root>";
    NSData *startTag = [startTagString dataUsingEncoding:NSUTF8StringEncoding];

	// NSLog(@"stream event %i", streamEvent);
	switch (streamEvent) {
		case NSStreamEventOpenCompleted: {
            break;
        }

		case NSStreamEventHasBytesAvailable:
			if (theStream == self.inputStream) {
				while (!self.networkShutdown && [self.inputStream hasBytesAvailable]) {
                    uint8_t inputBuffer[4096];
                    NSInteger len;

                    //Multiple entry in one callback possible
					len = [self.inputStream read:inputBuffer maxLength:sizeof(inputBuffer)];
					if (len > 0) {

                        //[SNLog Log:@"%s: Response Length : %d",__PRETTY_FUNCTION__,len];
                        //If current stream has </root>
                        //1. Get NSRange and prepare command
                        //2. If command has partial command add it to mutableData object
                        //3. It mutable object has some data append new received Data to it
                        //4. repeat this procedure for newly created mutableData

                        //Append received data to partial buffer
                        [self.partialData appendBytes:&inputBuffer[0] length:(NSUInteger) len];

                        //Initialize range
                        NSRange endTagRange = NSMakeRange(0, [self.partialData length]);
                        int count=0;

                        //NOT NEEDED- Convert received buffer to NSMutableData
                        //[totalReceivedData appendBytes:&inputBuffer[0] length:len];

                        while (endTagRange.location != NSNotFound)
                        {
                            endTagRange = [self.partialData rangeOfData:endTag options:0 range:endTagRange];
                            if(endTagRange.location != NSNotFound)
                            {
                                //// NSLog(@"endTag Location: %i, Length: %i",endTagRange.location,endTagRange.length);

                                //Look for <root> tag in [0 to endTag]
                                NSRange startTagRange = NSMakeRange(0, endTagRange.location);

                                startTagRange = [self.partialData rangeOfData:startTag options:0 range:startTagRange];

                                if(startTagRange.location == NSNotFound)
                                {
                                    // [SNLog Log:@"%s: Serious error !!! should not come here// Invalid command /// without startRootTag", __PRETTY_FUNCTION__];
                                }
                                else
                                {
                                    [self.partialData getBytes:&_command range:NSMakeRange(4, 4)];
                                    DLog(@"%s: Response Received: %d TIME => %f ",__PRETTY_FUNCTION__,NSSwapBigIntToHost(self.command), CFAbsoluteTimeGetCurrent());

                                    self.command = NSSwapBigIntToHost(self.command);
                                    // [SNLog Log:@"%s: Command Again: %d", __PRETTY_FUNCTION__,command];
                                    CommandParser *tempObj = [[CommandParser alloc] init];
                                    GenericCommand *temp = nil ;

                                    //Send single command data to parseXML rather than complete buffer
                                    NSRange xmlParserRange = {startTagRange.location, (endTagRange.location+endTagRange.length - 8)};
                                    NSData *buffer = [self.partialData subdataWithRange:xmlParserRange];

                                    DLog(@"Partial Buffer : %@", [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]);

                                    temp = (GenericCommand *)[tempObj parseXML:buffer];

                                    //Remove 8 bytes from received command
                                    [self.partialData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

                                    // Tell the world the connection is up and running
                                    [self tryPostNetworkUpNotification];

                                    switch (temp.commandType) {
                                        case LOGIN_RESPONSE: {
                                            LoginResponse *obj = (LoginResponse *) temp.command;
                                            if (obj.isSuccessful == YES) {
                                                //Set the indicator that we are logged in to prevent next login from User
                                                self.isLoggedIn = YES;
                                                self.connectionState = SDKCloudStatusLoggedIn;
                                            }
                                            else {
                                                self.isLoggedIn = NO;
                                                self.connectionState = SDKCloudStatusNotLoggedIn;
                                            }

                                            [self tryMarkUnitCompletion:obj.isSuccessful responseType:LOGIN_RESPONSE];
                                            [self postData:LOGIN_NOTIFIER data:obj];

                                            break;
                                        }
                                        case SIGNUP_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:SIGNUP_RESPONSE];
                                            [self postData:SIGN_UP_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case KEEP_ALIVE: {
//                                            [self tryMarkUnitCompletion:YES];
                                            break;
                                        }

                                        case CLOUD_SANITY_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:CLOUD_SANITY_RESPONSE];
                                            break;
                                        }
                                            //PY 250214 - Logout Response
                                        case LOGOUT_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:LOGOUT_RESPONSE];
                                            [self postData:LOGOUT_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 250214 - Logout All Response
                                        case LOGOUT_ALL_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:LOGOUT_ALL_RESPONSE];
                                            [self postData:LOGOUT_ALL_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case AFFILIATION_USER_COMPLETE: {
                                            [self tryMarkUnitCompletion:YES responseType:AFFILIATION_USER_COMPLETE];
                                            [self postData:AFFILIATION_COMPLETE_NOTIFIER data:temp.command];
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
                                            //PY 160913 - Almond List Response
                                        case ALMOND_LIST_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:ALMOND_LIST_RESPONSE];
                                            [self postData:ALMOND_LIST_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 170913 - Device Data Hash Response
                                        case DEVICEDATA_HASH_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:DEVICEDATA_HASH_RESPONSE];
                                            [self postData:DEVICEDATA_HASH_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 170913 - Device Data  Response
                                        case DEVICEDATA_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:DEVICEDATA_RESPONSE];
                                            [self postData:DEVICE_DATA_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 170913 - Device Data  Response
                                        case DEVICE_VALUE_LIST_RESPONSE: {
                                            // [SNLog Log:@"%s: Received Device Value Mobile Response", __PRETTY_FUNCTION__];
                                            [self tryMarkUnitCompletion:YES responseType:DEVICE_VALUE_LIST_RESPONSE];
                                            [self postData:DEVICE_VALUE_LIST_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 200913 - Mobile Command Response
                                        case MOBILE_COMMAND_RESPONSE: {
                                            // [SNLog Log:@"%s: Received Mobile Command Response", __PRETTY_FUNCTION__];
                                            [self tryMarkUnitCompletion:YES responseType:MOBILE_COMMAND_RESPONSE];
                                            [self postData:MOBILE_COMMAND_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 230913 - Device List Command - 81 -  Response
                                        case DYNAMIC_DEVICE_DATA: {
                                            // [SNLog Log:@"%s: Received DYNAMIC_DEVICE_DATA", __PRETTY_FUNCTION__];
                                            [self postDataDynamic:DYNAMIC_DEVICE_DATA_NOTIFIER data:temp.command];
                                            break;
                                        }

                                            //PY 230913 - Device Value Command - 82 -  Response
                                        case DYNAMIC_DEVICE_VALUE_LIST: {
                                            // [SNLog Log:@"%s: Received DEVICE_VALUE_LIST_RESPONSE", __PRETTY_FUNCTION__];
                                            [self postDataDynamic:DYNAMIC_DEVICE_VALUE_LIST_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 291013 - Generic Command Response
                                        case GENERIC_COMMAND_RESPONSE: {
                                            // [SNLog Log:@"%s: Received Generic Command Response", __PRETTY_FUNCTION__];
                                            GenericCommandResponse *obj = (GenericCommandResponse *) temp.command;
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            obj.decodedData = decodedData;

                                            [self tryMarkUnitCompletion:YES responseType:GENERIC_COMMAND_RESPONSE];
                                            [self postData:GENERIC_COMMAND_NOTIFIER data:obj];
                                            break;
                                        }
                                            //PY 301013 - Generic Command Notification
                                        case GENERIC_COMMAND_NOTIFICATION: {
                                            // [SNLog Log:@"%s: Received Generic Command Notification", __PRETTY_FUNCTION__];
                                            GenericCommandResponse *obj = (GenericCommandResponse *) temp.command;

                                            //Decode using Base64
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            obj.decodedData = decodedData;

//                                            [self tryMarkUnitCompletion:YES responseType:GENERIC_COMMAND_NOTIFICATION];
                                            [self postData:GENERIC_COMMAND_CLOUD_NOTIFIER data:obj];

                                            break;
                                        }
                                            //PY 011113 - Validate Account Response
                                        case VALIDATE_RESPONSE: {
                                            // [SNLog Log:@"%s: Received VALIDATE_RESPONSE", __PRETTY_FUNCTION__];
                                            [self tryMarkUnitCompletion:YES responseType:VALIDATE_RESPONSE];
                                            [self postData:VALIDATE_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case RESET_PASSWORD_RESPONSE: {
                                            // [SNLog Log:@"%s: Received RESET_PASSWORD_RESPONSE", __PRETTY_FUNCTION__];
                                            [self tryMarkUnitCompletion:YES responseType:RESET_PASSWORD_RESPONSE];
                                            [self postData:RESET_PWD_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case DYNAMIC_ALMOND_ADD: {
                                            // [SNLog Log:@"%s: Received DYNAMIC_ALMOND_ADD", __PRETTY_FUNCTION__];
                                            [self postDataDynamic:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case DYNAMIC_ALMOND_DELETE: {
                                            // [SNLog Log:@"%s: Received DYNAMIC_ALMOND_DELETE", __PRETTY_FUNCTION__];
                                            [self postDataDynamic:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case SENSOR_CHANGE_RESPONSE: {
                                            //[SNLog Log:@"%s: Received SENSOR_CHANGE_RESPONSE", __PRETTY_FUNCTION__];
                                            [self tryMarkUnitCompletion:YES responseType:SENSOR_CHANGE_RESPONSE];
                                            [self postData:SENSOR_CHANGE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case DYNAMIC_ALMOND_NAME_CHANGE: {
                                            // [SNLog Log:@"%s: Received DYNAMIC_ALMOND_NAME_CHANGE", __PRETTY_FUNCTION__];
                                            [self postDataDynamic:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        default:
                                            break;
                                    }

                                    [self.partialData replaceBytesInRange:NSMakeRange(0, endTagRange.location + endTagRange.length - 8 /* Removed 8 bytes before */) withBytes:NULL length:0];

                                    //Regenerate NSRange
                                    endTagRange = NSMakeRange(0, [self.partialData length]);
                                }
                                count++;
                            }
                            else
                            {
                                // [SNLog Log:@"%s: Number of Command Processed  : %d", __PRETTY_FUNCTION__,count];
                                //At this point paritalBuffer will have unffinised command data
                            }
                        }
                    }
                }
            }
            break;

        case NSStreamEventErrorOccurred:
            //Cleanup stream -- taken from EventEndEncountered
            //We should create new object of singleton class
            //if (theStream == outputStream && [outputStream streamStatus] == NSStreamStatusError)

            if (theStream == self.outputStream) {
                NSLog(@"Output stream error: %@", theStream.streamError.localizedDescription);
                [self shutdown];
            }
            break;

        case NSStreamEventHasSpaceAvailable: {
            // Evaluate the SSL connection
            if (!self.certificateTrusted) {
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
//                [SNLog Log:@"%s: Unknown event", __PRETTY_FUNCTION__];
        }
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

- (void)postData:(NSString*)notificationName data:(id)payload {
    // An interesting behavior: notifications are posted mainly to the UI. There is an assumption built into the system that
    // the notifications are posted synchronously from the SDK. Change the dispatch queue to async, and the
    // UI can easily become confused. This needs to be sorted out.
    SLog(@"Posting %@", notificationName);
    [self post:notificationName payload:payload queue:self.callbackQueue];
}

- (void)postDataDynamic:(NSString*)notificationName data:(id)payload {
    // An interesting behavior: notifications are posted mainly to the UI. There is an assumption built into the system that
    // the notifications are posted synchronously from the SDK. Change the dispatch queue to async, and the
    // UI can easily become confused. This needs to be sorted out.
    SLog(@"Posting dynamic %@", notificationName);
    [self post:notificationName payload:payload queue:self.dynamicCallbackQueue];
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"der"];
    NSData *certData = [NSData dataWithContentsOfFile:path];

    SecCertificateRef oldCertificate = self.certificate;
    self.certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certData);
    if (oldCertificate) {
        CFRelease(oldCertificate);
    }
}

- (BOOL)isTrustedCertificate:(NSStream *)aStream {
    SecPolicyRef policy = SecPolicyCreateSSL(NO, CFSTR("*.securifi.com"));

    SecTrustRef trust = NULL;
    CFArrayRef streamCertificates = (__bridge CFArrayRef) [aStream propertyForKey:(NSString *) kCFStreamPropertySSLPeerCertificates];
    SecTrustCreateWithCertificates(streamCertificates, policy, &trust);

    SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) @[(id) self.certificate]);

    SecTrustResultType trustResultType = kSecTrustResultInvalid;
    OSStatus status = SecTrustEvaluate(trust, &trustResultType);

    BOOL trusted;
    if (status == errSecSuccess) {
        // expect trustResultType == kSecTrustResultUnspecified until the cert exists in the keychain
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
            for (NSInteger i=0; i < limit; i++) {
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
    return [self internalSubmitCommand:command queue:queue waitForNetworkInitializedLatch:waitForInit];
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

        case SDKCloudStatusUninitialized:break;
        case SDKCloudStatusInitializing:break;
        case SDKCloudStatusNotLoggedIn:break;
        case SDKCloudStatusLoginInProcess:break;
        case SDKCloudStatusLoggedIn:break;
    }

    return [self internalSubmitCommand:command queue:queue waitForNetworkInitializedLatch:waitForInit];
}

// we manage two different queues, one for initializing the network, and one for normal network operation.
// this mechanism allows the initialization logic to be determined by the toolkit as responses are returned.
// when initializing, the normal command queue blocks on the network_initialized_latch semaphore
- (BOOL)internalSubmitCommand:(GenericCommand *)command queue:(dispatch_queue_t)queue waitForNetworkInitializedLatch:(BOOL)waitForNetworkInitializedLatch {
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
        [unit markWorking: tag];
        block_self.currentUnit = unit;

        SLog(@"Command Queue: sending %ld (%@)", (long)tag, command);

        NSError *error;
        BOOL success = [block_self internalSendToCloud:block_self command:command error:&error];
        if (!success) {
            NSLog(@"Command Queue: send error: %@, tag:%ld", error.description, (long)tag);
            [unit markResponse:NO];
            return;
        }

        SLog(@"Command Queue: waiting for response: %ld (%@)", (long)tag, command);

        int const waitAtMostSecs = 5;
        [unit waitForResponse:waitAtMostSecs];

        SLog(@"Command Queue: done waiting for response: %ld (%@)", (long)tag, command);
    });

    return YES;
}

- (BOOL)internalSendToCloud:(SingleTon *)socket command:(id)sender error:(NSError **)outError {
    DLog(@"%s: Waiting to enter sync block",__PRETTY_FUNCTION__);
    @synchronized (self.syncLocker) {
        DLog(@"%s: Entered sync block",__PRETTY_FUNCTION__);

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

        NSString *commandPayload;
        unsigned int commandLength = 0;
        unsigned int commandType = 0;
        NSData *sendCommandPayload;

        @try {
            switch (obj.commandType) {
                case LOGIN_COMMAND: {
                    /* Check if User is already logged in [ if he has received loginResponse command */
                    if (socket.isLoggedIn == YES) {
                        //Post Callback that you are logged in
                        LoginResponse *object = [[LoginResponse alloc] init];
                        object.isSuccessful = NO;
                        object.userID = nil;
                        object.tempPass = nil;
                        [object setReason:@"Already Loggedin"];

                        [self postData:LOGIN_NOTIFIER data:object];

                        return YES;
                    }
                    else {
                        Login *cmd = (Login *) obj.command;
                        commandType = (uint32_t) htonl(LOGIN_COMMAND);
                        commandPayload = [cmd toXml];
                        sendCommandPayload = [commandPayload dataUsingEncoding:NSUTF8StringEncoding];
                        commandLength = (uint32_t) htonl([sendCommandPayload length]);
                    }

                    break;
                }
                case LOGIN_TEMPPASS_COMMAND: {
                    // [SNLog Log:@"%s: Sending LOGIN_TEMPPASS_COMMAND",__PRETTY_FUNCTION__];
                    LoginTempPass *ob1 = (LoginTempPass *) obj.command;
                    commandPayload = [NSString stringWithFormat:LOGIN_REQUEST_XML, ob1.UserID, ob1.TempPass];

                    //Cloud has switch for both command as LOGIN_COMMAND
                    commandType = (uint32_t) htonl(LOGIN_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case LOGOUT_COMMAND: {
                    // [SNLog Log:@"%s: Sending LOGOUT COMMAND",__PRETTY_FUNCTION__];
//                    Logout *ob1 = (Logout *)obj.command;
                    commandPayload = LOGOUT_REQUEST_XML;
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    //Cloud has switch for both command as LOGIN_COMMAND
                    commandType = (uint32_t) htonl(LOGOUT_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    //PY 250214 - Logout Response will be received now
                    //Remove preferences
//                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//
//                    // [SNLog Log:@"%s: TempPass - %@ \n UserID - %@",__PRETTY_FUNCTION__,[prefs objectForKey:tmpPwdKey], [prefs objectForKey:usrIDKey]];
//                    [prefs removeObjectForKey:tmpPwdKey];
//                    [prefs removeObjectForKey:usrIDKey];
//                    [prefs synchronize];
//                    // [SNLog Log:@"%s: After delete\n",__PRETTY_FUNCTION__];
//                    // [SNLog Log:@"%s: TempPass - %@ \n UserID - %@",__PRETTY_FUNCTION__,[prefs objectForKey:tmpPwdKey], [prefs objectForKey:usrIDKey]];
//
//                    [socket setConnectionState:NOT_LOGGED_IN];
//
//                    //PY 160913 - Reconnect to cloud
//                    id ret = [[SecurifiToolkit sharedInstance] initSDKCloud];
//                    if (ret == nil)
//                    {
//                        // [SNLog Log:@"%s: APP Delegate : SDKInit Error",__PRETTY_FUNCTION__];
//                    }
//

                    break;
                }
                case SIGNUP_COMMAND: {
                    // [SNLog Log:@"%s: Sending SIGNUP Command",__PRETTY_FUNCTION__];
                    Signup *ob1 = (Signup *) obj.command;
                    commandPayload = [NSString stringWithFormat:SIGNUP_REQUEST_XML, ob1.UserID, ob1.Password];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(SIGNUP_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case CLOUD_SANITY: {
                    // [SNLog Log:@"%s: Sending CLOUD_SANITY Command",__PRETTY_FUNCTION__];
                    commandPayload = CLOUDSANITY_REQUEST_XML;//[NSString stringWithFormat:CLOUDSANITY_REQUEST_XML];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(CLOUD_SANITY);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case AFFILIATION_CODE_REQUEST: {
                    // [SNLog Log:@"%s: Sending Affiliation Code request",__PRETTY_FUNCTION__];
                    AffiliationUserRequest *affiliationObj = (AffiliationUserRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:AFFILIATION_CODE_REQUEST_XML, affiliationObj.Code];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(AFFILIATION_CODE_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case LOGOUT_ALL_COMMAND: {
                    //PY 160913 - Logout all command
                    // [SNLog Log:@"%s: Sending Logout request",__PRETTY_FUNCTION__];
                    //            <root>
                    //            <LogoutAll>
                    //            <EmailID>validemail@mycompany.com</EmailID>
                    //            <Password>originalpassword</Password>
                    //            </LogoutAll>
                    //            </root>

                    LogoutAllRequest *logoutAllObj = (LogoutAllRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:LOGOUT_ALL_REQUEST_XML, logoutAllObj.UserID, logoutAllObj.Password];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(LOGOUT_ALL_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case ALMOND_LIST: {
                    //PY 160913 - almond list command
                    // [SNLog Log:@"%s: Sending almond list request",__PRETTY_FUNCTION__];
                    // <root></root>

                    //AlmondListRequest *logoutAllObj = (AlmondListRequest *)obj.command;
                    commandPayload = ALMOND_LIST_REQUEST_XML; //[NSString stringWithFormat:];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(ALMOND_LIST);


                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case DEVICEDATA_HASH: {
                    //PY 170913 - Device Hash command
                    // [SNLog Log:@"%s: Sending Device Hash request",__PRETTY_FUNCTION__];
                    //            <root><DeviceDataHash>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceDataHash></root>

                    DeviceDataHashRequest *deviceDataHashObj = (DeviceDataHashRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_DATA_HASH_REQUEST_XML, deviceDataHashObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(DEVICEDATA_HASH);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case DEVICEDATA: {
                    //PY 170913 - Device Data command
                    // [SNLog Log:@"%s: Sending Device Data request",__PRETTY_FUNCTION__];
                    //            <root><DeviceData>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceData></root>

                    DeviceListRequest *deviceDataObj = (DeviceListRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_DATA_REQUEST_XML, deviceDataObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(DEVICEDATA);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case DEVICE_VALUE: {
                    //PY 190913 - Device Value command
                    // [SNLog Log:@"%s: Sending DeviceValue request",__PRETTY_FUNCTION__];
                    //            <root><DeviceValue>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceValue></root>

                    DeviceValueRequest *deviceValueObj = (DeviceValueRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_VALUE_REQUEST_XML, deviceValueObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(DEVICE_VALUE);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case MOBILE_COMMAND: {
                    //PY 200913 - Mobile command
                    // [SNLog Log:@"%s: Sending MobileCommand request",__PRETTY_FUNCTION__];
                    /* <root><MobileCommand>
                     * <AlmondplusMAC>251176214925585</AlmondplusMAC>
                     * <Device ID=”6”>
                     * <NewValue Index=”1”>NewTextValue</NewValue>
                     * </Device>
                     * <MobileInternalIndex>324</MobileInternalIndex>
                     * </MobileCommand></root>
                     */

                    MobileCommandRequest *mobileCommandObj = (MobileCommandRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:MOBILE_COMMAND_REQUEST_XML, mobileCommandObj.almondMAC, mobileCommandObj.deviceID, mobileCommandObj.indexID, mobileCommandObj.changedValue, mobileCommandObj.internalIndex];
                    DLog(@"Command length %lu", (unsigned long) [commandPayload length]);


                    //PY 290114: Replacing the \" (backslash quotes) in the string to just " (quotes).
                    //When we are using string obfuscation the decoded string has the \ escape character with it.
                    //The cloud is unable to handle it and rejects the command.
                    //Add this line to any XML  string with has \" in it. For example: <Device ID=\"%@\">
                    commandPayload = [self stringByRemovingEscapeCharacters:commandPayload];

                    commandType = (uint32_t) htonl(MOBILE_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    DLog(@"Payload Command length %lu", (unsigned long) [sendCommandPayload length]);
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case GENERIC_COMMAND_REQUEST: {
                    //PY 291013 - Generic command
//                    <root>
//                    <GenericCommandRequest>
//                    <AlmondplusMAC>251176214925585</AlmondplusMAC>
//                    <ApplicationID></ApplicationID>
//                    <MobileInternalIndex>1</MobileInternalIndex>
//                    <Data>
//                    [Base64Encoded]
//                    <root><Reboot>1</Reboot></root>[Base64Encoded]
//                    </Data>
//                    </GenericCommandRequest>
//                    </root>
                    // [SNLog Log:@"%s: Sending GenricCommand request",__PRETTY_FUNCTION__];

                    GenericCommandRequest *genericCommandObj = (GenericCommandRequest *) obj.command;

                    //Encode data to Base64
                    NSData *dataToEncode = [genericCommandObj.data dataUsingEncoding:NSUTF8StringEncoding];
                    NSData *encodedData = [dataToEncode base64EncodedDataWithOptions:0];
                    NSString *encodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];

                    commandPayload = [NSString stringWithFormat:GENERIC_COMMAND_REQUEST_XML, genericCommandObj.almondMAC, genericCommandObj.applicationID, genericCommandObj.mobileInternalIndex, encodedString];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(GENERIC_COMMAND_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                    //PY 011113 - Reactivation email command
                case VALIDATE_REQUEST: {
                    // [SNLog Log:@"%s: Sending VALIDATE request",__PRETTY_FUNCTION__];
                    /*
                     <root>
                     <ValidateAccountRequest>
                     <EmailID>xyz@abc.com</EmailID>
                     </ValidateAccountRequest>
                     </root>
                     */

                    ValidateAccountRequest *validateObj = (ValidateAccountRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:VALIDATE_REQUEST_XML, validateObj.email];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(VALIDATE_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case RESET_PASSWORD_REQUEST: {
                    // [SNLog Log:@"%s: Sending RESET_PASSWORD request",__PRETTY_FUNCTION__];
                    /*
                     <root>
                     <ResetPasswordRequest>
                     <EmailID>xyz@abc.com</EmailID>
                     </ResetPasswordRequest>
                     </root>
                     */

                    ResetPasswordRequest *resetPwdObj = (ResetPasswordRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:RESET_PWD_REQUEST_XML, resetPwdObj.email];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(RESET_PASSWORD_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                    //PY 150114 - Forced Data Update
                case DEVICE_DATA_FORCED_UPDATE_REQUEST: {
                    // [SNLog Log:@"%s: Sending DEVICE_DATA_FORCED_UPDATE_REQUEST request",__PRETTY_FUNCTION__];
                    /*
                    <root><DeviceDataForcedUpdate>
                    <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    <MobileInternalIndex>1234</MobileInternalIndex>
                    </DeviceDataForcedUpdate></root>
                     */

                    SensorForcedUpdateRequest *forcedUpdateObj = (SensorForcedUpdateRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:SENSOR_FORCED_UPDATE_REQUEST_XML, forcedUpdateObj.almondMAC, forcedUpdateObj.mobileInternalIndex];
                    //commandLength = (uint32_t)htonl([commandPayload length]);


                    //Send as Command 61
                    commandType = (uint32_t) htonl(MOBILE_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case SENSOR_CHANGE_REQUEST: {
                    SensorChangeRequest *cmd = (SensorChangeRequest *) obj.command;

                    commandPayload = [cmd toXml];
                    commandType = (uint32_t) htonl(MOBILE_COMMAND);
                    sendCommandPayload = [commandPayload dataUsingEncoding:NSUTF8StringEncoding];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }

                default:
                    break;
            }
            //isLoggedin might be set to 1 if we miss the TCP termination callback
            //Check on each write if it fails set isLoggedin to

            DLog(@"@Payload being sent: %@", commandPayload);

            NSStreamStatus type;
            do {
                type = [socket.outputStream streamStatus];
                // [SNLog Log:@"%s: Socket in opening state.. wait..",__PRETTY_FUNCTION__];
            } while (type == NSStreamStatusOpening);

            if (socket.isStreamConnected) {
                [socket.outputStream streamStatus];
            }

            // [SNLog Log:@"%s: Out of stream type check loop : %d",__PRETTY_FUNCTION__,type];

            if (socket.isStreamConnected && socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [socket.outputStream write:(uint8_t *) &commandLength maxLength:4]) {
                    socket.isLoggedIn = NO;
                    socket.sendCommandFail = YES;
                    socket.isStreamConnected = NO;

                    *outError = [self makeError:@"Securifi Payload - Send Error"];

                    return NO;
                }
            }

            //stream status
            if (socket.isStreamConnected && socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [socket.outputStream write:(uint8_t *) &commandType maxLength:4]) {
                    socket.isLoggedIn = NO;
                    socket.sendCommandFail = YES;
                    socket.isStreamConnected = NO;

                    *outError = [self makeError:@"Securifi Payload - Send Error"];

                    return NO;
                }
            }

            if (socket.isStreamConnected && socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [socket.outputStream write:[sendCommandPayload bytes] maxLength:[sendCommandPayload length]]) {
                    socket.isLoggedIn = NO;
                    socket.sendCommandFail = YES;
                    socket.isStreamConnected = NO;

                    *outError = [self makeError:@"Securifi Payload - Send Error"];

                    return NO;
                }
            }

            DLog(@"%s: Exiting sync block",__PRETTY_FUNCTION__);

            if (socket.outputStream == nil) {
                DLog(@"%s: Output stream is nil, out=%@", __PRETTY_FUNCTION__, socket.outputStream);
                return NO;
            }
            else if (!socket.isStreamConnected) {
                DLog(@"%s: Output stream is not connected, out=%@", __PRETTY_FUNCTION__, socket.outputStream);
                return NO;
            }
            else if (socket.outputStream.streamStatus == NSStreamStatusError) {
                DLog(@"%s: Output stream has error status, out=%@", __PRETTY_FUNCTION__, socket.outputStream);
                return NO;
            }
            else {
                DLog(@"%s: sent command to cloud: TIME => %f ", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                return YES;
            }
        }
        @catch (NSException *e) {
            NSLog(@"%s: Exception : %@",__PRETTY_FUNCTION__, e.reason);
            @throw;
        }
    }//synchronized

}

- (NSString *)stringByRemovingEscapeCharacters:(NSString *)inputString {
    NSMutableString *s = [NSMutableString stringWithString:inputString];
    [s replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    //[s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

- (NSError*)makeError:(NSString*)description {
    NSDictionary *details = @{NSLocalizedDescriptionKey : description};
    return [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];
}


@end

