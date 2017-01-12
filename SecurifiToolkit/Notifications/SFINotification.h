//
// Created by Matthew Sinclair-Day on 1/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

// Represents a single notification
@interface SFINotification : NSObject <NSCopying, NSCoding>

@property(nonatomic) long notificationId;   // the ID value as stored and referenced in the on-device db
@property(nonatomic, copy) NSString *externalId;  // the ID value as stored and referenced in the cloud db
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic) NSTimeInterval time;
@property(nonatomic, copy) NSString *deviceName;
@property(nonatomic) sfi_id deviceId;
@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic) sfi_id valueIndex;
@property(nonatomic) SFIDevicePropertyType valueType;
@property(nonatomic, copy) NSString *value; // device value
@property(nonatomic) BOOL viewed;
@property(nonatomic) SFINotificationCategory notiCat;
//@property(nonatomic, copy) NSString *clientName;
//@property(nonatomic, copy) NSString *clientConnection;
//@property(nonatomic, copy) NSString *notiType;
//@property(nonatomic, copy) NSString *clientType;

@property(nonatomic) long debugCounter;

+ (instancetype)parseNotificationPayload:(NSDictionary *)payload;

+ (instancetype)parseDeviceLogPayload:(NSDictionary *)payload;

// Used to alter the device name by appending the debugCounter value; useful for testing and debugging to track
// sequences of notifications. This alteration can be done prior to persisting the notification.
- (void)setDebugDeviceName;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

@end
