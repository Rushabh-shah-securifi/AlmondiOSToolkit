//
//  SingleTon.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleTon : NSObject <NSStreamDelegate>

@property BOOL disableNetworkDownNotification;

@property(nonatomic, retain) NSInputStream *inputStream;
@property(nonatomic, retain) NSOutputStream *outputStream;

@property NSInteger connectionState;
@property BOOL isStreamConnected;
@property BOOL isLoggedIn;
@property BOOL sendCommandFail;

+ (SingleTon *)newSingleton:(dispatch_queue_t)backgroundQueue;

- (void)shutdown;

@end
