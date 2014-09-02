//
//  SFIDeviceKnownValues.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDeviceKnownValues.h"

@implementation SFIDeviceKnownValues

+ (SFIDevicePropertyType) nameToPropertyType:(NSString*)valueName {
    static NSDictionary *lookupTable;

    if (lookupTable == nil) {
        lookupTable = @{
                @"AC_CURRENTDIVISOR" : @(SFIDevicePropertyType_AC_CURRENTDIVISOR),
                @"AC_CURRENTMULTIPLIER" : @(SFIDevicePropertyType_AC_CURRENTMULTIPLIER),
                @"AC_FREQUENCY" : @(SFIDevicePropertyType_AC_FREQUENCY),
                @"AC_FREQUENCYDIVISOR" : @(SFIDevicePropertyType_AC_FREQUENCYDIVISOR),
                @"AC_FREQUENCYMULTIPLIER" : @(SFIDevicePropertyType_AC_FREQUENCYMULTIPLIER),
                @"AC_POWERDIVISOR" : @(SFIDevicePropertyType_AC_POWERDIVISOR),
                @"AC_POWERMULTIPLIER" : @(SFIDevicePropertyType_AC_POWERMULTIPLIER),
                @"AC_VOLTAGEDIVISOR" : @(SFIDevicePropertyType_AC_VOLTAGEDIVISOR),
                @"AC_VOLTAGEMULTIPLIER" : @(SFIDevicePropertyType_AC_VOLTAGEMULTIPLIER),
                @"ACTIVE_POWER" : @(SFIDevicePropertyType_ACTIVE_POWER),
                @"ARMMODE" : @(SFIDevicePropertyType_ARMMODE),
                @"BASIC" : @(SFIDevicePropertyType_BASIC),
                @"BATTERY" : @(SFIDevicePropertyType_BATTERY),
                @"COLOR_TEMPERATURE" : @(SFIDevicePropertyType_COLOR_TEMPERATURE),
                @"CURRENT POSITION" : @(SFIDevicePropertyType_CURRENT_POSITION),
                @"CURRENT_HUE" : @(SFIDevicePropertyType_CURRENT_HUE),
                @"CURRENT_SATURATION" : @(SFIDevicePropertyType_CURRENT_SATURATION),
                @"CURRENT_X" : @(SFIDevicePropertyType_CURRENT_X),
                @"CURRENT_Y" : @(SFIDevicePropertyType_CURRENT_Y),
                @"CURRENTPOSITION-LIFT" : @(SFIDevicePropertyType_CURRENTPOSITION_LIFT),
                @"CURRENTPOSITION-TILT" : @(SFIDevicePropertyType_CURRENTPOSITION_TILT),
                @"DC_CURRENT" : @(SFIDevicePropertyType_DC_CURRENT),
                @"DC_CURRENTDIVISOR" : @(SFIDevicePropertyType_DC_CURRENTDIVISOR),
                @"DC_CURRENTMULTIPLIER" : @(SFIDevicePropertyType_DC_CURRENTMULTIPLIER),
                @"DC_POWER" : @(SFIDevicePropertyType_DC_POWER),
                @"DC_POWERDIVISOR" : @(SFIDevicePropertyType_DC_POWERDIVISOR),
                @"DC_POWERMULTIPLIER" : @(SFIDevicePropertyType_DC_POWERMULTIPLIER),
                @"DC_VOLTAGE" : @(SFIDevicePropertyType_DC_VOLTAGE),
                @"DC_VOLTAGEDIVISOR" : @(SFIDevicePropertyType_DC_VOLTAGEDIVISOR),
                @"DC_VOLTAGEMULTIPLIER" : @(SFIDevicePropertyType_DC_VOLTAGEMULTIPLIER),
                @"EMER_ALARM" : @(SFIDevicePropertyType_EMER_ALARM),
                @"HUMIDITY" : @(SFIDevicePropertyType_HUMIDITY),
                @"ILLUMINANCE" : @(SFIDevicePropertyType_ILLUMINANCE),
                @"LOCK_CONF" : @(SFIDevicePropertyType_LOCK_CONF),
                @"LOCK_STATE" : @(SFIDevicePropertyType_LOCK_STATE),
                @"LOW BATTERY" : @(SFIDevicePropertyType_LOW_BATTERY),
                @"MAXIMUM_USERS" : @(SFIDevicePropertyType_MAXIMUM_USERS),
                @"MEASURED_VALUE" : @(SFIDevicePropertyType_MEASURED_VALUE),
                @"METERING_DEVICETYPE" : @(SFIDevicePropertyType_METERING_DEVICETYPE),
                @"OCCUPANCY" : @(SFIDevicePropertyType_OCCUPANCY),
                @"PANIC_ALARM" : @(SFIDevicePropertyType_PANIC_ALARM),
                @"RMS_CURRENT" : @(SFIDevicePropertyType_RMS_CURRENT),
                @"RMS_VOLTAGE" : @(SFIDevicePropertyType_RMS_VOLTAGE),
                @"SENSOR BINARY" : @(SFIDevicePropertyType_SENSOR_BINARY),
                @"SENSOR MULTILEVEL" : @(SFIDevicePropertyType_SENSOR_MULTILEVEL),
                @"STATE" : @(SFIDevicePropertyType_STATE),
                @"STATUS" : @(SFIDevicePropertyType_STATUS),
                @"SWITCH BINARY" : @(SFIDevicePropertyType_SWITCH_BINARY),
                @"SWITCH MULTILEVEL" : @(SFIDevicePropertyType_SWITCH_MULTILEVEL),
                @"TAMPER" : @(SFIDevicePropertyType_TAMPER),
                @"TEMPERATURE" : @(SFIDevicePropertyType_TEMPERATURE),
                @"THERMOSTAT FAN MODE" : @(SFIDevicePropertyType_THERMOSTAT_FAN_MODE),
                @"THERMOSTAT FAN STATE" : @(SFIDevicePropertyType_THERMOSTAT_FAN_STATE),
                @"THERMOSTAT MODE" : @(SFIDevicePropertyType_THERMOSTAT_MODE),
                @"THERMOSTAT OPERATING STATE" : @(SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE),
                @"THERMOSTAT SETPOINT COOLING" : @(SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING),
                @"THERMOSTAT SETPOINT HEATING" : @(SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING),
                @"TOLERANCE" : @(SFIDevicePropertyType_TOLERANCE)
        };
    }

    NSNumber *o = lookupTable[valueName];
    if (!o) {
        return SFIDevicePropertyType_UNKNOWN;
    }
    return (SFIDevicePropertyType) [o intValue];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.index = (unsigned int) [coder decodeIntForKey:@"self.index"];
        self.valueName = [coder decodeObjectForKey:@"self.valueName"];
        self.propertyType = (SFIDevicePropertyType) [coder decodeIntForKey:@"self.propertyType"];
        self.valueType = [coder decodeObjectForKey:@"self.valueType"];
        self.value = [coder decodeObjectForKey:@"self.value"];
        self.isUpdating = [coder decodeBoolForKey:@"self.isUpdating"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.index forKey:@"self.index"];
    [coder encodeObject:self.valueName forKey:@"self.valueName"];
    [coder encodeInt:self.propertyType forKey:@"self.propertyType"];
    [coder encodeObject:self.valueType forKey:@"self.valueType"];
    [coder encodeObject:self.value forKey:@"self.value"];
    [coder encodeBool:self.isUpdating forKey:@"self.isUpdating"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.index=%u", self.index];
    [description appendFormat:@", self.valueName=%@", self.valueName];
    [description appendFormat:@", self.propertyType=%d", self.propertyType];
    [description appendFormat:@", self.valueType=%@", self.valueType];
    [description appendFormat:@", self.value=%@", self.value];
    [description appendFormat:@", self.isUpdating=%d", self.isUpdating];
    [description appendString:@">"];
    return description;
}


- (BOOL)hasValue {
    return self.value.length > 0;
}

- (BOOL)boolValue {
    return [self.value isEqualToString:@"true"];
}

- (int)intValue {
    return [self.value intValue];
}

- (float)floatValue {
    return [self.value floatValue];
}

- (void)setIntValue:(int)value {
    self.value = [NSString stringWithFormat:@"%d", value];
}

- (void)setBoolValue:(BOOL)value {
    if (value) {
        self.value = @"true";
    }
    else {
        self.value = @"false";
    }
}


- (BOOL)isZeroLevelValue {
    return [self.value isEqualToString:@"0"];
}

- (id)choiceForLevelValueZeroValue:(id)aZeroVal nonZeroValue:(id)aNonZeroValue nilValue:(id)aNoneValue {
    if (self.value == nil) {
        return aNoneValue;
    }
    if (self.isZeroLevelValue) {
        return aZeroVal;
    }
    return aNonZeroValue;
}


- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr {
    if ([self.value isEqualToString:@"true"]) {
        return aTrueStr;
    }
    return aFalseStr;
}

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue {
    if ([self.value isEqualToString:@"true"]) {
        return aTrueStr;
    }
    if ([self.value isEqualToString:@"false"]) {
        return aFalseStr;
    }
    return aNoneValue;
}


- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue nonNilValue:(NSString*)aNonNilValue {
    if ([self.value isEqualToString:@"true"]) {
        return aTrueStr;
    }
    if ([self.value isEqualToString:@"false"]) {
        return aFalseStr;
    }
    if (self.value == nil) {
        return aNoneValue;
    }
    return aNonNilValue;
}

- (id)copyWithZone:(NSZone *)zone {
    SFIDeviceKnownValues *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.index = self.index;
        copy.valueName = self.valueName;
        copy.propertyType = self.propertyType;
        copy.valueType = self.valueType;
        copy.value = self.value;
        copy.isUpdating = self.isUpdating;
    }

    return copy;
}

@end
