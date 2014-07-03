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

// Called by clients that need to use the output stream. Blocks until the connection is set up or fails.
// return YES when time out is reached; NO if connection established without timeout
// On time out, the SingleTon will shut itself down
- (BOOL)waitForConnectionEstablishment:(int)numSecsToWait;

// Sends the specified command to the cloud
// Returns YES on successful sending
// Returns NO on failure to send
- (BOOL)sendCommandToCloud:(id)command error:(NSError **)outError;

@end
