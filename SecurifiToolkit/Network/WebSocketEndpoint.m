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
@property(nonatomic, strong) PSWebSocket *socket_mesh;

@property(nonatomic, strong) NetworkConfig *config;
@property(nonatomic, readonly) NSDictionary *responseHandlers;
@property BOOL isMesh;
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
    self.isMesh = NO;
    NSString *login = config.login;
    NSString *password = config.password;
    NSString *host = config.host;
    NSLog(@"connect - login: %@, password: %@, host: %@", config.login, config.password, config.host);
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

-(void)connectMesh{
    NSLog(@"connect mesh");
    NetworkConfig *config = self.config;
    self.isMesh = YES;
    NSString *login = config.login;
    NSString *password = config.password;
    NSString *host = config.host;
    NSInteger meshPort = 7682;
    NSLog(@"connect - login: %@, password: %@, host: %@, %ld", config.login, config.password, config.host, config.port);
    if (!host || !login || !password) {
        [self.delegate networkEndpointDidDisconnect:self];
        return;
    }
    
    password = [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // ws://192.168.1.102:7681/<password>
    NSString *connect_str_mesh = [NSString stringWithFormat:@"ws://%@:%lu/%@/%@", host, (unsigned long) meshPort, login, password];
    NSLog(@"connect_str_mesh: %@", connect_str_mesh);
    NSURL *url_mesh = [NSURL URLWithString:connect_str_mesh];
    
    if (!url_mesh){
        NSLog(@"disconnect disconnected");
        [self.delegate networkEndpointDidDisconnect:self];
        return;
    }
    
    NSURLRequest *request_mesh = [NSURLRequest requestWithURL:url_mesh];

    self.socket_mesh = [PSWebSocket clientSocketWithRequest:request_mesh];
    self.socket_mesh.delegate = self;
    
    [self.socket_mesh open];
}
- (void)shutdown {
    NSLog(@"websocket shutDown");
    [self.socket close];
    [self.socket_mesh close];
}

- (BOOL)sendCommand:(GenericCommand *)obj error:(NSError **)outError {
    NSData *data = obj.command;
    if(obj.isMesh)
        [self.socket_mesh send:data];
    else
        [self.socket send:data];


    if([data isKindOfClass:[NSData class]])
        NSLog(@"Websocket send: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    else
        NSLog(@"websocket send: %@", data);
    return YES;
}

#pragma mark - PSWebSocketDelegate methods
- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"webSocketDidOpen");
    if(self.isMesh){
        return;
    }
    [self connectMesh];
    
    [self.delegate networkEndpointDidConnect:self];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
//    [toolkit cleanUp];
    
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    [toolkit asyncSendToLocal:[GenericCommand requestSensorDeviceList:plus.almondplusMAC] almondMac:plus.almondplusMAC];
    [toolkit asyncSendToLocal:[GenericCommand requestAlmondClients:plus.almondplusMAC] almondMac:plus.almondplusMAC];
    [toolkit asyncSendToLocal:[GenericCommand requestSceneList:plus.almondplusMAC] almondMac:plus.almondplusMAC];
    [toolkit asyncSendToLocal:[GenericCommand requestAlmondRules:plus.almondplusMAC] almondMac:plus.almondplusMAC];   
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
             //meshcommands
             @"SlaveDetails" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_MESH_COMMAND];
             },
             @"CheckForAddableWiredSlave" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_MESH_COMMAND];
             },
             @"CheckForAddableWirelessSlave" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_MESH_COMMAND];
             },
             @"AddWiredSlave" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_MESH_COMMAND];
             },
             @"AddWirelessSlave" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_MESH_COMMAND];
             },
             @"BlinkLed" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_MESH_COMMAND];
             },
             @"SetSlaveName" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_MESH_COMMAND];
             },
             //new device commands
             @"DeviceList" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicDeviceAdded" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicDeviceUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicDeviceRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicAllDevicesRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicIndexUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"UpdateDeviceIndex" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"UpdateDeviceName" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             //rules
             @"RuleList" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicRuleAdded" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicRuleRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicAllRulesRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicRuleUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES];
             },
            
             @"AddRule" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RESPONSE];
             },
             @"UpdateRule" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RESPONSE];
             },
             
             @"RemoveRule" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_RULE_COMMAND_RESPONSE];
             },
             
             //Client
             @"DynamicAllClientsRemoved":^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicClientRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicClientUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicClientAdded" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicClientLeft" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"DynamicClientJoined" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"ClientList" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES];
             },
             @"UpdateClient" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"RemoveClient" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             //scenes
             @"DynamicSceneList" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES];
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
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES];
             },
             
             @"DynamicSceneActivated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES];
             },
             
             @"DynamicSceneUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES];
             },
             
             @"DynamicSceneRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES];
             },
             
             @"DynamicAllScenesRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES];
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
//             @"updatealmondmode" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
//                 AlmondModeChangeResponse *res = [AlmondModeChangeResponse parseJson:payload];
//                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_ALMOND_MODE_CHANGE_RESPONSE];
//             },
             @"DynamicAlmondModeUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DynamicAlmondModeChange *res = [DynamicAlmondModeChange parseJson:payload];
                 res.almondMAC = endpoint.config.almondMac;
                 
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DYNAMIC_ALMOND_MODE_CHANGE];
                 NSLog(@"DynamicAlmondModeUpdated ");
//                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_DYNAMIC_ALMOND_MODE_CHANGE];
             },
//             @"AlmondModeUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
//                 DynamicAlmondModeChange *res = [DynamicAlmondModeChange parseJson:payload];
//                 res.almondMAC = endpoint.config.almondMac;
//                 
//                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DYNAMIC_ALMOND_MODE_CHANGE];
//             },
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
             @"DynamicAlmondNameUpdated":  ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 DynamicAlmondNameChangeResponse *res = [DynamicAlmondNameChangeResponse new];
                 res.almondplusMAC = endpoint.config.almondMac;
                 res.almondplusName = payload[@"Name"];
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DYNAMIC_ALMOND_NAME_CHANGE];
             },
             };
}

@end