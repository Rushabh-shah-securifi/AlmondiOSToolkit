//
// Created by Matthew Sinclair-Day on 1/23/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

// Represents a single notification
@interface SFINotification : NSObject <NSCopying, NSCoding>

@property(nonatomic) long notificationId;
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic) NSTimeInterval time;
@property(nonatomic) sfi_id deviceId;
@property(nonatomic, copy) NSString *deviceName;
@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic) sfi_id valueIndex;
@property(nonatomic) SFIDevicePropertyType valueType;
@property(nonatomic, copy) NSString *value; // device value
@property(nonatomic, readonly) NSString *message;
@property(nonatomic) BOOL viewed;

+ (instancetype)parseJson:(NSData*)data;

+ (instancetype)parsePayload:(NSDictionary*)payload;

- (NSString *)description;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (id)copyWithZone:(NSZone *)zone;

@end