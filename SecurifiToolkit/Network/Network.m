//  Network.m
//  SecurifiToolkit
//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//


#import "Network.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SUnit.h"
#import "NetworkState.h"
#import "NetworkEndpoint.h"
#import "CloudEndpoint.h"
#import "NetworkConfig.h"
#import "WebSocketEndpoint.h"
#import "LoginResponse.h"

@interface Network () <NetworkEndpointDelegate>
@property(nonatomic, readonly) NetworkConfig *networkConfig;

@property(atomic) NSInteger currentUnitCounter;
@property(nonatomic) SUnit *currentUnit;

@property(nonatomic, readonly) dispatch_queue_t initializationQueue;    // serial queue to which network initialization commands submitted to the system are added
@property(nonatomic, readonly) dispatch_queue_t commandQueue;           // serial queue to which commands submitted to the system are added
@property(nonatomic, readonly) dispatch_queue_t callbackQueue;          // queue used for posting notifications
@property(nonatomic, readonly) dispatch_queue_t dynamicCallbackQueue;          // queue used for posting notifications
@property(nonatomic, readonly) dispatch_semaphore_t cloud_initialized_latch;

@property(nonatomic) BOOL networkUpNoticePosted;
@property(nonatomic) id <NetworkEndpoint> endpoint;

@end


@implementation Network

+ (instancetype)networkWithNetworkConfig:(NetworkConfig *)networkConfig callbackQueue:(dispatch_queue_t)callbackQueue dynamicCallbackQueue:(dispatch_queue_t)dynamicCallbackQueue {
    return [[self alloc] initWithNetworkConfig:networkConfig callbackQueue:callbackQueue dynamicCallbackQueue:dynamicCallbackQueue];
}

- (instancetype)initWithNetworkConfig:(NetworkConfig *)networkConfig callbackQueue:(dispatch_queue_t)callbackQueue dynamicCallbackQueue:(dispatch_queue_t)dynamicCallbackQueue {
    self = [super init];
    if (self) {
        _networkConfig = networkConfig;
        _callbackQueue = callbackQueue;
        _dynamicCallbackQueue = dynamicCallbackQueue;

        [self markConnectionState:NetworkConnectionStatusUninitialized];
        self.loginStatus = NetworkLoginStatusNotLoggedIn;

        _initializationQueue = dispatch_queue_create("cloud_init_command_queue", DISPATCH_QUEUE_SERIAL);
        _cloud_initialized_latch = dispatch_semaphore_create(0);

        _commandQueue = dispatch_queue_create("command_queue", DISPATCH_QUEUE_SERIAL);
        _networkState = [NetworkState new];
    }

    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"endpoint=%@", self.endpoint];
    [description appendString:@">"];
    return description;
}

- (void)connect {
    NSLog(@"Initialzing network communication");

    [self markConnectionState:NetworkConnectionStatusInitializing];

    if (self.endpoint) {
        return;
    }

    NetworkConfig *config = self.networkConfig;
    if (config.mode == NetworkEndpointMode_cloud) {
        self.endpoint = [CloudEndpoint endpointWithConfig:config];
    }
    else {
        self.endpoint = [WebSocketEndpoint endpointWithConfig:config];
    }
    
    self.endpoint.delegate = self;
    [self.endpoint connect];
}

- (void)shutdown {
    NSLog(@"Shutting down network Network");

    if (!self.endpoint) {
        return;
    }

    NSLog(@"[%@] Network is shutting down", self.debugDescription);

    // Signal shutdown
    //
    [self markConnectionState:NetworkConnectionStatusShutdown];
    [self markLoggedInState:NO];

    // Clean up command queue
    //
    [self tryAbortUnit];
    dispatch_semaphore_signal(self.cloud_initialized_latch);

    [self.endpoint shutdown];
    self.endpoint = nil;

    // Tell delegate of shutdown
    [self.delegate networkConnectionDidClose:self];
}

#pragma mark - Semaphores

