//
//  SingleTon.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleTon : NSObject <NSStreamDelegate>

@property BOOL isLoggedin;
@property(nonatomic, retain) NSInputStream *inputStream;
@property(nonatomic, retain) NSOutputStream *outputStream;
@property unsigned int command;
@property unsigned int expectedLength;
@property unsigned int totalReceivedLength;
@property UInt32 deviceid;
@property BOOL disableNetworkDownNotification;
@property BOOL isStreamConnected;
@property BOOL sendCommandFail;

@property NSInteger connectionState;

+ (void)createSingletonObj;
+ (SingleTon *)getObject;
+ (void)removeSingletonObject;
- (void)reconnect;

@end
