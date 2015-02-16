//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

// Structure containing information about an update to an Almond's Mode setting.
@protocol SFIAlmondMode <NSObject>

// The Almond identified by the MAC value, whose mode setting changed
- (NSString *)almondMAC;

// The user ID of the person who changed the setting
- (NSString *)userId;  // change made by logged in user

// The new mode setting
- (SFIAlmondNotificationMode)mode;

@end