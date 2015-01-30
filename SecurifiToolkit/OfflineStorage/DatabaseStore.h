//
// Created by Matthew Sinclair-Day on 1/29/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFINotification;


@interface DatabaseStore : NSObject

- (void)setup;

- (void)storeNotification:(SFINotification *)notification;

- (NSInteger)countUnviewedNotifications;

- (NSInteger)countNotificationsForBucket:(NSDate *)date;

// returns an array of NSDates, newest to oldest. Dates are normalized to midnight of a day for which there are notifications.
- (NSArray *)fetchDateBuckets:(int)limit;

- (NSArray *)fetchNotifications:(int)limit;

- (NSArray *)fetchNotificationsForBucket:(NSDate *)bucket limit:(int)limit;

- (void)deleteNotificationsForAlmond:(NSString *)almondMAC;

- (void)purgeAll;

- (void)markViewed:(SFINotification *)notification;

@end