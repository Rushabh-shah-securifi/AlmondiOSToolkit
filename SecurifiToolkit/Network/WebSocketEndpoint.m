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


@interface WebSocketEndpoint () <PSWebSocketDelegate>
@property(nonatomic, strong) PSWebSocket *socket;
@property(nonatomic, strong) NetworkConfig *config;
@end

@implementation WebSocketEndpoint

+ (instancetype)endpointWithConfig:(NetworkConfig *)config {
    return [[self alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(NetworkConfig *)config {
    self = [super init];
    if (self) {
        self.config = [config copy];
    }

    return self;
}

- (void)connect {
    NetworkConfig *config = self.config;

    // ws://192.168.1.102:7681/<password>
    NSString *connect_str = [NSString stringWithFormat:@"ws://%@:%lu/%@", config.host, (unsigned long) config.port, config.password];
    NSURL *url = [NSURL URLWithString:connect_str];

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
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    [self.socket send:json];
    DLog(@"Websocket send: %@", json);

    return YES;
}

#pragma mark - PSWebSocketDelegate methods

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    [self.delegate networkEndpointDidConnect:self];
    DLog(@"Websocket did open");
}

- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    DLog(@"Websocket received a message: %@", message);

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

    if ([commandType isEqualToString:@"SensorUpdate"]) {
        DeviceValueResponse *res = [DeviceValueResponse parseJson:payload];
        res.almondMAC = self.config.almondMac;

        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_DYNAMIC_DEVICE_VALUE_LIST];
    }
    else if ([commandType isEqualToString:@"DeviceUpdated"]) {
        DeviceListResponse *res = [DeviceListResponse parseJson:payload];
        res.type = DeviceListResponseType_updated;
        res.almondMAC = self.config.almondMac;

        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
    }
    else if ([commandType isEqualToString:@"DeviceAdded"]) {
        DeviceListResponse *res = [DeviceListResponse parseJson:payload];
        res.type = DeviceListResponseType_added;
        res.almondMAC = self.config.almondMac;

        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
    }
    else if ([commandType isEqualToString:@"DeviceRemoved"]) {
        DeviceListResponse *res = [DeviceListResponse parseJson:payload];
        res.type = DeviceListResponseType_removed;
        res.almondMAC = self.config.almondMac;

        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
    }
    else if ([commandType isEqualToString:@"DeviceRemoveAll"]) {
        DeviceListResponse *res = [DeviceListResponse new];
        res.type = DeviceListResponseType_removed_all;
        res.almondMAC = self.config.almondMac;

        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
    }
    else if ([commandType isEqualToString:@"devicelist"]) {
        DeviceListResponse *res = [DeviceListResponse parseJson:payload];
        res.almondMAC = self.config.almondMac;

        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
    }
    else if ([commandType isEqualToString:@"updatealmondmode"]) {
        AlmondModeChangeResponse *res = [AlmondModeChangeResponse parseJson:payload];
        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_ALMOND_MODE_CHANGE_RESPONSE];
    }
    else if ([commandType isEqualToString:@"ClientsList"]) {
        SFIDevicesList *res = [SFIDevicesList parseJson:payload];

        SFIGenericRouterCommand *cmd = [SFIGenericRouterCommand new];
        cmd.almondMAC = self.config.almondMac;
        cmd.commandSuccess = YES;
        cmd.commandType = SFIGenericRouterCommandType_CONNECTED_DEVICES;
        cmd.command = res;

        [self.delegate networkEndpoint:self dispatchResponse:cmd commandType:CommandType_ALMOND_COMMAND_RESPONSE];
    }
    else if ([commandType isEqualToString:@"GetAlmondNameandMAC"]) {
        // just send back raw dictionary for now
        [self.delegate networkEndpoint:self dispatchResponse:payload commandType:CommandType_ALMOND_NAME_AND_MAC_RESPONSE];
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

@end