//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "WebSocketEndpoint.h"
#import "GenericCommand.h"
#import "PSWebSocket.h"
#import "NetworkConfig.h"
#import "DeviceListResponse.h"
#import "AlmondPlusSDKConstants.h"


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
@property(nonatomic, readonly) dispatch_semaphore_t network_established_latch;
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
        _network_established_latch = dispatch_semaphore_create(0);
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

    if ([self waitForConnectionEstablishment:2]) {
        *outError = [self makeError:@"WebSocket: Timed out waiting for connection establishment"];
        return NO;
    }

    NSData *data = obj.command;
    NSString *json =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    [self.socket send:json];
    NSLog(@"Websocket send: %@", json);

    return YES;
}

- (NSError *)makeError:(NSString *)description {
    NSDictionary *details = @{NSLocalizedDescriptionKey : description};
    return [NSError errorWithDomain:@"WebSocket" code:201 userInfo:details];
}

#pragma mark - Semaphores

// Called during command process need to use the output stream. Blocks until the connection is set up or fails.
// return YES when time out is reached; NO if connection established without timeout
// On time out, the WebSocket will shut itself down
- (BOOL)waitForConnectionEstablishment:(int)numSecsToWait {
    dispatch_semaphore_t latch = self.network_established_latch;
    NSString *msg = @"WebSocket: Giving up on connection establishment";

    BOOL timedOut = [self waitOnLatch:latch timeout:numSecsToWait logMsg:msg];
    if (self.connectionState == WebSocketConnectionStatus_established) {
        // If the connection is up by now, no need to worry about the timeout.
        return NO;
    }
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
        if (self.connectionState == WebSocketConnectionStatus_uninitialized) {
            NSLog(@"%@. WebSocket is uniitialized.", msg);
            break;
        }
        if (self.connectionState == WebSocketConnectionStatus_shutting_down) {
            NSLog(@"%@. WebSocket is shutting down.", msg);
            break;
        }
        if (self.connectionState == WebSocketConnectionStatus_shutdown) {
            NSLog(@"%@. WebSocket was shutdown.", msg);
            break;
        }
        if (self.connectionState == WebSocketConnectionStatus_failed) {
            NSLog(@"%@. WebSocket is failed.", msg);
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

#pragma mark - State

- (BOOL)isStreamConnected {
    enum WebSocketEndpointConnectionStatus status = self.connectionState;

    switch (status) {
        case WebSocketConnectionStatus_connecting:
        case WebSocketConnectionStatus_established:
            return YES;

        case WebSocketConnectionStatus_uninitialized:
        case WebSocketConnectionStatus_failed:
        case WebSocketConnectionStatus_shutting_down:
        case WebSocketConnectionStatus_shutdown:
        default:
            return NO;
    }
}

- (void)markConnectionState:(enum WebSocketEndpointConnectionStatus)status {
    _connectionState = status;
}

#pragma mark - PSWebSocketDelegate methods

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    [self markConnectionState:WebSocketConnectionStatus_established];
    dispatch_semaphore_signal(self.network_established_latch);
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

    if ([commandType isEqualToString:@"setdeviceindex"]) {

    }
    else
    if ([commandType isEqualToString:@"devicelist"]) {
        DeviceListResponse *res = [DeviceListResponse parseJson:payload];
        NSString *mii = payload[@"mii"];
        NSRange range = [mii rangeOfString:@":"];
        res.almondMAC = [mii substringToIndex:range.location];
        [self.delegate networkEndpoint:self dispatchResponse:res commandType:CommandType_DEVICE_LIST_AND_VALUES_RESPONSE];
    }
}

- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self markConnectionState:WebSocketConnectionStatus_failed];
    dispatch_semaphore_signal(self.network_established_latch);
    [self.delegate networkEndpointDidDisconnect:self];
    NSLog(@"The websocket did fial with error: %@", error.description);
}

- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    enum WebSocketEndpointConnectionStatus status = wasClean ? WebSocketConnectionStatus_shutdown : WebSocketConnectionStatus_failed;
    [self markConnectionState:status];

    dispatch_semaphore_signal(self.network_established_latch);
    [self.delegate networkEndpointDidDisconnect:self];

    NSLog(@"The websocket closed with code: %@, reason: %@, wasClean: %@", @(code), reason, (wasClean) ? @"YES" : @"NO");
}

@end