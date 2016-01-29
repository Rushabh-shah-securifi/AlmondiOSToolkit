//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "WebSocketEndpoint.h"
#import "GenericCommand.h"
#import "PSWebSocket.h"
#import "NetworkConfig.h"
#import "DeviceListResponse.h"
#import "DeviceValueResponse.h"
#import "AlmondModeChangeResponse.h"
#import "SFIDevicesList.h"
#import "SFIGenericRouterCommand.h"
#import "DynamicAlmondModeChange.h"
#import "DynamicAlmondNameChangeResponse.h"
#import "SecurifiToolkit.h"
#import "GenericCommand.h"

typedef void (^WebSocketResponseHandler)(WebSocketEndpoint *, NSDictionary *);

@interface WebSocketEndpoint () <PSWebSocketDelegate>
@property(nonatomic, strong) PSWebSocket *socket;
@property(nonatomic, strong) NetworkConfig *config;
@property(nonatomic, readonly) NSDictionary *responseHandlers;
@end

@implementation WebSocketEndpoint

+ (instancetype)endpointWithConfig:(NetworkConfig *)config {
    return [[self alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(NetworkConfig *)config {
    self = [super init];
    if (self) {
        self.config = [config copy];
        _responseHandlers = [self buildResponseHandlers];
    }
    
    return self;
}

- (void)connect {
    NetworkConfig *config = self.config;
    
    NSString *login = config.login;
    NSString *password = config.password;
    NSString *host = config.host;
    
    if (!host || !login || !password) {
        [self.delegate networkEndpointDidDisconnect:self];
        return;
    }
    
    password = [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // ws://192.168.1.102:7681/<password>
    NSString *connect_str = [NSString stringWithFormat:@"ws://%@:%lu/%@/%@", host, (unsigned long) config.port, login, password];
    NSURL *url = [NSURL URLWithString:connect_str];
    if (!url) {
        [self.delegate networkEndpointDidDisconnect:self];
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    self.socket = [PSWebSocket clientSocketWithRequest:request];
    self.socket.delegate = self;
    
    [self.socket open];
}

- (void)shutdown {
    [self.socket close];
}

- (BOOL)sendCommand:(GenericCommand *)obj error:(NSError **)outError {
    NSLog(@"send command: %@", obj);
    NSData *data = obj.command;
    [self.socket send:data];
    //    NSLog(@"Websocket send: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return YES;
}

-(void)requestForSceneList{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    GenericCommand *cmd = [GenericCommand websocketRequestAlmondSceneList];
    [[SecurifiToolkit sharedInstance] asyncSendToLocal:cmd almondMac:plus.almondplusMAC];
}

#pragma mark - PSWebSocketDelegate methods

- (void)requestForWiFiClientList{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    NSLog(@" my almond mac %@ %@ %@",toolkit, plus.almondplusMAC,plus.almondplusName);
    GenericCommand *cmd = [GenericCommand websocketRequestAlmondWifiClients:plus.almondplusMAC];
    [toolkit asyncSendToLocal:cmd almondMac:plus.almondplusMAC];
}

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    [self.delegate networkEndpointDidConnect:self];
    [self requestForWiFiClientList];
    [self requestForRuleList];
    [self requestForSceneList];
    NSLog(@" rewuest for rule is send");
}

-(void)requestForRuleList{
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    GenericCommand *cmd = [GenericCommand websocketRequestAlmondRules];
    [[SecurifiToolkit sharedInstance] asyncSendToLocal:cmd almondMac:plus.almondplusMAC];
}

- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Websocket receive: %@", message);
    
    NSString *str = message;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"Error decoding websocket message: %@", error);
        return;
    }
    
    NSDictionary *payload = obj;
    
    NSString *commandType = payload[@"commandtype"];
    if (commandType.length == 0) {
        commandType = payload[@"CommandType"];
    }
    if (commandType.length == 0) {
        NSLog(@"No command type specified for payload: %@", payload);
        return;
    }
    
    WebSocketResponseHandler handler = self.responseHandlers[commandType];
    if (handler) {
        handler(self, payload);
    }
    else {
        NSLog(@"Unsupported command: %@", str);
    }
}

- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    [self.delegate networkEndpointDidDisconnect:self];
    NSLog(@"The websocket did fail with error: %@", error.description);
}

- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self.delegate networkEndpointDidDisconnect:self];
    NSLog(@"The websocket closed with code: %@, reason: %@, wasClean: %@", @(code), reason, (wasClean) ? @"YES" : @"NO");
}

