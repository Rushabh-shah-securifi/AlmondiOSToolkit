//
//  SFIDevice.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDevice.h"
#import "SFIDeviceKnownValues.h"
#import "SFIDeviceValue.h"

#define STATE @"STATE"
#define TAMPER @"TAMPER"
#define LOW_BATTERY @"LOW BATTERY"

@implementation SFIDevice

+ (NSString *)nameForType:(SFIDeviceType)type {
    switch (type) {
        case SFIDeviceType_UnknownDevice_0:return @"0_UnknownDevice";
        case SFIDeviceType_BinarySwitch_1:return @"1_BinarySwitch";
        case SFIDeviceType_MultiLevelSwitch_2:return @"2_MultiLevelSwitch";
        case SFIDeviceType_BinarySensor_3:return @"3_BinarySensor";
        case SFIDeviceType_MultiLevelOnOff_4:return @"4_MultiLevelOnOff";
        case SFIDeviceType_DoorLock_5:return @"5_DoorLock";
        case SFIDeviceType_Alarm_6:return @"6_Alarm";
        case SFIDeviceType_Thermostat_7:return @"7_Thermostat";
        case SFIDeviceType_Controller_8:return @"8_Controller";
        case SFIDeviceType_SceneController_9:return @"9_SceneController";
        case SFIDeviceType_StandardCIE_10:return @"10_StandardCIE";
        case SFIDeviceType_MotionSensor_11:return @"11_MotionSensor";
        case SFIDeviceType_ContactSwitch_12:return @"12_ContactSwitch";
        case SFIDeviceType_FireSensor_13:return @"13_FireSensor";
        case SFIDeviceType_WaterSensor_14:return @"14_WaterSensor";
        case SFIDeviceType_GasSensor_15:return @"15_GasSensor";
        case SFIDeviceType_PersonalEmergencyDevice_16:return @"16_PersonalEmergencyDevice";
        case SFIDeviceType_VibrationOrMovementSensor_17:return @"17_VibrationOrMovementSensor";
        case SFIDeviceType_RemoteControl_18:return @"18_RemoteControl";
        case SFIDeviceType_KeyFob_19:return @"19_KeyFob";
        case SFIDeviceType_Keypad_20:return @"20_Keypad";
        case SFIDeviceType_StandardWarningDevice_21:return @"21_StandardWarningDevice";
        case SFIDeviceType_SmartACSwitch_22:return @"22_SmartACSwitch";
        case SFIDeviceType_SmartDCSwitch_23:return @"23_SmartDCSwitch";
        case SFIDeviceType_OccupancySensor_24:return @"24_OccupancySensor";
        case SFIDeviceType_LightSensor_25:return @"25_LightSensor";
        case SFIDeviceType_WindowCovering_26:return @"26_WindowCovering";
        case SFIDeviceType_TemperatureSensor_27:return @"27_TemperatureSensor";
        case SFIDeviceType_SimpleMetering_28:return @"28_SimpleMetering";
        case SFIDeviceType_ColorControl_29:return @"29_ColorControl";
        case SFIDeviceType_PressureSensor_30:return @"30_PressureSensor";
        case SFIDeviceType_FlowSensor_31:return @"31_FlowSensor";
        case SFIDeviceType_ColorDimmableLight_32:return @"32_ColorDimmableLight";
        case SFIDeviceType_HAPump_33:return @"33_HAPump";
        case SFIDeviceType_Shade_34:return @"34_Shade";
        case SFIDeviceType_SmokeDetector_36:return @"36_SmokeDetector";
        case SFIDeviceType_FloodSensor_37:return @"37_FloodSensor";
        case SFIDeviceType_ShockSensor_38:return @"38_ShockSensor";
        case SFIDeviceType_DoorSensor_39:return @"39_DoorSensor";
        case SFIDeviceType_MoistureSensor_40:return @"40_MoistureSensor";
        case SFIDeviceType_MovementSensor_41:return @"41_MovementSensor";
        case SFIDeviceType_Siren_42:return @"42_Siren";
        case SFIDeviceType_MultiSwitch_43:return @"43_MultiSwitch";
        case SFIDeviceType_UnknownOnOffModule_44:return @"44_UnknownOnOffModule";
        case SFIDeviceType_BinaryPowerSwitch_45:return @"45_BinaryPowerSwitch";
        default: return nil;
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.deviceID = (unsigned int) [coder decodeIntForKey:@"self.deviceID"];
        self.deviceName = [coder decodeObjectForKey:@"self.deviceName"];
        self.OZWNode = [coder decodeObjectForKey:@"self.OZWNode"];
        self.zigBeeShortID = [coder decodeObjectForKey:@"self.zigBeeShortID"];
        self.zigBeeEUI64 = [coder decodeObjectForKey:@"self.zigBeeEUI64"];
        self.deviceTechnology = (unsigned int) [coder decodeIntForKey:@"self.deviceTechnology"];
        self.associationTimestamp = [coder decodeObjectForKey:@"self.associationTimestamp"];
        self.deviceType = (SFIDeviceType) [coder decodeIntForKey:@"self.deviceType"];
        self.deviceTypeName = [coder decodeObjectForKey:@"self.deviceTypeName"];
        self.friendlyDeviceType = [coder decodeObjectForKey:@"self.friendlyDeviceType"];
        self.deviceFunction = [coder decodeObjectForKey:@"self.deviceFunction"];
        self.allowNotification = [coder decodeObjectForKey:@"self.allowNotification"];
        self.valueCount = (unsigned int) [coder decodeIntForKey:@"self.valueCount"];
        self.location = [coder decodeObjectForKey:@"self.location"];
        self.isExpanded = [coder decodeBoolForKey:@"self.isExpanded"];
        self.imageName = [coder decodeObjectForKey:@"self.imageName"];
        self.mostImpValueName = [coder decodeObjectForKey:@"self.mostImpValueName"];
        self.mostImpValueIndex = [coder decodeIntForKey:@"self.mostImpValueIndex"];
        self.stateIndex = [coder decodeIntForKey:@"self.stateIndex"];
        self.isTampered = [coder decodeBoolForKey:@"self.isTampered"];
        self.tamperValueIndex = [coder decodeIntForKey:@"self.tamperValueIndex"];
        self.isBatteryLow = [coder decodeBoolForKey:@"self.isBatteryLow"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.deviceID forKey:@"self.deviceID"];
    [coder encodeObject:self.deviceName forKey:@"self.deviceName"];
    [coder encodeObject:self.OZWNode forKey:@"self.OZWNode"];
    [coder encodeObject:self.zigBeeShortID forKey:@"self.zigBeeShortID"];
    [coder encodeObject:self.zigBeeEUI64 forKey:@"self.zigBeeEUI64"];
    [coder encodeInt:self.deviceTechnology forKey:@"self.deviceTechnology"];
    [coder encodeObject:self.associationTimestamp forKey:@"self.associationTimestamp"];
    [coder encodeInt:self.deviceType forKey:@"self.deviceType"];
    [coder encodeObject:self.deviceTypeName forKey:@"self.deviceTypeName"];
    [coder encodeObject:self.friendlyDeviceType forKey:@"self.friendlyDeviceType"];
    [coder encodeObject:self.deviceFunction forKey:@"self.deviceFunction"];
    [coder encodeObject:self.allowNotification forKey:@"self.allowNotification"];
    [coder encodeInt:self.valueCount forKey:@"self.valueCount"];
    [coder encodeObject:self.location forKey:@"self.location"];
    [coder encodeBool:self.isExpanded forKey:@"self.isExpanded"];
    [coder encodeObject:self.imageName forKey:@"self.imageName"];
    [coder encodeObject:self.mostImpValueName forKey:@"self.mostImpValueName"];
    [coder encodeInt:self.mostImpValueIndex forKey:@"self.mostImpValueIndex"];
    [coder encodeInt:self.stateIndex forKey:@"self.stateIndex"];
    [coder encodeBool:self.isTampered forKey:@"self.isTampered"];
    [coder encodeInt:self.tamperValueIndex forKey:@"self.tamperValueIndex"];
    [coder encodeBool:self.isBatteryLow forKey:@"self.isBatteryLow"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.deviceID=%u", self.deviceID];
    [description appendFormat:@", self.deviceName=%@", self.deviceName];
    [description appendFormat:@", self.OZWNode=%@", self.OZWNode];
    [description appendFormat:@", self.zigBeeShortID=%@", self.zigBeeShortID];
    [description appendFormat:@", self.zigBeeEUI64=%@", self.zigBeeEUI64];
    [description appendFormat:@", self.deviceTechnology=%u", self.deviceTechnology];
    [description appendFormat:@", self.associationTimestamp=%@", self.associationTimestamp];
    [description appendFormat:@", self.deviceType=%u", self.deviceType];
    [description appendFormat:@", self.deviceTypeName=%@", self.deviceTypeName];
    [description appendFormat:@", self.friendlyDeviceType=%@", self.friendlyDeviceType];
    [description appendFormat:@", self.deviceFunction=%@", self.deviceFunction];
    [description appendFormat:@", self.allowNotification=%@", self.allowNotification];
    [description appendFormat:@", self.valueCount=%u", self.valueCount];
    [description appendFormat:@", self.location=%@", self.location];
    [description appendFormat:@", self.isExpanded=%d", self.isExpanded];
    [description appendFormat:@", self.imageName=%@", self.imageName];
    [description appendFormat:@", self.mostImpValueName=%@", self.mostImpValueName];
    [description appendFormat:@", self.mostImpValueIndex=%i", self.mostImpValueIndex];
    [description appendFormat:@", self.stateIndex=%i", self.stateIndex];
    [description appendFormat:@", self.isTampered=%d", self.isTampered];
    [description appendFormat:@", self.tamperValueIndex=%i", self.tamperValueIndex];
    [description appendFormat:@", self.isBatteryLow=%d", self.isBatteryLow];
    [description appendString:@">"];
    return description;
}

- (id)copyWithZone:(NSZone *)zone {
    SFIDevice *copy = (SFIDevice *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.deviceID = self.deviceID;
        copy.deviceName = self.deviceName;
        copy.OZWNode = self.OZWNode;
        copy.zigBeeShortID = self.zigBeeShortID;
        copy.zigBeeEUI64 = self.zigBeeEUI64;
        copy.deviceTechnology = self.deviceTechnology;
        copy.associationTimestamp = self.associationTimestamp;
        copy.deviceType = self.deviceType;
        copy.deviceTypeName = self.deviceTypeName;
        copy.friendlyDeviceType = self.friendlyDeviceType;
        copy.deviceFunction = self.deviceFunction;
        copy.allowNotification = self.allowNotification;
        copy.valueCount = self.valueCount;
        copy.location = self.location;
        copy.isExpanded = self.isExpanded;
        copy.imageName = self.imageName;
        copy.mostImpValueName = self.mostImpValueName;
        copy.mostImpValueIndex = self.mostImpValueIndex;
        copy.stateIndex = self.stateIndex;
        copy.isTampered = self.isTampered;
        copy.tamperValueIndex = self.tamperValueIndex;
        copy.isBatteryLow = self.isBatteryLow;
    }

    return copy;
}


- (NSString *)imageName:(NSString *)defaultName {
    return self.imageName ? self.imageName : defaultName;
}

- (void)initializeFromValues:(SFIDeviceValue *)values {

    switch (self.deviceType) {

        case SFIDeviceType_MultiLevelSwitch_2: {
            [self configureDeviceForState:SFIDevicePropertyType_SWITCH_MULTILEVEL values:values];
            break;
        }

        case SFIDeviceType_MultiLevelOnOff_4: {
            NSArray *currentKnownValues = values.knownDevicesValues;
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues;
                curDeviceValues = currentKnownValues[index];

                if (curDeviceValues.propertyType == SFIDevicePropertyType_SWITCH_BINARY) {
                    self.stateIndex = index;
                }
                else if (curDeviceValues.propertyType == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = curDeviceValues.valueName;
                }
            }
            break;
        }
        case SFIDeviceType_DoorLock_5: {
            [self configureDeviceForState:SFIDevicePropertyType_LOCK_STATE values:values];
            break;
        }

        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_BinarySensor_3:
        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_SmartDCSwitch_23:
        case SFIDeviceType_Shade_34:
        case SFIDeviceType_MovementSensor_41:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_UnknownOnOffModule_44:
        case SFIDeviceType_BinaryPowerSwitch_45: {
            [self configureDeviceForState:SFIDevicePropertyType_SWITCH_BINARY values:values];
            break;
        }

        case SFIDeviceType_Alarm_6:
        case SFIDeviceType_FloodSensor_37:
        case SFIDeviceType_MoistureSensor_40: {
            [self configureDeviceForState:SFIDevicePropertyType_BASIC values:values];
            break;
        }

        case SFIDeviceType_MotionSensor_11:
        case SFIDeviceType_ContactSwitch_12:
        case SFIDeviceType_FireSensor_13:
        case SFIDeviceType_WaterSensor_14:
        case SFIDeviceType_GasSensor_15:
        case SFIDeviceType_VibrationOrMovementSensor_17:
        case SFIDeviceType_Keypad_20:
        case SFIDeviceType_StandardWarningDevice_21: {
            [self configureStandardStateDevice:values];
            break;
        }

        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_Thermostat_7:
        case SFIDeviceType_Controller_8:
        case SFIDeviceType_SceneController_9:
        case SFIDeviceType_StandardCIE_10:
        case SFIDeviceType_PersonalEmergencyDevice_16:
        case SFIDeviceType_RemoteControl_18:
        case SFIDeviceType_KeyFob_19:
        case SFIDeviceType_OccupancySensor_24:
        case SFIDeviceType_LightSensor_25:
        case SFIDeviceType_WindowCovering_26:
        case SFIDeviceType_TemperatureSensor_27:
        case SFIDeviceType_SimpleMetering_28:
        case SFIDeviceType_ColorControl_29:
        case SFIDeviceType_PressureSensor_30:
        case SFIDeviceType_FlowSensor_31:
        case SFIDeviceType_ColorDimmableLight_32:
        case SFIDeviceType_HAPump_33:
        case SFIDeviceType_SmokeDetector_36:
        case SFIDeviceType_ShockSensor_38:
        case SFIDeviceType_DoorSensor_39:
        case SFIDeviceType_MultiSwitch_43:
        default: {
            self.imageName = @"default_device.png";
            break;
        }
    };
}

- (void)configureDeviceForState:(SFIDevicePropertyType)stateProperty values:(SFIDeviceValue *)deviceValue {
    //todo remove need for iteration
    NSArray *devicesValues = deviceValue.knownDevicesValues;
    NSUInteger count = [devicesValues count];
    for (unsigned int index = 0; index < count; index++) {
        SFIDeviceKnownValues *values = devicesValues[index];

        if (values.propertyType == stateProperty) {
            self.stateIndex = index;
            self.mostImpValueIndex = index;
            self.mostImpValueName = values.valueName;

            break;
        }
    }

    SFIDeviceKnownValues *values;

    values = [deviceValue knownValuesForProperty:SFIDevicePropertyType_TAMPER];
    if (values) {
        self.isTampered = [values.value boolValue];
    }

    values = [deviceValue knownValuesForProperty:SFIDevicePropertyType_LOW_BATTERY];
    if (values) {
        self.isBatteryLow = [values.value boolValue];
    }
    
}

- (void)configureStandardStateDevice:(SFIDeviceValue *)deviceValue {
    [self configureDeviceForState:SFIDevicePropertyType_STATE values:deviceValue];
}

- (BOOL)isTamperMostImportantValue {
    return [self.mostImpValueName isEqualToString:TAMPER];
}

@end
