//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"
#import "SFIAlmondMode.h"


@interface DynamicAlmondModeChange : NSObject <SFIAlmondMode>

@property(nonatomic) BOOL success;
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic, copy) NSString *userId;  // change made by logged in user
@property(nonatomic) SFIAlmondNotificationMode mode;

@end