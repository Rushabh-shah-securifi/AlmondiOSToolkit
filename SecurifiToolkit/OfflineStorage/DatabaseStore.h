//
// Created by Matthew Sinclair-Day on 1/29/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

@class SFINotification;
@protocol SFINotificationStore;
@protocol SFIDeviceLogStoreDelegate;
@protocol SFIDeviceLogStore;


@interface DatabaseStore : NSObject

// Returns the standard database for storing Notifications
+ (instancetype)notificationsDatabase;

// Returns the standard database for storing device log records
// A single database can be used to store records for any number of devices
+ (instancetype)deviceLogsDatabase;

- (id <SFINotificationStore>)newNotificationStore;

- (id <SFIDeviceLogStore>)newDeviceLogStore:(NSString *)almondMac deviceId:(sfi_id)deviceId delegate:(id<SFIDeviceLogStoreDelegate>)delegate;

// Removes all notifications associated with the specified Almond MAC; called when an Almond is detached from the account
- (void)deleteNotificationsForAlmond:(NSString *)almondMAC;

// Remove all notifications and syncpoints
- (void)purgeAll;

// Clones the underlying database to the specified file path
- (BOOL)copyDatabaseTo:(NSString *)filePath;

// Called to store the notifications that were fetched using the specified sync point token
// The notifications are stored and the sync point is purged from the tracking table
// Returns number actually stored; the process stops on finding the first duplicate.
// The caller can compare the count with the total payload to determine whether to continue fetching.
- (NSInteger)storeNotifications:(NSArray *)notifications syncPoint:(NSString *)syncPoint;

// Returns number of sync points being tracked pending download
- (NSInteger)countTrackedSyncPoints;

// Get the next sync point whose notifications need to be fetched
// will be nil when there are no sync points being tracked
- (NSString *)nextTrackedSyncPoint;

// Removed the sybc point from the tracking table
- (void)removeSyncPoint:(NSString *)pageState;

// Enqueue a sync point for tracking until its notifications can be fetched.
// The sync point is removed on calling -(BOOL)storeNotifications:syncPoint:
- (void)trackSyncPoint:(NSString *)pageState;

// Indicates whether the sync point is already tracked
// Can be used for higher-level control logic to validate page state data returned from the cloud.
- (BOOL)isTrackedSyncPoint:(NSString *)pageState;

- (void)storeBadgeCount:(NSInteger)count;

- (NSInteger)badgeCount;

@end