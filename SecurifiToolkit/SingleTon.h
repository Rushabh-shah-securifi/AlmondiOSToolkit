//
//  SingleTon.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SDKCloudStatus) {
    SDKCloudStatusUninitialized = 1,
    SDKCloudStatusInitializing,
    SDKCloudStatusNetworkDown,
    SDKCloudStatusNotLoggedIn,
    SDKCloudStatusLoginInProcess,
    SDKCloudStatusLoggedIn,
    SDKCloudStatusInitialized,
    SDKCloudStatusCloudConnectionShutdown,
};

@class SingleTon;
@class GenericCommand;

@protocol SingleTonDelegate

- (void)singletTonCloudConnectionDidClose:(SingleTon *)singleTon;

@end


@interface SingleTon : NSObject <NSStreamDelegate>

@property(weak, nonatomic) id <SingleTonDelegate> delegate;

@property SDKCloudStatus connectionState;
@property BOOL isStreamConnected;
@property BOOL isLoggedIn;

// queue on which notifications will be posted
+ (SingleTon *)newSingleton:(dispatch_queue_t)callbackQueue;

- (void)initNetworkCommunication;

- (void)shutdown;

// Queues the specified command to the cloud. This is a special command queue that is used for initializing the singleton.
- (BOOL)submitCloudInitializationCommand:(GenericCommand*)command;

// After all initialization has been completed, this method MUST BE CALLED for normal command processing to start
- (void)markCloudInitialized;

// Queues the specified command to the cloud
// Returns YES on successful submission
// Returns NO on failure to queue
- (BOOL)submitCommand:(GenericCommand*)command;

// Provides a per-connection ledger for tracking Device Hash requests.
// A Hash is requested for a current Almond on each connection because
// the state could have changed while the app was not connected to the cloud.
- (void)markHashFetchedForAlmond:(NSString *)aAlmondMac;

// Tests whether a Hash was requested already.
// TRUE if requested. FALSE otherwise.
- (BOOL)wasHashFetchedForAlmond:(NSString *)aAlmondMac;

@end
