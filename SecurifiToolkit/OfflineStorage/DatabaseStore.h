//
// Created by Matthew Sinclair-Day on 1/29/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFINotification;
@protocol SFINotificationStore;


@interface DatabaseStore : NSObject

- (void)setup;

- (id<SFINotificationStore>)newStore;

- (BOOL)storeNotification:(SFINotification *)notification;

- (void)deleteNotificationsForAlmond:(NSString *)almondMAC;

- (void)purgeAll;

- (BOOL)copyDatabaseTo:(NSString*)filePath;

- (BOOL)storeNotifications:(NSArray *)notifications newSyncPoint:(NSString *)syncPoint;

// will be nil when no sync has been done
- (NSString*)lastSyncPoint;

@end