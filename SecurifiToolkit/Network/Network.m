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
#import "WebSocketEndpoint.h"
#import "ConnectionStatus.h"
#import "KeyChainAccess.h"

@interface Network () <NetworkEndpointDelegate>
@property(nonatomic, readonly) NetworkConfig *networkConfig;

@property(atomic) NSInteger currentUnitCounter;
@property(nonatomic) SUnit *currentUnit;

@property(nonatomic, readonly) dispatch_queue_t commandQueue;           // serial queue to which commands submitted to the system are added
@property(nonatomic, readonly) dispatch_queue_t callbackQueue;          // queue used for posting notifications
@property(nonatomic, readonly) dispatch_queue_t dynamicCallbackQueue;          // queue used for posting notifications


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
        NSLog(@" Who is setting status Network - initWithNetworkConfig");
        [ConnectionStatus setConnectionStatusTo:(ConnectionStatusType)NO_NETWORK_CONNECTION];
        self.loginStatus = NetworkLoginStatusNotLoggedIn;
        
        _commandQueue = dispatch_queue_create("command_queue", DISPATCH_QUEUE_SERIAL);
        _networkState = [NetworkState new];
    }
    
    return self;
}

- (NetworkConfig *)config {
    return [self.networkConfig copy];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"endpoint=%@", self.endpoint];
    [description appendString:@">"];
    return description;
}

