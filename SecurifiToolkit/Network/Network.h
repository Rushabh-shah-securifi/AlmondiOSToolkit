//
//  Network.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandTypes.h"
#import "SecurifiTypes.h"

typedef NS_ENUM(NSUInteger, SDKConnectionStatus) {
    SDKConnectionStatusUninitialized = 1,
    SDKConnectionStatusInitializing,
    SDKConnectionStatusInitialized,
    SDKConnectionStatusShutdown,
};

typedef NS_ENUM(NSUInteger, SDKLoginStatus) {
    SDKLoginStatusNotLoggedIn = 1,
    SDKLoginStatusInProcess,
    SDKLoginStatusLoggedIn,
};

@class Network;
@class GenericCommand;
@class SecurifiConfigurator;
@class NetworkState;
@class NetworkConfig;

@protocol NetworkDelegate

- (void)networkConnectionDidEstablish:(Network *)Network;

- (void)networkConnectionDidClose:(Network *)Network;

- (void)networkDidReceiveDynamicUpdate:(Network *)Network commandType:(enum CommandType)type;

- (void)networkDidSendCommand:(Network *)Network command:(GenericCommand *)command;

- (void)networkDidReceiveCommandResponse:(Network *)Network command:(GenericCommand *)cmd timeToCompletion:(NSTimeInterval)roundTripTime responseType:(enum CommandType)type;

@end


@interface Network : NSObject

@property(nonatomic, weak) id <NetworkDelegate> delegate;

@property(nonatomic, readonly) NetworkState *networkState;
@property(nonatomic, readonly) enum SDKConnectionStatus connectionState;
@property(nonatomic, readonly) BOOL isStreamConnected;
@property(nonatomic) enum SDKLoginStatus loginStatus;

// queue on which notifications will be posted
+ (instancetype)networkWithNetworkConfig:(NetworkConfig *)networkConfig callbackQueue:(dispatch_queue_t)callbackQueue dynamicCallbackQueue:(dispatch_queue_t)dynamicCallbackQueue;

// Initializes and opens the connection. This method must be called before submitting work.
- (void)connect;

- (void)shutdown;

// Queues the specified command to the cloud. This is a special command queue that is used for initializing the Network.
- (BOOL)submitCloudInitializationCommand:(GenericCommand *)command;

// After all initialization has been completed, this method MUST BE CALLED for normal command processing to start
- (void)markCloudInitialized;

// Queues the specified command to the cloud
// Returns YES on successful submission
// Returns NO on failure to queue
- (BOOL)submitCommand:(GenericCommand *)command;

- (NSString *)description;

@end
