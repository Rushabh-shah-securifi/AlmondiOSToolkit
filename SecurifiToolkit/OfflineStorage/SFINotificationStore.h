//
// Created by Matthew Sinclair-Day on 2/11/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

@class SFINotification;
@protocol SFINotificationStore;
@protocol SFIDeviceLogStore;

@protocol SFINotificationStore <NSObject>

// returns total number of notifications that have not been viewed
- (NSUInteger)countUnviewedNotifications;

// returns the number of notifications in a bucket
- (NSUInteger)countNotificationsForBucket:(NSDate *)date;

// returns an array of NSDates, newest to oldest. Dates are normalized to midnight of a day for which there are notifications.
- (NSArray *)fetchDateBuckets:(NSUInteger)limit;

// Called when the last records are being displayed to signal more should be fetched/loaded, if possible
- (void)ensureFetchNotifications;

- (SFINotification *)fetchNotificationForBucket:(NSDate *)bucket index:(NSUInteger)pos;

- (void)markViewed:(SFINotification *)notification;

// marks all notifications up to and including the one as viewed
- (void)markAllViewedTo:(SFINotification *)notification;

- (void)markDeleted:(SFINotification *)notification;

- (void)deleteAllNotifications;

@end


@protocol SFIDeviceLogStoreDelegate

- (void)deviceLogStoreTryFetchRecords:(id <SFIDeviceLogStore>)deviceLogStore;

@end


// For storing device log records
@protocol SFIDeviceLogStore <SFINotificationStore>

// Filtering:
// Only notifications for the specified device and Almond are shown
// This facility provides for a data source delegation that can perform incremental loading
@property(weak) id <SFIDeviceLogStoreDelegate> delegate;
@property(nonatomic, readonly, copy) NSString *almondMac;
@property(nonatomic, readonly) sfi_id deviceID;

@end