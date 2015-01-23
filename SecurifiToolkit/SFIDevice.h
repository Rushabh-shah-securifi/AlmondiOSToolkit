//
//  SFIDevice.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

typedef NS_ENUM(unsigned int, SFINotificationMode) {
    SFINotificationMode_always                  = 1,
    SFINotificationMode_home                    = 2,
    SFINotificationMode_away                    = 3,
};

@class SFIDeviceValue;
@class SFIDeviceKnownValues;

@interface SFIDevice : NSObject <NSCoding, NSCopying>

@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic) sfi_id deviceID;
@property(nonatomic) NSString *deviceName;
@property(nonatomic) NSString *OZWNode;
@property(nonatomic) NSString *zigBeeShortID;
@property(nonatomic) NSString *zigBeeEUI64;
@property(nonatomic) unsigned int deviceTechnology;
@property(nonatomic) NSString *associationTimestamp;
@property(nonatomic) NSString *deviceTypeName;
@property(nonatomic) NSString *friendlyDeviceType;
@property(nonatomic) NSString *deviceFunction;
@property(nonatomic) NSString *allowNotification;
@property(nonatomic) unsigned int valueCount;
@property(nonatomic) NSString *location;
@property(nonatomic) NSString *almondMAC; //todo remove me or set me in the toolkit
@property(nonatomic) SFINotificationMode notificationMode;

// Specified the property in the device values that represents the state of the device
@property(nonatomic, readonly) SFIDevicePropertyType statePropertyType;
@property(nonatomic, readonly) SFIDevicePropertyType mutableStatePropertyType; //todo probably need a better name for this; it was 'most important property index'; maybe call it "variableStatePropertyType" to mean the value can be in a range, not just binary.

// Converts a type into a standard mnemonic name suitable for event logging
+ (NSString *)nameForType:(SFIDeviceType)type;

// Indicates whether the device has been tampered
- (BOOL)isTampered:(SFIDeviceValue *)deviceValue;

// Indicates whether the device has a low battery
- (BOOL)isBatteryLow:(SFIDeviceValue *)deviceValue;

// Indicates whether the device has a binary "on/off" (or "open/closed" or so on) state that can be toggled.
- (BOOL)isBinaryStateSwitchable;

// Indicates whether the device has notification preference on
- (BOOL)isNotificationEnabled;



// Toggles the device state, returning the new state values.
// Returns nil if the device does not support switching state or when the value is missing and cannot be determined.
// Caller may test whether the device supports this capability by calling isBinaryStateSwitchable
- (SFIDeviceKnownValues*)switchBinaryState:(SFIDeviceValue *)value;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

@end
