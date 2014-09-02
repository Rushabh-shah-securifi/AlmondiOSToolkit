//
//  SFIDevice.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

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
    SFIDeviceType_UnknownOnOffModule_44         = 44
};

@class SFIDeviceValue;

@interface SFIDevice : NSObject <NSCoding, NSCopying>

@property(nonatomic) unsigned int deviceID;
@property(nonatomic) NSString *deviceName;
@property(nonatomic) NSString *OZWNode;
@property(nonatomic) NSString *zigBeeShortID;
@property(nonatomic) NSString *zigBeeEUI64;
@property(nonatomic) unsigned int deviceTechnology;
@property(nonatomic) NSString *associationTimestamp;
@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic) NSString *deviceTypeName;
@property(nonatomic) NSString *friendlyDeviceType;
@property(nonatomic) NSString *deviceFunction;
@property(nonatomic) NSString *allowNotification;
@property(nonatomic) unsigned int valueCount;
@property(nonatomic) NSString *location;

@property(nonatomic) BOOL isExpanded;
@property(nonatomic) NSString *imageName;
@property(nonatomic) NSString *mostImpValueName;
@property(nonatomic) int mostImpValueIndex;
@property(nonatomic) int stateIndex;
@property(nonatomic) BOOL isTampered;
@property(nonatomic) int tamperValueIndex;
@property(nonatomic) BOOL isBatteryLow;

// Converts a type into a standard mnemonic name suitable for event logging
+ (NSString*)nameForType:(SFIDeviceType)type;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

// returns the imageName property value or when null returns the default value
- (NSString *)imageName:(NSString *)defaultName;

//todo not sure why it's called "most important" value
- (BOOL)isTamperMostImportantValue;

- (void)initializeFromValues:(SFIDeviceValue *)values;

- (id)copyWithZone:(NSZone *)zone;

@end
