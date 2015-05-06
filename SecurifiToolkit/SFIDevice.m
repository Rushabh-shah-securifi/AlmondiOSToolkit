//
//  SFIDevice.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SecurifiToolkit.h"

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
        case SFIDeviceType_ZigbeeDoorLock_28:return @"28_ZigbeeDoorLock";
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
        case SFIDeviceType_HueLamp_48:return @"48_HueLamp";
        case SFIDeviceType_SecurifiSmartSwitch_50:return @"50_SecurifiSmartSwitch";
        default: return [NSString stringWithFormat:@"%d_UnknownDevice", type];
    }
}

- (SFIDevicePropertyType)statePropertyType {
    switch (self.deviceType) {
        case SFIDeviceType_MultiLevelSwitch_2: {
            return SFIDevicePropertyType_SWITCH_MULTILEVEL;
        }

        case SFIDeviceType_DoorLock_5:
        case SFIDeviceType_ZigbeeDoorLock_28:
        {
            return SFIDevicePropertyType_LOCK_STATE;
        }

        case SFIDeviceType_StandardWarningDevice_21: {
            return SFIDevicePropertyType_ALARM_STATE;
        }

        case SFIDeviceType_Alarm_6:
        case SFIDeviceType_SmokeDetector_36:
        case SFIDeviceType_FloodSensor_37:
        case SFIDeviceType_MoistureSensor_40: {
            return SFIDevicePropertyType_BASIC;
        }

        case SFIDeviceType_MotionSensor_11:
        case SFIDeviceType_ContactSwitch_12:
        case SFIDeviceType_FireSensor_13:
        case SFIDeviceType_WaterSensor_14:
        case SFIDeviceType_GasSensor_15:
        case SFIDeviceType_VibrationOrMovementSensor_17:
        case SFIDeviceType_Keypad_20:
        {
            return SFIDevicePropertyType_STATE;
        }

        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_MultiLevelOnOff_4:
        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_SmartDCSwitch_23:
        case SFIDeviceType_ColorDimmableLight_32:
        case SFIDeviceType_Shade_34:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_UnknownOnOffModule_44:
        case SFIDeviceType_BinaryPowerSwitch_45:
        case SFIDeviceType_HueLamp_48:
        case SFIDeviceType_SecurifiSmartSwitch_50:
        {
            return SFIDevicePropertyType_SWITCH_BINARY;
        }

        case SFIDeviceType_BinarySensor_3:
        case SFIDeviceType_ShockSensor_38:
        case SFIDeviceType_DoorSensor_39:
        case SFIDeviceType_MovementSensor_41:
        {
            return SFIDevicePropertyType_SENSOR_BINARY;
        }

        case SFIDeviceType_OccupancySensor_24: {
            return SFIDevicePropertyType_OCCUPANCY;
        };

        // Not implemented devices
        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_Thermostat_7:
        case SFIDeviceType_Controller_8:
        case SFIDeviceType_SceneController_9:
        case SFIDeviceType_StandardCIE_10:
        case SFIDeviceType_PersonalEmergencyDevice_16:
        case SFIDeviceType_RemoteControl_18:
        case SFIDeviceType_KeyFob_19:
        case SFIDeviceType_LightSensor_25:
        case SFIDeviceType_WindowCovering_26:
        case SFIDeviceType_TemperatureSensor_27:
        case SFIDeviceType_ColorControl_29:
        case SFIDeviceType_PressureSensor_30:
        case SFIDeviceType_FlowSensor_31:
        case SFIDeviceType_HAPump_33:
        case SFIDeviceType_MultiSwitch_43:
        default: {
            return SFIDevicePropertyType_STATE;
        }
    }}

- (SFIDevicePropertyType)mutableStatePropertyType {
    switch (self.deviceType) {
        case SFIDeviceType_MultiLevelSwitch_2:
        case SFIDeviceType_MultiLevelOnOff_4:
            return SFIDevicePropertyType_SWITCH_MULTILEVEL;

        default:
            return [self statePropertyType];
    }
}

- (BOOL)isBinaryStateSwitchable {
    switch (self.deviceType) {
        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_MultiLevelSwitch_2:
        case SFIDeviceType_BinarySensor_3:
        case SFIDeviceType_MultiLevelOnOff_4:
        case SFIDeviceType_DoorLock_5:
        case SFIDeviceType_Alarm_6:
        case SFIDeviceType_StandardWarningDevice_21:
        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_SmartDCSwitch_23:
        case SFIDeviceType_ZigbeeDoorLock_28:
        case SFIDeviceType_ColorDimmableLight_32:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_UnknownOnOffModule_44:
        case SFIDeviceType_BinaryPowerSwitch_45:
        case SFIDeviceType_HueLamp_48:
        case SFIDeviceType_SecurifiSmartSwitch_50: {
            return YES;
        }

        default: {
            return NO;
        }
    }
}


