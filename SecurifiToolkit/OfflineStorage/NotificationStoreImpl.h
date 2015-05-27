//
// Created by Matthew Sinclair-Day on 2/11/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFINotificationStore.h"
#import "SecurifiTypes.h"

@class ZHDatabase;


@interface NotificationStoreImpl : NSObject <SFIDeviceLogStore>

// SFINotificationStore init
- (instancetype)initWithDb:(ZHDatabase *)db queue:(dispatch_queue_t)queue;

// SFIDeviceLogStore init
- (instancetype)initWithDb:(ZHDatabase *)db queue:(dispatch_queue_t)queue almondMac:(NSString *)almondMac deviceID:(sfi_id)deviceID;

// SFIDeviceLogStore methods
//
// Filtering:
// When specified, only notifications for the specified device and Almond are shown
// This facility provides for a data source delegation that can perform incremental loading
@property(weak) id <SFIDeviceLogStoreDelegate> delegate;
@property(nonatomic, readonly, copy) NSString *almondMac;
@property(nonatomic, readonly) sfi_id deviceID;

@end