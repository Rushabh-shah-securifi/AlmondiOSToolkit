//
// Created by Matthew Sinclair-Day on 2/11/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFINotification;

@protocol SFINotificationStore <NSObject>

// returns total number of notifications that have not been viewed
- (NSUInteger)countUnviewedNotifications;

// returns the number of notifications in a bucket
- (NSUInteger)countNotificationsForBucket:(NSDate *)date;

// returns an array of NSDates, newest to oldest. Dates are normalized to midnight of a day for which there are notifications.
- (NSArray *)fetchDateBuckets:(NSUInteger)limit;

// fetch up to the specified number of most recent notifications
- (NSArray *)fetchNotifications:(NSUInteger)limit;

// this is the preferred way to fetch notifications
// retrieves the specified number of notifications starting at the specified index, in the specified time bucket
- (NSArray *)fetchNotificationsForBucket:(NSDate *)bucket start:(NSUInteger)start limit:(NSUInteger)limit;

- (SFINotification *)fetchNotificationForBucket:(NSDate *)bucket index:(NSUInteger)pos;

- (void)markViewed:(SFINotification *)notification;

@end