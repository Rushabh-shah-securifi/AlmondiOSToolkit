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

- (void)storeNotification:(SFINotification *)notification;

- (void)deleteNotificationsForAlmond:(NSString *)almondMAC;

- (void)purgeAll;

@end