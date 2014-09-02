//
//  SFIReachabilityManager.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

//todo move to the securifi toolkit; move to a delegate model
extern NSString *const kSFIReachabilityChangedNotification;

@interface SFIReachabilityManager : NSObject

- (instancetype)initWithHost:(NSString *)host;

- (void)shutdown;

- (BOOL)isReachable;

- (BOOL)isUnreachable;

- (BOOL)isReachableViaWWAN;

- (BOOL)isReachableViaWiFi;

@end
