//
// Created by Matthew Sinclair-Day on 1/29/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFINotification;


@interface DatabaseStore : NSObject

//todo delete notifications on removal of almond
//todo auto-group notifications by date

- (void)setup;

- (void)storeNotification:(SFINotification *)notification;

- (NSInteger)countUnviewedNotifications;

- (NSArray *)fetchNotifications:(int)limit;

- (void)markViewed:(SFINotification *)notification;

@end