- (void)connect {
    NSLog(@"Initialzing network communication");
    NSLog(@" Who is setting status Network - connect");
    [ConnectionStatus setConnectionStatusTo:(ConnectionStatusType)IS_CONNECTING_TO_NETWORK];
    NSLog(@"connecting to the network");
    
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

- (void)connectMesh{
    if(self.endpoint && [self.endpoint isKindOfClass:[WebSocketEndpoint class]]){
        [self.endpoint connectMesh];
    }
}

- (void)shutdownMesh{
    if(self.endpoint && [self.endpoint isKindOfClass:[WebSocketEndpoint class]]){
        [self.endpoint shutdownMesh];
    }
}

- (void)shutdown{
    NSLog(@"Shutdowing Network");
    if (!self.endpoint) {
        return;
    }
    
    [self markLoggedInState:NO];
    
    [self tryAbortUnit];
    [self.endpoint shutdown];
    self.endpoint = nil;
    [self.delegate networkConnectionDidClose:self];
}

#pragma mark - state

- (enum NetworkEndpointMode)mode {
    return _networkConfig.mode;
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
    [self.delegate networkDidReceiveDynamicUpdate:self response:payload responseType:commandType];
}

- (void)delegateData:(id)payload commandType:(CommandType)commandType {
    __weak Network *block_self = self;
    NSLog(@"delegate data is called");
    dispatch_sync(self.callbackQueue, ^() {
        [block_self.delegate networkDidReceiveResponse:block_self response:payload responseType:commandType];
    });
}

- (void)delegateDataDynamic:(id)payload commandType:(CommandType)commandType {
    __weak Network *block_self = self;
    dispatch_sync(self.dynamicCallbackQueue, ^() {
        [block_self.delegate networkDidReceiveDynamicUpdate:block_self response:payload responseType:commandType];
    });
}

- (void)post:(NSString *)notificationName payload:(id)payload queue:(dispatch_queue_t)queue {
    __weak id block_payload = payload;
    __weak id block_self = self;
    NSDictionary *data = nil;
    if (payload) {
        data = @{
                 @"data" : block_payload,
                 @"network" : block_self,
                 };
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:data];
}


#pragma mark - Command submission

- (NSInteger)nextUnitCounter {
    NSInteger next = self.currentUnitCounter + 1;
    self.currentUnitCounter = next;
    return next;
}


// we manage two different queues, one for initializing the network, and one for normal network operation.
// this mechanism allows the initialization logic to be determined by the toolkit as responses are returned.
// when initializing, the normal command queue blocks on the network_initialized_latch semaphore
- (BOOL)submitCommand:(GenericCommand *)command {
    
    dispatch_async(self.commandQueue, ^() {
        
        BOOL success = [self.endpoint sendCommand:command error:nil];
        [self.delegate networkDidSendCommand:self command:command];
        
    });
    
    return YES;
}

#pragma mark - NetworkEndpointDelegate methods

- (void)networkEndpointWillStartConnecting:(id <NetworkEndpoint>)endpoint {
    NSLog(@" Who is setting status Network - networkEndpointWillStartConnecting");
    [ConnectionStatus setConnectionStatusTo:(ConnectionStatusType*)IS_CONNECTING_TO_NETWORK];
}

- (void)networkEndpointDidConnect:(id <NetworkEndpoint>)endpoint {
    NSLog(@" Who is setting status Network - networkEndpointDidConnect");
    [ConnectionStatus setConnectionStatusTo:(ConnectionStatusType)CONNECTED_TO_NETWORK];
    if([[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local)
        [ConnectionStatus setConnectionStatusTo:(ConnectionStatusType)AUTHENTICATED];
    
    self.networkUpNoticePosted = YES;
    }


- (void)networkEndpointDidDisconnect:(id <NetworkEndpoint>)endpoint {
    NSLog(@" Who is setting status Network - networkEndpointDidDisconnect");
    [self.delegate networkConnectionDidClose:self];
}


- (void)networkEndpoint:(id <NetworkEndpoint>)endpoint dispatchResponse:(id)payload commandType:(enum CommandType)commandType {
    switch (commandType) {
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
            
        case CommandType_AFFILIATION_USER_COMPLETE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:AFFILIATION_COMPLETE_NOTIFIER data:payload];
            break;
        }
            
        case CommandType_MOBILE_COMMAND_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:MOBILE_COMMAND_NOTIFIER data:payload];
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
        case CommandType_SENSOR_CHANGE_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:SENSOR_CHANGE_NOTIFIER data:payload];
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
            [self delegateData:payload commandType:commandType];
            // fix me: some UI code still dependent on this notification
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
            
        case CommandType_GET_ALL_SCENES: {
            //md01
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_GET_ALL_SCENES_NOTIFIER data:payload];
            break;
        };
        case CommandType_COMMAND_RESPONSE: {
            //md01
            NSLog(@"network normal command response");
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER data:payload];
            break;
        };
        case CommandType_MESH_COMMAND: {
            NSLog(@"network mesh command response");
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_COMMAND_TYPE_MESH_RESPONSE data:payload];
            break;
        }
        case CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE: {
            [self postDataDynamic:NOTIFICATION_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE_NOTIFIER data:payload commandType:commandType];
            break;
        };
        case CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_WIFI_CLIENT_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER data:payload];
            break;
        };
        case CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_SCENE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER data:payload];
            break;
        };
        case CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_RULE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER data:payload];
            break;
        };
        case CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST: {
            //md01
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_WIFI_CLIENT_GET_PREFERENCE_REQUEST_NOTIFIER data:payload];
            break;
        };
        case CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST: {
            //md01
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST_NOTIFIER data:payload];
            break;
        };
        case CommandType_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE: {
            //md01
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE_NOTIFIER data:payload];
            break;
        };
            
            //rules
        case CommandType_RULE_LIST: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:RULE_LIST_NOTIFIER data:payload];
            break;
        };
            
        case CommandType_RULE_COMMAND_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:RULE_COMMAND_RESPONSE_NOTIFIER data:payload];
            break;
        };
        case CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER data:payload];
            break;
        };
        case CommandType_NOTIFICATION_PREF_CHANGE_DYNAMIC_RESPONSE:{
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_CommandType_NOTIFICATION_PREF_CHANGE_DYNAMIC_RESPONSE data:payload];
            break;
        };
        case CommandType_DYNAMIC_ALMOND_MODE_CHANGE:{
            [self tryMarkUnitCompletion:YES responseType:commandType];
            //            .s
            NSLog(@"CommandType_DYNAMIC_ALMOND_MODE_CHANGE");
            [self delegateData:payload commandType:commandType];
            //            [self postData:kSFIAlmondModeDidChange data:payload];
            break;
        };
        case CommandType_ROUTER_COMMAND_REQUEST_RESPONSE: {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self postData:NOTIFICATION_ROUTER_RESPONSE_NOTIFIER data:payload];
            break;
        };
            
        case CommandType_DYNAMIC_ALMOND_ADD:
        case CommandType_DYNAMIC_ALMOND_DELETE:
        case CommandType_DYNAMIC_ALMOND_NAME_CHANGE:
            
        case CommandType_DYNAMIC_DEVICE_DATA:
        case CommandType_DYNAMIC_DEVICE_VALUE_LIST:
        case CommandType_DYNAMIC_NOTIFICATION_PREFERENCE_LIST:
        {
            [self delegateDataDynamic:payload commandType:commandType];
            break;
        };
            
            // =========================
            
        case CommandType_LOGIN_RESPONSE: {
            LoginResponse *obj = (LoginResponse *) payload;
            [self markLoggedInState:obj.isSuccessful];
            // pass through to normal handler below
        };
            
        case CommandType_LOGOUT_RESPONSE:
        case CommandType_LOGOUT_ALL_RESPONSE:
        case CommandType_ALMOND_LIST_RESPONSE:
        case CommandType_DEVICE_DATA_HASH_RESPONSE:
        case CommandType_DEVICE_DATA_RESPONSE:
        case CommandType_DEVICE_LIST_AND_VALUES_RESPONSE:
        case CommandType_DEVICE_VALUE_LIST_RESPONSE:
        case CommandType_GENERIC_COMMAND_RESPONSE:
        case CommandType_GENERIC_COMMAND_NOTIFICATION:
        case CommandType_ALMOND_NAME_CHANGE_RESPONSE:
        case CommandType_ALMOND_MODE_RESPONSE:
        case CommandType_NOTIFICATION_DEREGISTRATION_RESPONSE:
        case CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE:
        case CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE:
        case CommandType_NOTIFICATIONS_SYNC_RESPONSE:
        case CommandType_NOTIFICATIONS_COUNT_RESPONSE:
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE:
        case CommandType_DEVICELOG_RESPONSE:
        case CommandType_ALMOND_COMMAND_RESPONSE:
        case CommandType_ALMOND_NAME_AND_MAC_RESPONSE: // posted from web socket only; payload is dictionary
        {
            [self tryMarkUnitCompletion:YES responseType:commandType];
            [self delegateData:payload commandType:commandType];
            break;
        }
            
            // =========================
            
        default:
            break;
    }
}

@end
