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
#import "SecurifiConfigurator.h"

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

                                    const CommandType commandType = temp.commandType;
                                    switch (commandType) {
                                        case CommandType_LOGIN_RESPONSE: {
                                            LoginResponse *obj = (LoginResponse *) temp.command;
                                            [self markLoggedInState:obj.isSuccessful];
                                            [self tryMarkUnitCompletion:obj.isSuccessful responseType:commandType];
                                            [self postData:LOGIN_NOTIFIER data:obj];
                                            break;
                                        }

                                        case CommandType_SIGNUP_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:SIGN_UP_NOTIFIER data:temp.command];
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
                                            [self postData:LOGOUT_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case CommandType_LOGOUT_ALL_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:LOGOUT_ALL_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case CommandType_AFFILIATION_USER_COMPLETE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
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
                                        case CommandType_ALMOND_LIST_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:ALMOND_LIST_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case CommandType_DEVICE_DATA_HASH_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:DEVICEDATA_HASH_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case CommandType_DEVICE_DATA_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:DEVICE_DATA_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case CommandType_DEVICE_VALUE_LIST_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:DEVICE_VALUE_LIST_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case CommandType_MOBILE_COMMAND_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:MOBILE_COMMAND_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case CommandType_DYNAMIC_DEVICE_DATA: {
                                            [self postDataDynamic:DYNAMIC_DEVICE_DATA_NOTIFIER data:temp.command commandType:commandType];
                                            break;
                                        }
                                        case CommandType_DYNAMIC_DEVICE_VALUE_LIST: {
                                            [self postDataDynamic:DYNAMIC_DEVICE_VALUE_LIST_NOTIFIER data:temp.command commandType:commandType];
                                            break;
                                        }
                                        case CommandType_GENERIC_COMMAND_RESPONSE: {
                                            GenericCommandResponse *obj = (GenericCommandResponse *) temp.command;
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            obj.decodedData = decodedData;

                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:GENERIC_COMMAND_NOTIFIER data:obj];
                                            break;
                                        }
                                        case CommandType_GENERIC_COMMAND_NOTIFICATION: {
                                            GenericCommandResponse *obj = (GenericCommandResponse *) temp.command;

                                            //Decode using Base64
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            obj.decodedData = decodedData;

//                                            [self tryMarkUnitCompletion:YES responseType:GENERIC_COMMAND_NOTIFICATION];
                                            [self postData:GENERIC_COMMAND_CLOUD_NOTIFIER data:obj];

                                            break;
                                        }
                                        case CommandType_VALIDATE_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:VALIDATE_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case CommandType_RESET_PASSWORD_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:RESET_PWD_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case CommandType_DYNAMIC_ALMOND_ADD: {
                                            [self postDataDynamic:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER data:temp.command commandType:commandType];
                                            break;
                                        }
                                        case CommandType_DYNAMIC_ALMOND_DELETE: {
                                            [self postDataDynamic:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER data:temp.command commandType:commandType];
                                            break;
                                        }
                                        case CommandType_SENSOR_CHANGE_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:SENSOR_CHANGE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case CommandType_DYNAMIC_ALMOND_NAME_CHANGE: {
                                            [self postDataDynamic:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER data:temp.command commandType:commandType];
                                            break;
                                        }
                                            
                                            //PY 150914 - Account Settings
                                        case CommandType_USER_PROFILE_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:USER_PROFILE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_CHANGE_PASSWORD_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:CHANGE_PWD_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case CommandType_DELETE_ACCOUNT_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:DELETE_ACCOUNT_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_UPDATE_USER_PROFILE_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:UPDATE_USER_PROFILE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_ALMOND_AFFILIATION_DATA_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:ALMOND_AFFILIATION_DATA_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_UNLINK_ALMOND_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:UNLINK_ALMOND_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_USER_INVITE_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:USER_INVITE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_DELETE_SECONDARY_USER_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:DELETE_SECONDARY_USER_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_ALMOND_NAME_CHANGE_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:ALMOND_NAME_CHANGE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_ME_AS_SECONDARY_USER_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:ME_AS_SECONDARY_USER_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_DELETE_ME_AS_SECONDARY_USER_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:DELETE_ME_AS_SECONDARY_USER_NOTIFIER data:temp.command];
                                            break;
                                        }
                                           
                                            //TODO: PY121214 - Uncomment later when Push Notification is implemented on cloud
                                            //Push Notification - START
                                            /*
                                        case CommandType_NOTIFICATION_REGISTRATION_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:NOTIFICATION_REGISTRATION_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            
                                        case CommandType_NOTIFICATION_DEREGISTRATION_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:NOTIFICATION_DEREGISTRATION_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case CommandType_DYNAMIC_NOTIFICATION_PREFERENCE_LIST:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:DYNAMIC_NOTIFICATION_PREFERENCE_LIST_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE:{
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:NOTIFICATION_PREFERENCE_LIST_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE: {
                                            [self tryMarkUnitCompletion:YES responseType:commandType];
                                            [self postData:NOTIFICATION_PREFERENCE_CHANGE_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                             */
                                            //Push Notification - END
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

- (void)postData:(NSString *)notificationName data:(id)payload {
    // An interesting behavior: notifications are posted mainly to the UI. There is an assumption built into the system that
    // the notifications are posted synchronously from the SDK. Change the dispatch queue to async, and the
    // UI can easily become confused. This needs to be sorted out.
    SLog(@"Posting %@", notificationName);
    [self post:notificationName payload:payload queue:self.callbackQueue];
}

- (void)postDataDynamic:(NSString*)notificationName data:(id)payload commandType:(CommandType)commandType {
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
        default:break;
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
            default:break;
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
        [block_self.delegate singletTonDidSendCommand:block_self command:command];

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
                case CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST:
                {
                    id<SecurifiCommand> cmd = obj.command;
                    commandPayload = [cmd toXml];
                    break;
                }
                case CommandType_ALMOND_NAME_CHANGE_REQUEST:
                case CommandType_NOTIFICATION_PREF_CHANGE_REQUEST:
                case CommandType_DEVICE_DATA_FORCED_UPDATE_REQUEST: {
                    id<SecurifiCommand> cmd = obj.command;
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
                default:
                    break;
            }

            NSData *sendCommandPayload = [commandPayload dataUsingEncoding:NSUTF8StringEncoding];
            unsigned int commandLength = (unsigned int) htonl([sendCommandPayload length]);

            DLog(@"@Payload being sent: %@", commandPayload);

//            // Wait until socket is open
//            NSStreamStatus type;
//            do {
//                type = [socket.outputStream streamStatus];
//            } while (type == NSStreamStatusOpening);
//
//            if (socket.isStreamConnected) {
//                [socket.outputStream streamStatus];
//            }

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

- (NSError*)makeError:(NSString*)description {
    NSDictionary *details = @{NSLocalizedDescriptionKey : description};
    return [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];
}


@end

