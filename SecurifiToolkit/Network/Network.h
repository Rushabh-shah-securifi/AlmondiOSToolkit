//
//  Network.h
//  SecurifiToolkit
//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandTypes.h"
#import "SecurifiTypes.h"
#import "NetworkConfig.h"

typedef NS_ENUM(NSUInteger, NetworkConnectionStatus) {
    NetworkConnectionStatusUninitialized = 1,
    NetworkConnectionStatusInitializing,
    NetworkConnectionStatusInitialized,
    NetworkConnectionStatusShutdown,
};

typedef NS_ENUM(NSUInteger, NetworkLoginStatus) {
    NetworkLoginStatusNotLoggedIn = 1,
    NetworkLoginStatusInProcess,
    NetworkLoginStatusLoggedIn,
};

@class Network;
@class GenericCommand;
@class SecurifiConfigurator;
@class NetworkState;

@protocol NetworkDelegate

- (void)networkConnectionDidEstablish:(Network *)network;

- (void)networkConnectionDidClose:(Network *)network;

- (void)networkDidReceiveDynamicUpdate:(Network *)network commandType:(enum CommandType)type;

- (void)networkDidSendCommand:(Network *)network command:(GenericCommand *)command;

- (void)networkDidReceiveCommandResponse:(Network *)network command:(GenericCommand *)cmd timeToCompletion:(NSTimeInterval)roundTripTime responseType:(enum CommandType)type;

@end


@interface Network : NSObject

@property(nonatomic, weak) id <NetworkDelegate> delegate;

// Indicates whether the config is for a Cloud connection or web socket connection
@property(readonly) enum NetworkEndpointMode mode;
@property(nonatomic, readonly) NetworkState *networkState;
@property(nonatomic, readonly) enum NetworkConnectionStatus connectionState;
@property(nonatomic, readonly) BOOL isStreamConnected;
@property(nonatomic) enum NetworkLoginStatus loginStatus;

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

- (NetworkConfig *)config;

- (NSString *)description;

@end