// Called by commands submitted to the normal command queue that have to wait for the cloud initialization
// sequence to complete. Like network establishment procedures, this process can time out in which case the
// Network is shutdown.
- (BOOL)waitForCloudInitialization:(int)numSecsToWait {
    dispatch_semaphore_t latch = self.cloud_initialized_latch;
    NSString *msg = @"Giving up on endpoint initialization";

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
        if (self.connectionState == NetworkConnectionStatusShutdown) {
            NSLog(@"%@. Network was shutdown.", msg);
            break;
        }
        if (self.connectionState == NetworkConnectionStatusInitialized) {
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

#pragma mark - state

- (BOOL)isStreamConnected {
    NetworkConnectionStatus status = self.connectionState;
    return (status == NetworkConnectionStatusInitialized) || (status == NetworkConnectionStatusInitializing);
}

- (void)markConnectionState:(enum NetworkConnectionStatus)status {
    _connectionState = status;
}

- (void)markLoggedInState:(BOOL)loggedIn {
    self.loginStatus = loggedIn ? NetworkLoginStatusLoggedIn : NetworkLoginStatusNotLoggedIn;
}

#pragma mark - NSStreamDelegate methods

- (void)tryMarkUnitCompletion:(BOOL)success responseType:(CommandType)responseType {
    SUnit *unit = self.currentUnit;

    if (unit) {
        [unit markResponse:success];
        [self.delegate networkDidReceiveCommandResponse:self command:unit.command timeToCompletion:unit.timeToCompletionSuccess responseType:responseType];
        DLog(@"Marking response %i for unit: %@", responseType, unit.description);
    }
    else {
        [self.delegate networkDidReceiveCommandResponse:self command:nil timeToCompletion:0 responseType:responseType];
    }
}

- (void)tryAbortUnit {
    SUnit *unit = self.currentUnit;

    if (unit) {
        DLog(@"Marking unit as aborted: %@", unit.description);
        [unit abort];
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
    [self.delegate networkDidReceiveDynamicUpdate:self commandType:commandType];
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


#pragma mark - Command submission

- (NSInteger)nextUnitCounter {
    NSInteger next = self.currentUnitCounter + 1;
    self.currentUnitCounter = next;
    return next;
}

- (void)markCloudInitialized {
    NetworkConnectionStatus cloudStatus = self.connectionState;
    if (cloudStatus == NetworkConnectionStatusInitialized) {
        return;
    }
    if (cloudStatus == NetworkConnectionStatusShutdown) {
        return;
    }

    // There may be other commands in the initialization queue still waiting for responses.
    // Let them complete or timeout before opening up the main command queue.
    // Therefore, queue a command to make the state change and start the main queue's processing.

    NSLog(@"Queuing cloud initialization completed command");

    __weak Network *block_self = self;
    dispatch_async(self.initializationQueue, ^() {
        NetworkConnectionStatus status = block_self.connectionState;
        if (status == NetworkConnectionStatusInitialized) {
            return;
        }
        if (status == NetworkConnectionStatusShutdown) {
            return;
        }

        [block_self markConnectionState:NetworkConnectionStatusInitialized];

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
    if (self.connectionState == NetworkConnectionStatusInitialized) {
        NSLog(@"Rejected cloud initialization command submission: already marked as initialized");
//        return NO; //todo fix me.
    }

    dispatch_queue_t queue = self.initializationQueue;
    BOOL waitForInit = NO;
    return [self internalSubmitCommand:command queue:queue waitForNetworkInitializedLatch:waitForInit waitAtMostSecs:5];
}

- (BOOL)submitCommand:(GenericCommand *)command {
    dispatch_queue_t queue = self.commandQueue;
    BOOL waitForInit = YES;

    if (!self.isStreamConnected) {
        return NO;
    }

    switch (self.connectionState) {
        case NetworkConnectionStatusUninitialized:
        case NetworkConnectionStatusShutdown:
            // don't even queue; just get out
            return NO;

        case NetworkConnectionStatusInitialized:
            waitForInit = NO;
            break;

        case NetworkConnectionStatusInitializing:
            break;
    }

    return [self internalSubmitCommand:command queue:queue waitForNetworkInitializedLatch:waitForInit waitAtMostSecs:0];
}

// we manage two different queues, one for initializing the network, and one for normal network operation.
// this mechanism allows the initialization logic to be determined by the toolkit as responses are returned.
// when initializing, the normal command queue blocks on the network_initialized_latch semaphore
- (BOOL)internalSubmitCommand:(GenericCommand *)command queue:(dispatch_queue_t)queue waitForNetworkInitializedLatch:(BOOL)waitForNetworkInitializedLatch waitAtMostSecs:(int)waitAtMostSecs {
    if (!self.isStreamConnected) {
        DLog(@"SubmitCommand failed: network is shutdown");
        return NO;
    }

    DLog(@"Command Queue: queueing command: %@, wait:%@", command, waitForNetworkInitializedLatch ? @"YES" : @"NO");

    __weak Network *block_self = self;
    dispatch_async(queue, ^() {
        if (!block_self.isStreamConnected) {
            SLog(@"Command Queue: aborting unit: network is shutdown");
            return;
        }
        if (waitForNetworkInitializedLatch) {
            int const timeOutSecs = 10;
            [block_self waitForCloudInitialization:timeOutSecs];
        }
        if (!block_self.isStreamConnected) {
            SLog(@"Command Queue: aborting unit: network is shutdown");
            return;
        }

        NSInteger tag = [block_self nextUnitCounter];

        SUnit *unit = [[SUnit alloc] initWithCommand:command];
        [unit markWorking:tag];
        block_self.currentUnit = unit;

        SLog(@"Command Queue: sending %ld (%@)", (long) tag, command);

        NSError *error;
        BOOL success = [block_self.endpoint sendCommand:command error:&error];
        if (!success) {
            NSLog(@"Command Queue: send error, command:%@, error:%@, tag:%ld", command, error.description, (long) tag);
            [unit markResponse:NO];
            return;
        }
        [block_self.delegate networkDidSendCommand:block_self command:command];

        SLog(@"Command Queue: waiting for response: %ld (%@)", (long) tag, command);

//        int const waitAtMostSecs = 1;
        [unit waitForResponse:waitAtMostSecs];

        SLog(@"Command Queue: done waiting for response: %ld (%@)", (long) tag, command);
    });

    return YES;
}

#pragma mark - NetworkEndpointDelegate methods

- (void)networkEndpointWillStartConnecting:(id <NetworkEndpoint>)endpoint {
    [self postData:NETWORK_CONNECTING_NOTIFIER data:nil];
}

- (void)networkEndpointDidConnect:(id <NetworkEndpoint>)endpoint {
    if (self.networkConfig.mode == NetworkEndpointMode_web_socket) {
        [self markConnectionState:NetworkConnectionStatusInitialized];
    }
    else {
        if (!self.networkUpNoticePosted) {
            [self.delegate networkConnectionDidEstablish:self];
            self.networkUpNoticePosted = YES;
            [self postData:NETWORK_UP_NOTIFIER data:nil];
        }
    }
}

- (void)networkEndpointDidDisconnect:(id <NetworkEndpoint>)endpoint {
    [self markConnectionState:NetworkConnectionStatusShutdown];
    [self.delegate networkConnectionDidClose:self];
}

- (void)networkEndpoint:(id <NetworkEndpoint>)endpoint dispatchResponse:(id)payload commandType:(enum CommandType)commandType {
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

        case CommandType_DEVICE_LIST_AND_VALUES_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:DEVICE_LIST_AND_VALUES_NOTIFIER data:payload];
        };

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
        case CommandType_DEVICELOG_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:DEVICELOG_LIST_SYNC_RESPONSE_NOTIFIER data:payload];
            break;
        };

        case CommandType_ALMOND_COMMAND_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:ALMOND_COMMAND_RESPONSE_NOTIFIER data:payload];
            break;
        };

        default:
            break;
    }
}


@end

