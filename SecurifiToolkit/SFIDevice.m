//
//  SFIDevice.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "SecurifiToolkit.h"

#define SFIDeviceType_ZigbeeDoorLock_28_NOT_FULLY_LOCKED    0
#define SFIDeviceType_ZigbeeDoorLock_28_LOCKED              1
#define SFIDeviceType_ZigbeeDoorLock_28_UNLOCKED            2

#define SFIDeviceType_GarageDoorOpener_53_CLOSED            0
#define SFIDeviceType_GarageDoorOpener_53_CLOSING           252
#define SFIDeviceType_GarageDoorOpener_53_STOPPED           253
#define SFIDeviceType_GarageDoorOpener_53_OPENING           254
#define SFIDeviceType_GarageDoorOpener_53_OPEN              255


@implementation SFIDevice

+ (NSArray *)addDevice:(SFIDevice *)device list:(NSArray *)list {
    for (SFIDevice *old in list) {
        if (device.deviceID == old.deviceID) {
            // already in list; do nothing
            return list;
        }
    }
    
    NSMutableArray *new_list = [NSMutableArray arrayWithArray:list];
    [new_list addObject:device];
    
    return new_list;
}

+ (NSArray *)removeDevice:(SFIDevice *)device list:(NSArray *)list {
    NSMutableArray *new_list = [NSMutableArray array];
    
    for (SFIDevice *old in list) {
        if (device.deviceID != old.deviceID) {
            // already in list; do nothing
            [new_list addObject:device];
        }
    }
    
    return new_list;
}

- (SFIDevicePropertyType)statePropertyType {
    switch (self.deviceType) {
        case SFIDeviceType_MultiLevelSwitch_2:{
            return SFIDevicePropertyType_SWITCH_MULTILEVEL;
        }
            
        case SFIDeviceType_DoorLock_5:
        case SFIDeviceType_ZigbeeDoorLock_28: {
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
        case SFIDeviceType_Keypad_20: {
            return SFIDevicePropertyType_STATE;
        }
            
        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_MultiLevelOnOff_4:
        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_SmartDCSwitch_23:
        case SFIDeviceType_ColorDimmableLight_32:
        case SFIDeviceType_Shade_34:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_MultiSwitch_43:
        case SFIDeviceType_UnknownOnOffModule_44:
        case SFIDeviceType_BinaryPowerSwitch_45:
        case SFIDeviceType_HueLamp_48:
        case SFIDeviceType_SecurifiSmartSwitch_50: {
            return SFIDevicePropertyType_SWITCH_BINARY;
        }
            
        case SFIDeviceType_BinarySensor_3:
        case SFIDeviceType_ShockSensor_38:
        case SFIDeviceType_DoorSensor_39:
        case SFIDeviceType_MovementSensor_41: {
            return SFIDevicePropertyType_SENSOR_BINARY;
        }
            
        case SFIDeviceType_OccupancySensor_24: {
            return SFIDevicePropertyType_OCCUPANCY;
        };
            
        case SFIDeviceType_GarageDoorOpener_53: {
            return SFIDevicePropertyType_BARRIER_OPERATOR;
        }
            
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
        case SFIDeviceType_SetPointThermostat_46:
        case SFIDeviceType_NestSmokeDetector_58:
        case SFIDeviceType_NestThermostat_57:
        case SFIDeviceType_51:
        case SFIDeviceType_RollerShutter_52:
        default: {
            return SFIDevicePropertyType_STATE;
        }
    }
}

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
        case SFIDeviceType_SecurifiSmartSwitch_50:
        case SFIDeviceType_GarageDoorOpener_53: {
            return YES;
        }
            
        default: {
            return NO;
        }
    }
}



