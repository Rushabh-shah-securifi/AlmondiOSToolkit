//
// Created by Matthew Sinclair-Day on 2/11/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFINotificationStore.h"

@class ZHDatabaseStatement;
@class ZHDatabase;


@interface NotificationStoreImpl : NSObject <SFINotificationStore>

- (instancetype)initWithDb:(ZHDatabase *)db;

@end