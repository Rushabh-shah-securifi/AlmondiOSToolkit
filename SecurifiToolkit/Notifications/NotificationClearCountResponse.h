//
// Created by Matthew Sinclair-Day on 5/4/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NotificationClearCountResponse : NSObject

@property(nonatomic, readonly) BOOL error;

+ (instancetype)parseJson:(NSData *)data;

@end