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

- (NSString *)imageName:(NSString *)defaultName {
    return self.imageName ? self.imageName : defaultName;
}

- (void)initializeFromValues:(SFIDeviceValue *)values {
    self.imageName = @"Reload_icon.png";

    if (values == nil) {
        return;
    }

    NSString *deviceValueTypeName;
    NSArray *currentKnownValues = values.knownValues;

    switch (self.deviceType) {
        case SFIDeviceType_BinarySwitch_1: {
            //            SFIDeviceKnownValues *curDeviceValues = currentKnownValues[0];
            break;
        }
        case SFIDeviceType_MultiLevelSwitch_2: {
            for (unsigned int index = 0; index < currentKnownValues.count; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:@"SWITCH MULTILEVEL"]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                    break;
                }
            }
            break;
        }
        case SFIDeviceType_BinarySensor_3: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues;
                curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:@"SENSOR BINARY"]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                    break;
                }
            }

            break;
        }
        case SFIDeviceType_MultiLevelOnOff_4: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues;
                curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:@"SWITCH BINARY"]) {
                    self.stateIndex = index;
                }
                else if ([deviceValueTypeName isEqualToString:@"SWITCH MULTILEVEL"]) {
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                }
            }
            break;
        }
        case SFIDeviceType_DoorLock_5: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:@"DOOR LOCK "]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                    break;
                }
            }
            break;
        }

        case SFIDeviceType_Alarm_6: {
            //Alarm : TODO Later
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:@"LOCK_STATE"]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                    break;
                }
            }
            break;
        }

        case SFIDeviceType_MotionSensor_11: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:STATE]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                }
                else if ([deviceValueTypeName isEqualToString:TAMPER]) {
                    self.isTampered = [curDeviceValues.value boolValue];
                    self.tamperValueIndex = index;
                }
                else if ([deviceValueTypeName isEqualToString:LOW_BATTERY]) {
                    self.isBatteryLow = [curDeviceValues.value boolValue];
                }
            }
            break;
        }

        case SFIDeviceType_ContactSwitch_12: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];

                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:STATE]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                }
                else if ([deviceValueTypeName isEqualToString:TAMPER]) {
                    self.isTampered = [curDeviceValues.value boolValue];
                    self.tamperValueIndex = index;
                }
                else if ([deviceValueTypeName isEqualToString:LOW_BATTERY]) {
                    self.isBatteryLow = [curDeviceValues.value boolValue];
                }
            }
            break;
        }

        case SFIDeviceType_FireSensor_13: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:STATE]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                }
                else if ([deviceValueTypeName isEqualToString:TAMPER]) {
                    self.isTampered = [curDeviceValues.value boolValue];
                    self.tamperValueIndex = index;
                }
                else if ([deviceValueTypeName isEqualToString:LOW_BATTERY]) {
                    self.isBatteryLow = [curDeviceValues.value boolValue];
                }
            }
            break;
        }

        case SFIDeviceType_WaterSensor_14: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:STATE]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                }
                else if ([deviceValueTypeName isEqualToString:TAMPER]) {
                    self.isTampered = [curDeviceValues.value boolValue];
                    self.tamperValueIndex = index;
                }
                else if ([deviceValueTypeName isEqualToString:LOW_BATTERY]) {
                    self.isBatteryLow = [curDeviceValues.value boolValue];
                }
            }
            break;
        }

        case SFIDeviceType_GasSensor_15: {
            //Gas Sensor
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:STATE]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                }
                else if ([deviceValueTypeName isEqualToString:TAMPER]) {
                    self.isTampered = [curDeviceValues.value boolValue];
                    self.tamperValueIndex = index;
                }
                else if ([deviceValueTypeName isEqualToString:LOW_BATTERY]) {
                    self.isBatteryLow = [curDeviceValues.value boolValue];
                }
            }
            break;
        }

        case SFIDeviceType_VibrationOrMovementSensor_17: {
            //Vibration Sensor
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:STATE]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                }
                else if ([deviceValueTypeName isEqualToString:TAMPER]) {
                    self.isTampered = [curDeviceValues.value boolValue];
                    self.tamperValueIndex = index;
                }
                else if ([deviceValueTypeName isEqualToString:LOW_BATTERY]) {
                    self.isBatteryLow = [curDeviceValues.value boolValue];
                }
            }
            break;
        }


        case SFIDeviceType_KeyFob_19: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:STATE]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                }
                else if ([deviceValueTypeName isEqualToString:TAMPER]) {
                    self.isTampered = [curDeviceValues.value boolValue];
                    self.tamperValueIndex = index;
                }
                else if ([deviceValueTypeName isEqualToString:LOW_BATTERY]) {
                    self.isBatteryLow = [curDeviceValues.value boolValue];
                }
            }

            break;
        }

        case SFIDeviceType_SmartACSwitch_22: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:@"SWITCH BINARY"]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                    break;
                }
            }
            break;
        }

        case SFIDeviceType_SmartDCSwitch_23: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:@"SWITCH BINARY"]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                    break;
                }
            }
            break;
        }

        case SFIDeviceType_Shade_34: {
            for (unsigned int index = 0; index < [currentKnownValues count]; index++) {
                SFIDeviceKnownValues *curDeviceValues = currentKnownValues[index];
                deviceValueTypeName = curDeviceValues.valueName;

                if ([deviceValueTypeName isEqualToString:@"SWITCH BINARY"]) {
                    self.stateIndex = index;
                    self.mostImpValueIndex = index;
                    self.mostImpValueName = deviceValueTypeName;
                    break;
                }
            }
            break;
        }

        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_Thermostat_7:
        case SFIDeviceType_Controller_8:
        case SFIDeviceType_SceneController_9:
        case SFIDeviceType_StandardCIE_10:
        case SFIDeviceType_PersonalEmergencyDevice_16:
        case SFIDeviceType_RemoteControl_18:
        case SFIDeviceType_Keypad_20:
        case SFIDeviceType_StandardWarningDevice_21:
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
        case SFIDeviceType_FloodSensor_37:
        case SFIDeviceType_ShockSensor_38:
        case SFIDeviceType_DoorSensor_39:
        case SFIDeviceType_MoistureSensor_40:
        case SFIDeviceType_MovementSensor_41:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_MultiSwitch_43:
        case SFIDeviceType_UnknownOnOffModule_44:
        default: {
            self.imageName = @"default_device.png";
            break;
        }
    };
}

- (BOOL)isTamperMostImportantValue {
    return [self.mostImpValueName isEqualToString:TAMPER];
}

@end
