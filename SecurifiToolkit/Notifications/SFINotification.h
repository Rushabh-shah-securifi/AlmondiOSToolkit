//
// Created by Matthew Sinclair-Day on 1/23/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

// Represents a single notification
@interface SFINotification : NSObject <NSCopying, NSCoding>

@property(nonatomic) NSTimeInterval time;
@property(nonatomic) sfi_id deviceId;
@property(nonatomic) NSString *deviceName;
@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic) sfi_id valueIndex;
@property(nonatomic) SFIDevicePropertyType valueType;
@property(nonatomic) NSString *value;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (id)copyWithZone:(NSZone *)zone;

@end