- (NSDictionary *)buildResponseHandlers {
    return @{
             @"RemoveAllRules" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RULLCHANGED];
             },
             @"RuleRemoveAll" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_DYNAMICDELETEALL];
             },
             
             @"RuleUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RULLCHANGED];
             },
             @"RuleUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RULLCHANGED];
             },
             
             @"RuleRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RULLCHANGED];
             },
             @"DynamicRuleAdded" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_DYNAMICADD];
             },
             @"RuleAdded" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {// adding just gor getting rulId in savedRuleController
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RULLCHANGED];
             },
             @"AddRule" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RESPONSE];
             },
             @"UpdateRule" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RESPONSE];
             },
             
             @"RemoveRule" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RESPONSE];
             },
             //rules
             @"RuleList" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 
                 
                 NSLog(@"websocket payload ruleList: %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_LIST_RESPONSE];
             },
             //rules
             @"DynamicClientRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_CLIENT_REMOVE_REQUEST];
             },
             @"DynamicClientUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_CLIENT_UPDATE_REQUEST];
             },
             @"DynamicClientAdded" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_CLIENT_ADD_REQUEST];
             },
             @"DynamicClientLeft" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_CLIENT_LEFT_REQUEST];
             },
             @"DynamicClientJoined" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_CLIENT_JOIN_REQUEST];
             },
             @"UpdateClient" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"websocket payload : %@", payload);
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"ClientList" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 NSLog(@"ClientList");
                 
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_WIFI_CLIENTS_LIST_RESPONSE];
             },
             
             @"DynamicSceneList" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_GET_ALL_SCENES];
             },
             
             @"AddScene" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             
             @"ActivateScene" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             
             @"UpdateScene" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             
             @"RemoveScene" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             
             @"DynamicSceneAdded" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
             },
             
             @"DynamicSceneActivated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
             },
             
             @"DynamicSceneUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
             },
             
             @"DynamicSceneRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
             },
             
             @"DynamicAllScenesRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
             },
             
             @"SensorUpdate" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DeviceValueResponse *res = [DeviceValueResponse parseJson:payload];
                 res.almondMAC = endpoint.config.almondMac;
                 
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DYNAMIC_DEVICE_VALUE_LIST];
             },
             @"DeviceUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DeviceListResponse *res = [DeviceListResponse parseJson:payload];
                 res.type = DeviceListResponseType_updated;
                 res.updatedDevicesOnly = YES;
                 res.almondMAC = endpoint.config.almondMac;
                 
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
             },
             @"DeviceAdded" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DeviceListResponse *res = [DeviceListResponse parseJson:payload];
                 res.updatedDevicesOnly = YES;
                 res.type = DeviceListResponseType_websocket_added;
                 res.almondMAC = endpoint.config.almondMac;
                 
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
             },
             @"DeviceRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DeviceListResponse *res = [DeviceListResponse parseJson:payload];
                 res.updatedDevicesOnly = YES;
                 res.type = DeviceListResponseType_removed;
                 res.almondMAC = endpoint.config.almondMac;
                 
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
             },
             @"DeviceRemoveAll" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DeviceListResponse *res = [DeviceListResponse new];
                 res.type = DeviceListResponseType_removed_all;
                 res.almondMAC = endpoint.config.almondMac;
                 
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
             },
             @"devicelist" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DeviceListResponse *res = [DeviceListResponse parseJson:payload];
                 res.almondMAC = self.config.almondMac;
                 res.type = DeviceListResponseType_deviceList;
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
             },
             @"updatealmondmode" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 AlmondModeChangeResponse *res = [AlmondModeChangeResponse parseJson:payload];
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_ALMOND_MODE_CHANGE_RESPONSE];
             },
             @"AlmondModeUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DynamicAlmondModeChange *res = [DynamicAlmondModeChange parseJson:payload];
                 res.almondMAC = endpoint.config.almondMac;
                 
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DYNAMIC_ALMOND_MODE_CHANGE];
             },
             @"ClientsList" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 SFIDevicesList *res = [SFIDevicesList parseJson:payload];
                 
                 SFIGenericRouterCommand *cmd = [SFIGenericRouterCommand new];
                 cmd.almondMAC = endpoint.config.almondMac;
                 cmd.commandSuccess = YES;
                 cmd.commandType = SFIGenericRouterCommandType_CONNECTED_DEVICES;
                 cmd.command = res;
                 
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:cmd commandType:CommandType_ALMOND_COMMAND_RESPONSE];
             },
             @"GetAlmondNameandMAC" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 // just send back raw dictionary for now
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_ALMOND_NAME_AND_MAC_RESPONSE];
             },
             @"AlmondNameUpdated":  ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DynamicAlmondNameChangeResponse *res = [DynamicAlmondNameChangeResponse new];
                 res.almondplusMAC = endpoint.config.almondMac;
                 res.almondplusName = payload[@"Name"];
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DYNAMIC_ALMOND_NAME_CHANGE];
             },
             };
}

@end