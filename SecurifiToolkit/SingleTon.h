//
//  SingleTon.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SingleTon;

@protocol SingleTonDelegate

- (void)singletTonCloudConnectionDidClose:(SingleTon *)singleTon;

@end


@interface SingleTon : NSObject <NSStreamDelegate>

@property(weak, nonatomic) id <SingleTonDelegate> delegate;

@property BOOL disableNetworkDownNotification;

@property(nonatomic, strong) NSInputStream *inputStream;
@property(nonatomic, strong) NSOutputStream *outputStream;

@property NSInteger connectionState;
@property BOOL isStreamConnected;
@property BOOL isLoggedIn;
@property BOOL sendCommandFail;

+ (SingleTon *)newSingleton:(dispatch_queue_t)backgroundQueue;

- (void)shutdown;

@end
