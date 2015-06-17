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


typedef NS_ENUM(unsigned int, WebSocketEndpointConnectionStatus) {
    WebSocketConnectionStatus_uninitialized = 1,
    WebSocketConnectionStatus_connecting,
    WebSocketConnectionStatus_established,
    WebSocketConnectionStatus_failed,
    WebSocketConnectionStatus_shutting_down,
    WebSocketConnectionStatus_shutdown,
};

@interface WebSocketEndpoint () <PSWebSocketDelegate>
@property(nonatomic, strong) PSWebSocket *socket;
@property(nonatomic, strong) NetworkConfig *config;
@property(nonatomic, readonly) enum WebSocketEndpointConnectionStatus connectionState;
@end

@implementation WebSocketEndpoint

+ (instancetype)endpointWithConfig:(NetworkConfig *)config {
    return [[self alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(NetworkConfig *)config {
    self = [super init];
    if (self) {
        self.config = config;
        [self markConnectionState:WebSocketConnectionStatus_uninitialized];
    }

    return self;
}

- (void)connect {
    if (self.connectionState != WebSocketConnectionStatus_uninitialized) {
        return;
    }
    [self markConnectionState:WebSocketConnectionStatus_connecting];

    NetworkConfig *config = self.config;

    // ws://192.168.1.102:7681/<password>
    NSString *connect_str = [NSString stringWithFormat:@"ws://%@:%lu/%@", config.host, config.port, config.password];
    NSURL *url = [NSURL URLWithString:connect_str];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    // create the socket and assign delegate
    self.socket = [PSWebSocket clientSocketWithRequest:request];
    self.socket.delegate = self;

    NSLog(@"The websocket will open");
    [self.socket open];
}

- (void)shutdown {
    [self markConnectionState:WebSocketConnectionStatus_shutting_down];
    [self.socket close];
}

- (BOOL)sendCommand:(GenericCommand *)obj error:(NSError **)outError {
    switch (self.connectionState) {
        case WebSocketConnectionStatus_uninitialized:
            *outError = [self makeError:@"Wrong Connection state: uninitialized"];
            return NO;
        case WebSocketConnectionStatus_failed:
            *outError = [self makeError:@"Wrong Connection state: failed"];
            return NO;
        case WebSocketConnectionStatus_shutting_down:
            *outError = [self makeError:@"Wrong Connection state: shutting_down"];
            return NO;
        case WebSocketConnectionStatus_shutdown:
            *outError = [self makeError:@"Wrong Connection state: shutdown"];
            return NO;

        case WebSocketConnectionStatus_connecting:
        case WebSocketConnectionStatus_established:
            break;
    }

    NSData *data = obj.command;
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    [self.socket send:json];
    NSLog(@"Websocket send: %@", json);

    return YES;
}

- (NSError *)makeError:(NSString *)description {
    NSDictionary *details = @{NSLocalizedDescriptionKey : description};
    return [NSError errorWithDomain:@"WebSocket" code:201 userInfo:details];
}

#pragma mark - State

- (void)markConnectionState:(enum WebSocketEndpointConnectionStatus)status {
    _connectionState = status;
}

#pragma mark - PSWebSocketDelegate methods

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    [self markConnectionState:WebSocketConnectionStatus_established];
    [self.delegate networkEndpointDidConnect:self];
    NSLog(@"The websocket did open");
}

- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"The websocket received a message: %@", message);

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

    if ([commandType isEqualToString:@"SensorUpdate"]) {
        DeviceValueResponse *res = [DeviceValueResponse parseJson:payload];
        res.almondMAC = nil; //todo hack for now: signal that the local network almond should be used
        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_DYNAMIC_DEVICE_VALUE_LIST];
    }
    else if ([commandType isEqualToString:@"devicelist"]) {
        DeviceListResponse *res = [DeviceListResponse parseJson:payload];
        NSString *mii = payload[@"mii"];
        NSRange range = [mii rangeOfString:@":"];
        res.almondMAC = [mii substringToIndex:range.location];
        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
    }
}

- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self markConnectionState:WebSocketConnectionStatus_failed];
    [self.delegate networkEndpointDidDisconnect:self];
    NSLog(@"The websocket did fail with error: %@", error.description);
}

- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    enum WebSocketEndpointConnectionStatus status = wasClean ? WebSocketConnectionStatus_shutdown : WebSocketConnectionStatus_failed;
    [self markConnectionState:status];

    [self.delegate networkEndpointDidDisconnect:self];

    NSLog(@"The websocket closed with code: %@, reason: %@, wasClean: %@", @(code), reason, (wasClean) ? @"YES" : @"NO");
}

@end