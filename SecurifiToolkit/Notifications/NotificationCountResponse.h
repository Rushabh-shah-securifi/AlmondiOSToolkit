//
// Created by Matthew Sinclair-Day on 3/25/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// Reports the results of asking for the current count of new notifications
@interface NotificationCountResponse : NSObject

// the count unless error is true
@property(nonatomic, readonly) NSInteger badgeCount;
@property(nonatomic, readonly) BOOL error;

+ (instancetype)parseJson:(NSData *)data;

@end