//
//  SFIDevice.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIDeviceKnownValues.h"

typedef NS_ENUM(unsigned int, SFIDeviceType) {
    SFIDeviceType_UnknownDevice_0               = 0,
    SFIDeviceType_BinarySwitch_1                = 1,
    SFIDeviceType_MultiLevelSwitch_2            = 2,
    SFIDeviceType_BinarySensor_3                = 3,
    SFIDeviceType_MultiLevelOnOff_4             = 4,
    SFIDeviceType_DoorLock_5                    = 5,
    SFIDeviceType_Alarm_6                       = 6,
    SFIDeviceType_Thermostat_7                  = 7,
    SFIDeviceType_Controller_8                  = 8,
    SFIDeviceType_SceneController_9             = 9,
    SFIDeviceType_StandardCIE_10                = 10,
    SFIDeviceType_MotionSensor_11               = 11,
    SFIDeviceType_ContactSwitch_12              = 12,
    SFIDeviceType_FireSensor_13                 = 13,
    SFIDeviceType_WaterSensor_14                = 14,
    SFIDeviceType_GasSensor_15                  = 15,
    SFIDeviceType_PersonalEmergencyDevice_16    = 16,
    SFIDeviceType_VibrationOrMovementSensor_17  = 17,
    SFIDeviceType_RemoteControl_18              = 18,
    SFIDeviceType_KeyFob_19                     = 19,
    SFIDeviceType_Keypad_20                     = 20,
    SFIDeviceType_StandardWarningDevice_21      = 21,
    SFIDeviceType_SmartACSwitch_22              = 22,
    SFIDeviceType_SmartDCSwitch_23              = 23,
    SFIDeviceType_OccupancySensor_24            = 24,
    SFIDeviceType_LightSensor_25                = 25,
    SFIDeviceType_WindowCovering_26             = 26,
    SFIDeviceType_TemperatureSensor_27          = 27,
    SFIDeviceType_SimpleMetering_28             = 28,
    SFIDeviceType_ColorControl_29               = 29,
    SFIDeviceType_PressureSensor_30             = 30,
    SFIDeviceType_FlowSensor_31                 = 31,
    SFIDeviceType_ColorDimmableLight_32         = 32,
    SFIDeviceType_HAPump_33                     = 33,
    SFIDeviceType_Shade_34                      = 34,
    SFIDeviceType_SmokeDetector_36              = 36,
    SFIDeviceType_FloodSensor_37                = 37,
    SFIDeviceType_ShockSensor_38                = 38,
    SFIDeviceType_DoorSensor_39                 = 39,
    SFIDeviceType_MoistureSensor_40             = 40,
    SFIDeviceType_MovementSensor_41             = 41,
    SFIDeviceType_Siren_42                      = 42,
    SFIDeviceType_MultiSwitch_43                = 43,
    SFIDeviceType_UnknownOnOffModule_44         = 44,
    SFIDeviceType_BinaryPowerSwitch_45          = 45,
    SFIDeviceType_HueLamp_48                    = 48
};

typedef NS_ENUM(unsigned int, SFINotificationMode) {
    SFINotificationMode_always                  = 1,
    SFINotificationMode_home                    = 2,
    SFINotificationMode_away                    = 3,
};

@class SFIDeviceValue;

@interface SFIDevice : NSObject <NSCoding, NSCopying>

@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic) unsigned int deviceID;
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
