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

// Queues the specified command to the cloud
// Returns YES on successful submission
// Returns NO on failure to queue
- (BOOL)submitCommand:(GenericCommand*)command;

@end
