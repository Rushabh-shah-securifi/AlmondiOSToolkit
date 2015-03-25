//
// Created by Matthew Sinclair-Day on 1/29/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFINotification;
@protocol SFINotificationStore;


@interface DatabaseStore : NSObject

- (void)setup;

- (id<SFINotificationStore>)newStore;

- (BOOL)storeNotification:(SFINotification *)notification;

// Removes all notifications associated with the specified Almond MAC; called when an Almond is detached from the account
- (void)deleteNotificationsForAlmond:(NSString *)almondMAC;

// Remove all notifications ; does not affect tracked sync points
- (void)purgeAllNotifications;

// Clones the underlying database to the specified file path
- (BOOL)copyDatabaseTo:(NSString*)filePath;

// Called to store the notifications that were fetched using the specified sync point token
// The notifications are stored and the sync point is purged from the tracking table
- (BOOL)storeNotifications:(NSArray *)notifications syncPoint:(NSString *)syncPoint;

// Returns number of sync points being tracked pending download
- (NSInteger)countTrackedSyncPoints;

// Get the next sync point whose notifications need to be fetched
// will be nil when there are no sync points being tracked
- (NSString*)nextTrackedSyncPoint;

// Enqueue a sync point for tracking until its notifications can be fetched.
// The sync point is removed on calling -(BOOL)storeNotifications:syncPoint:
- (void)trackSyncPoint:(NSString *)pageState;

@end