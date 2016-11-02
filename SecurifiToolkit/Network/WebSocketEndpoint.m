//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "WebSocketEndpoint.h"
#import "GenericCommand.h"
//#import "PSWebSocket.h"
#import "SRWebSocket.h"
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

@interface WebSocketEndpoint () <SRWebSocketDelegate>
@property(nonatomic, strong) SRWebSocket *socket;
@property(nonatomic, strong) SRWebSocket *socket_mesh;

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

- (void)connect{
    NSLog(@"connect websocket");
    self.socket = [self connectSocketToPort:self.config.port];
}

-(void)connectMesh{
    NSLog(@"connect mesh");
    self.socket_mesh = [self connectSocketToPort:7682];
}

-(SRWebSocket *)connectSocketToPort:(NSUInteger)almondPort{
    NSLog(@"connect almond socket");
    NetworkConfig *config = self.config;
    NSString *login = config.login;
    NSString *password = config.password;
    NSString *host = config.host;
    NSLog(@" logiconnect -n: %@, password: %@, host: %@, port: %d", config.login, config.password, config.host, almondPort);
    if (!host || !login || !password) {
        [self.delegate networkEndpointDidDisconnect:self];
        return nil;
    }
    
    password = [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // ws://192.168.1.102:7681/<password>
    NSString *connect_str = [NSString stringWithFormat:@"ws://%@:%lu/%@/%@", host, (unsigned long) almondPort, login, password];
    NSLog(@"connected_str: %@", connect_str);
    NSURL *url = [NSURL URLWithString:connect_str];
    if (!url) {
        [self.delegate networkEndpointDidDisconnect:self];
        return nil;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    SRWebSocket *almondSocket = [[SRWebSocket alloc]initWithURLRequest:request];
    almondSocket.delegate = self;
    
    [almondSocket open];
    return almondSocket;
}


- (void)shutdown {
    NSLog(@"websocket shutDown");
    [self.socket close];
    [self.socket_mesh close];
    [self.delegate networkEndpointDidDisconnect:self];
}

- (void)shutdownMesh {
    NSLog(@"Mesh websocket shutdown");
    //ismesh NO will be set on delegate response
    GenericCommand *cmd = [GenericCommand requestRai2DownMobile:nil];
    [self.socket_mesh send:cmd.command];
    [self.socket_mesh close];
}

- (BOOL)sendCommand:(GenericCommand *)obj error:(NSError **)outError {
    if(obj==nil || obj.command==nil)
        return NO;
    NSData *data = obj.command;
    //logs
    if([data isKindOfClass:[NSData class]]){
        NSLog(@"Websocket send: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }else{
        NSLog(@"websocket send: %@", data);
    }
    if(![data isKindOfClass:[NSData class]] && ![data isKindOfClass:[NSString class]]){
        return NO;
    }
    
    if(obj.isMeshCmd)
        [self.socket_mesh send:data];
    else
        [self.socket send:data];
    
    return YES;
}

#pragma mark - SRWebSocketDelegate methods
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"webSocketDidOpen");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    if([webSocket isEqual:self.socket_mesh]){
        [toolkit asyncSendToNetwork:[GenericCommand requestRai2UpMobile:nil]];
        return;
    }
    
    [self.delegate networkEndpointDidConnect:self];
    [toolkit asyncSendToNetwork:[GenericCommand websocketAlmondNameAndMac]];
//    SFIAlmondPlus *plus = [toolkit currentAlmond];
//    [toolkit asyncSendToNetwork:[GenericCommand requestSensorDeviceList:plus.almondplusMAC] ];
//    [toolkit asyncSendToNetwork:[GenericCommand requestAlmondClients:plus.almondplusMAC] ];
//    [toolkit asyncSendToNetwork:[GenericCommand requestSceneList:plus.almondplusMAC] ];
//    [toolkit asyncSendToNetwork:[GenericCommand requestAlmondRules:plus.almondplusMAC]];
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
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


- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    if([webSocket isEqual:self.socket_mesh]){
        //need to work on logic
        NSLog(@"mesh web socket did fail: %@", webSocket);
        return;
    }
    NSLog(@"The websocket did fail with error: %@, socket: %@", error.description, webSocket);
        
    [self.delegate networkEndpointDidDisconnect:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    if([webSocket isEqual:self.socket_mesh]){
        //need to work on logic
        NSLog(@"mesh websocket did close");
        return;
    }
    NSLog(@"The websocket closed with code: %@, reason: %@, wasClean: %@, socket: %@", @(code), reason, (wasClean) ? @"YES" : @"NO", webSocket);
    [self.delegate networkEndpointDidDisconnect:self];
}

- (NSDictionary *)buildResponseHandlers {
    return @{
             @"RouterSummary" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
             },
             //meshcommands
             @"Rai2UpMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
            
             @"Rai2DownMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"SlaveDetailsMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"CheckForAddableWiredSlaveMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"CheckForAddableWirelessSlaveMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"AddWiredSlaveMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_MESH_COMMAND];
             },
             @"AddWirelessSlaveMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_MESH_COMMAND];
             },
             @"DynamicAddWiredSlaveMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"DynamicAddWirelessSlaveMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"BlinkLedMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"SetSlaveNameMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"RemoveSlaveMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
             },
             @"ForceRemoveSlaveMobile" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:payload commandType:CommandType_COMMAND_RESPONSE];
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
//             @"DeviceUpdated" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
//                 DeviceListResponse *res = [DeviceListResponse parseJson:payload];
//                 res.type = DeviceListResponseType_updated;
//                 res.updatedDevicesOnly = YES;
//                 res.almondMAC = endpoint.config.almondMac;
//                 
//                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
//             },
//             @"DeviceAdded" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
//                 DeviceListResponse *res = [DeviceListResponse parseJson:payload];
//                 res.updatedDevicesOnly = YES;
//                 res.type = DeviceListResponseType_websocket_added;
//                 res.almondMAC = endpoint.config.almondMac;
//                 
//                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
//             },
//             @"DeviceRemoved" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
//                 DeviceListResponse *res = [DeviceListResponse parseJson:payload];
//                 res.updatedDevicesOnly = YES;
//                 res.type = DeviceListResponseType_removed;
//                 res.almondMAC = endpoint.config.almondMac;
//                 
//                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
//             },
//             @"DeviceRemoveAll" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
//                 DeviceListResponse *res = [DeviceListResponse new];
//                 res.type = DeviceListResponseType_removed_all;
//                 res.almondMAC = endpoint.config.almondMac;
//                 
//                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
//             },
//             @"devicelist" : ^void(WebSocketEndpoint *endpoint, NSDictionary *payload) {
//                 DeviceListResponse *res = [DeviceListResponse parseJson:payload];
//                 res.almondMAC = self.config.almondMac;
//                 res.type = DeviceListResponseType_deviceList;
//                 [endpoint.delegate networkEndpoint:endpoint dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
//             },
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

-(void)setAlmondNameAndMAC:(NSString *)mac{
    self.config.almondMac=mac;
}

@end
