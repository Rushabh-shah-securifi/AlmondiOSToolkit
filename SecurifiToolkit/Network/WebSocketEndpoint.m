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

    NSString *password = config.password;
    NSString *host = config.host;

    if (!host || !password) {
        [self.delegate networkEndpointDidDisconnect:self];
        return;
    }

    password = [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    // ws://192.168.1.102:7681/<password>
    NSString *connect_str = [NSString stringWithFormat:@"ws://%@:%lu/%@", host, (unsigned long) config.port, password];
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
    NSData *data = obj.command;

    [self.socket send:data];
    NSLog(@"Websocket send: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    return YES;
}

#pragma mark - PSWebSocketDelegate methods

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    [self.delegate networkEndpointDidConnect:self];
    DLog(@"Websocket did open");
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
                res.type = DeviceListResponseType_added;
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
    };
}

@end