- (BOOL)isActuator{
    //        case SFIDeviceType_Alarm_6:
    switch (self.deviceType) {
        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_MultiLevelSwitch_2:
        case SFIDeviceType_MultiLevelOnOff_4:
        case SFIDeviceType_DoorLock_5:
        case SFIDeviceType_Thermostat_7:
        case SFIDeviceType_StandardWarningDevice_21:
        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_ZigbeeDoorLock_28:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_UnknownOnOffModule_44:
        case SFIDeviceType_BinaryPowerSwitch_45:
        case SFIDeviceType_HueLamp_48:
        case SFIDeviceType_SecurifiSmartSwitch_50:
        case SFIDeviceType_NestThermostat_57:{
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
        case SFIDeviceType_Alarm_6: {
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
            
            int newValue;
            switch (deviceValues.intValue) {
                case SFIDeviceType_ZigbeeDoorLock_28_NOT_FULLY_LOCKED:
                    newValue = SFIDeviceType_ZigbeeDoorLock_28_LOCKED;
                    break;
                case SFIDeviceType_ZigbeeDoorLock_28_LOCKED:
                    newValue = SFIDeviceType_ZigbeeDoorLock_28_UNLOCKED;
                    break;
                case SFIDeviceType_ZigbeeDoorLock_28_UNLOCKED:
                    newValue = SFIDeviceType_ZigbeeDoorLock_28_LOCKED;
                    break;
                default:
                    newValue = SFIDeviceType_ZigbeeDoorLock_28_LOCKED;
            }
            
            [deviceValues setIntValue:newValue];
            break;
        }
            
        case SFIDeviceType_GarageDoorOpener_53: {
            /*
             0	we can set 0 (to close) and 255(to open) only	Closed
             252		closing
             253		Stopped
             254		Opening
             255		Open
             */
            deviceValues = [value knownValuesForProperty:self.statePropertyType];
            
            int newValue;
            
            switch (deviceValues.intValue) {
                case SFIDeviceType_GarageDoorOpener_53_CLOSED:
                    newValue = SFIDeviceType_GarageDoorOpener_53_OPEN;
                    break;
                case SFIDeviceType_GarageDoorOpener_53_CLOSING:
                    newValue = SFIDeviceType_GarageDoorOpener_53_CLOSED;
                    break;
                case SFIDeviceType_GarageDoorOpener_53_STOPPED:
                    newValue = SFIDeviceType_GarageDoorOpener_53_CLOSED;
                    break;
                case SFIDeviceType_GarageDoorOpener_53_OPENING:
                    newValue = SFIDeviceType_GarageDoorOpener_53_CLOSED;
                    break;
                case SFIDeviceType_GarageDoorOpener_53_OPEN:
                    newValue = SFIDeviceType_GarageDoorOpener_53_CLOSED;
                    break;
                default:
                    newValue = SFIDeviceType_GarageDoorOpener_53_CLOSED;
                    break;
            }
            
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
        case SFIDeviceType_NestThermostat_57:
        case SFIDeviceType_NestSmokeDetector_58: {
            deviceValues = [value knownValuesForProperty:self.statePropertyType];
            if (deviceValues.hasValue) {
                [deviceValues setBoolValue:!deviceValues.boolValue];
            }
            break;
        }
            
        default: {
            // do nothing
        }
        case SFIDeviceType_UnknownDevice_0:
            break;
        case SFIDeviceType_Thermostat_7:
            break;
        case SFIDeviceType_Controller_8:
            break;
        case SFIDeviceType_SceneController_9:
            break;
        case SFIDeviceType_StandardCIE_10:
            break;
        case SFIDeviceType_MotionSensor_11:
            break;
        case SFIDeviceType_ContactSwitch_12:
            break;
        case SFIDeviceType_FireSensor_13:
            break;
        case SFIDeviceType_WaterSensor_14:
            break;
        case SFIDeviceType_GasSensor_15:
            break;
        case SFIDeviceType_PersonalEmergencyDevice_16:
            break;
        case SFIDeviceType_VibrationOrMovementSensor_17:
            break;
        case SFIDeviceType_RemoteControl_18:
            break;
        case SFIDeviceType_KeyFob_19:
            break;
        case SFIDeviceType_Keypad_20:
            break;
        case SFIDeviceType_OccupancySensor_24:
            break;
        case SFIDeviceType_LightSensor_25:
            break;
        case SFIDeviceType_WindowCovering_26:
            break;
        case SFIDeviceType_TemperatureSensor_27:
            break;
        case SFIDeviceType_ColorControl_29:
            break;
        case SFIDeviceType_PressureSensor_30:
            break;
        case SFIDeviceType_FlowSensor_31:
            break;
        case SFIDeviceType_ColorDimmableLight_32:
            break;
        case SFIDeviceType_HAPump_33:
            break;
        case SFIDeviceType_Shade_34:
            break;
        case SFIDeviceType_SmokeDetector_36:
            break;
        case SFIDeviceType_FloodSensor_37:
            break;
        case SFIDeviceType_ShockSensor_38:
            break;
        case SFIDeviceType_DoorSensor_39:
            break;
        case SFIDeviceType_MoistureSensor_40:
            break;
        case SFIDeviceType_MovementSensor_41:
            break;
        case SFIDeviceType_MultiSwitch_43:
            break;
        case SFIDeviceType_SetPointThermostat_46:
            break;
        case SFIDeviceType_51:
            break;
        case SFIDeviceType_RollerShutter_52:
            break;
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