- (SFIDeviceKnownValues *)switchBinaryState:(SFIDeviceValue *)value {
    SFIDeviceKnownValues *deviceValues = nil;

    switch (self.deviceType) {
        case SFIDeviceType_MultiLevelSwitch_2: {
            deviceValues = [value knownValuesForProperty:self.statePropertyType];

            int newValue = (deviceValues.intValue == 0) ? 99 : 0;
            [deviceValues setIntValue:newValue];
            break;
        }

        case SFIDeviceType_BinarySensor_3: {
            deviceValues = [value knownValuesForProperty:self.statePropertyType];
            [deviceValues setBoolValue:NO];
            break;
        }

        case SFIDeviceType_DoorLock_5:
        case SFIDeviceType_Alarm_6:
        {
            deviceValues = [value knownValuesForProperty:self.statePropertyType];

            int newValue = (deviceValues.intValue == 0) ? 255 : 0;
            [deviceValues setIntValue:newValue];
            break;
        }

        case SFIDeviceType_StandardWarningDevice_21: {
            deviceValues = [value knownValuesForProperty:self.statePropertyType];
            int newValue = (deviceValues.intValue == 0) ? 65535 : 0;
            [deviceValues setIntValue:newValue];
            break;
        }

        case SFIDeviceType_ZigbeeDoorLock_28: {
            deviceValues = [value knownValuesForProperty:self.statePropertyType];

            int newValue = (deviceValues.intValue == 0) ? 1 : 0;
            [deviceValues setIntValue:newValue];
            break;
        }

        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_MultiLevelOnOff_4:
        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_SmartDCSwitch_23:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_UnknownOnOffModule_44:
        case SFIDeviceType_BinaryPowerSwitch_45:
        case SFIDeviceType_HueLamp_48:
        case SFIDeviceType_SecurifiSmartSwitch_50:
        {
            deviceValues = [value knownValuesForProperty:self.statePropertyType];
            if (deviceValues.hasValue) {
                [deviceValues setBoolValue:!deviceValues.boolValue];
            }
            break;
        }

        default: {
            // do nothing
        }
    } // end switch

    return deviceValues; // can be nil
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.notificationMode = SFINotificationMode_unknown;
    }

    return self;
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.notificationMode = SFINotificationMode_unknown;

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
        self.almondMAC = [coder decodeObjectForKey:@"self.almondMAC"];
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
    [coder encodeObject:self.almondMAC forKey:@"self.almondMAC"];
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
    [description appendFormat:@", self.almondMAC=%@", self.almondMAC];
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
        copy.almondMAC = self.almondMAC;
    }

    return copy;
}

- (BOOL)isTampered:(SFIDeviceValue *)deviceValue {
    SFIDeviceKnownValues *values = [deviceValue knownValuesForProperty:SFIDevicePropertyType_TAMPER];
    if (!values) {
        return NO;
    }
    return [values.value boolValue];
}

- (BOOL)isBatteryLow:(SFIDeviceValue *)deviceValue {
    SFIDeviceKnownValues *values = [deviceValue knownValuesForProperty:SFIDevicePropertyType_LOW_BATTERY];
    if (!values) {
        return NO;
    }
    return [values.value boolValue];
}

- (NSArray *)updateNotificationMode:(SFINotificationMode)mode deviceValue:(SFIDeviceValue *)value {
    if (mode == SFINotificationMode_unknown) {
        NSLog(@"updateNotificationMode: illegal mode 'SFINotificationMode_unknown'; ignoring change");
        return @[];
    }

    // Note side-effect on this instance
    self.notificationMode = mode;

    // When changing mode, we have to set the preference for each index and send the list to the cloud.
    // Notification will be sent for all changes to the devices known values; one preference setting for each device property.
    // It seems like the cloud could provide a simple API for doing this work for us.
    //
    // The list of indexes whose preference setting has to be changed
    NSArray *deviceValuesList;

    if (self.deviceID == SFIDeviceType_SmartACSwitch_22 || self.deviceID == SFIDeviceType_SecurifiSmartSwitch_50) {
        // Special case these two: we only toggle the setting for the main state index
        // otherwise the notifications will be too many
        SFIDeviceKnownValues *deviceValue = [value knownValuesForProperty:self.statePropertyType];
        deviceValuesList = @[deviceValue];
    }
    else {
        // General case: change all indexes
        deviceValuesList = [value knownDevicesValues];
    }

    // The list of preference settings
    NSMutableArray *settings = [[NSMutableArray alloc] init];

    for (SFIDeviceKnownValues *deviceValue in deviceValuesList) {
        SFINotificationDevice *notificationDevice = [[SFINotificationDevice alloc] init];
        notificationDevice.deviceID = self.deviceID;
        notificationDevice.notificationMode = self.notificationMode;
        notificationDevice.valueIndex = deviceValue.index;

        [settings addObject:notificationDevice];
    }

    return settings;
}

@end
