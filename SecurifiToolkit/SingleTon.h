//
//  SingleTon.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Base64.h"

@interface SingleTon : NSObject <NSStreamDelegate>
{
    /*
     UInt32 deviceid;
     NSInputStream   *inputStream;
     NSOutputStream  *outputStream;
     */
    NSMutableData *partialData;

    dispatch_queue_t backgroundQueue;
}
//@property BOOL isBusy;
@property BOOL isLoggedin;
@property unsigned int expectedLength,totalReceivedLength, command;
@property UInt32 deviceid;
@property (nonatomic, retain) NSInputStream  *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property BOOL disableNetworkDownNotification;
@property BOOL isStreamConnected;
@property BOOL sendCommandFail;
@property SecCertificateRef certificate;

@property NSInteger connectionState;

@property dispatch_queue_t backgroundQueue;

+(SingleTon *)createSingletonObj;
+(void)removeSingletonObject;
+(SingleTon *)getObject;

-(void)reconnect;
-(void)scheduleInCurrentThread:(id)unused;


@end
