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

- (void)singletTonDidReceiveDynamicUpdate:(SingleTon *)singleTon;
- (void)singletTonDidSendCommand:(SingleTon *)singleTon;
- (void)singletTonDidReceiveCommandResponse:(SingleTon *)singleTon;

- (void)singletTonCloudConnectionDidClose:(SingleTon *)singleTon;

@end


@interface SingleTon : NSObject <NSStreamDelegate>

@property(weak, nonatomic) id <SingleTonDelegate> delegate;

@property SDKCloudStatus connectionState;
@property BOOL isStreamConnected;
@property BOOL isLoggedIn;

// queue on which notifications will be posted
+ (SingleTon *)newSingletonWithResponseCallbackQueue:(dispatch_queue_t)callbackQueue dynamicCallbackQueue:(dispatch_queue_t)dynamicCallbackQueue;

- (void)initNetworkCommunication:(BOOL)useProductionCloud;

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

// Provides a way to flag that a Device List is being fetched.
// Used to prevent sending multiple same requests.
// Caller should call clearWillFetchDeviceListForAlmond: on receiving a reply
- (void)markWillFetchDeviceListForAlmond:(NSString *)aAlmondMac;

// Tests whether a Device List has been requested already.
// TRUE if requested. FALSE otherwise.
- (BOOL)willFetchDeviceListFetchedForAlmond:(NSString *)aAlmondMac;

// Clears the flag indicating that a Device List is being fetched
- (void)clearWillFetchDeviceListForAlmond:(NSString *)aAlmondMac;

// Provides a per-connection ledger for tracking Device Value List requests.
// A list is should be requested at least once per each connection, but it
// should not be requested repeatedly. This ledger helps manage the process.
- (void)markDeviceValuesFetchedForAlmond:(NSString *)aAlmondMac;

// Tests whether a Device Values List was requested already.
// TRUE if requested. FALSE otherwise.
- (BOOL)wasDeviceValuesFetchedForAlmond:(NSString *)aAlmondMac;

@end
