//
//  SFIDeviceKnownValues.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, SFIDevicePropertyType) {
    SFIDevicePropertyType_UNKNOWN = 0,
    SFIDevicePropertyType_AC_CURRENTDIVISOR,
    SFIDevicePropertyType_AC_CURRENTMULTIPLIER,
    SFIDevicePropertyType_AC_FREQUENCY,
    SFIDevicePropertyType_AC_FREQUENCYDIVISOR,
    SFIDevicePropertyType_AC_FREQUENCYMULTIPLIER,
    SFIDevicePropertyType_AC_POWERDIVISOR,
    SFIDevicePropertyType_AC_POWERMULTIPLIER,
    SFIDevicePropertyType_AC_VOLTAGEDIVISOR,
    SFIDevicePropertyType_AC_VOLTAGEMULTIPLIER,
    SFIDevicePropertyType_ACTIVE_POWER,
    SFIDevicePropertyType_ARMMODE,
    SFIDevicePropertyType_BASIC,
    SFIDevicePropertyType_BATTERY,
    SFIDevicePropertyType_COLOR_TEMPERATURE,
    SFIDevicePropertyType_CURRENT_POSITION,
    SFIDevicePropertyType_CURRENT_HUE,
    SFIDevicePropertyType_CURRENT_SATURATION,
    SFIDevicePropertyType_CURRENT_X,
    SFIDevicePropertyType_CURRENT_Y,
    SFIDevicePropertyType_CURRENTPOSITION_LIFT,
    SFIDevicePropertyType_CURRENTPOSITION_TILT,
    SFIDevicePropertyType_DC_CURRENT,
    SFIDevicePropertyType_DC_CURRENTDIVISOR,
    SFIDevicePropertyType_DC_CURRENTMULTIPLIER,
    SFIDevicePropertyType_DC_POWER,
    SFIDevicePropertyType_DC_POWERDIVISOR,
    SFIDevicePropertyType_DC_POWERMULTIPLIER,
    SFIDevicePropertyType_DC_VOLTAGE,
    SFIDevicePropertyType_DC_VOLTAGEDIVISOR,
    SFIDevicePropertyType_DC_VOLTAGEMULTIPLIER,
    SFIDevicePropertyType_EMER_ALARM,
    SFIDevicePropertyType_HUMIDITY,
    SFIDevicePropertyType_ILLUMINANCE,
    SFIDevicePropertyType_LOCK_CONF,
    SFIDevicePropertyType_LOCK_STATE,
    SFIDevicePropertyType_LOW_BATTERY,
    SFIDevicePropertyType_MAXIMUM_USERS,
    SFIDevicePropertyType_MEASURED_VALUE,
    SFIDevicePropertyType_METERING_DEVICETYPE,
    SFIDevicePropertyType_OCCUPANCY,
    SFIDevicePropertyType_PANIC_ALARM,
    SFIDevicePropertyType_RMS_CURRENT,
    SFIDevicePropertyType_RMS_VOLTAGE,
    SFIDevicePropertyType_SENSOR_BINARY,
    SFIDevicePropertyType_SENSOR_MULTILEVEL,
    SFIDevicePropertyType_STATE,
    SFIDevicePropertyType_STATUS,
    SFIDevicePropertyType_SWITCH_BINARY,
    SFIDevicePropertyType_SWITCH_MULTILEVEL,
    SFIDevicePropertyType_TAMPER,
    SFIDevicePropertyType_TEMPERATURE,
    SFIDevicePropertyType_THERMOSTAT_FAN_MODE,
    SFIDevicePropertyType_THERMOSTAT_FAN_STATE,
    SFIDevicePropertyType_THERMOSTAT_MODE,
    SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE,
    SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING,
    SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING,
    SFIDevicePropertyType_TOLERANCE
};

@interface SFIDeviceKnownValues : NSObject <NSCoding, NSCopying>

@property(nonatomic) unsigned int index;
@property(nonatomic) NSString *valueName;
@property(nonatomic) SFIDevicePropertyType propertyType;
@property(nonatomic) NSString *valueType;
@property(nonatomic) NSString *value;
@property(nonatomic) BOOL isUpdating;

// Converts the standard Device Property Name string into a type ID
+ (SFIDevicePropertyType)nameToPropertyType:(NSString *)valueName;

// true when a non-nil and non-empty value is present
- (BOOL)hasValue;

- (BOOL)boolValue;

- (int)intValue;

- (float)floatValue;

- (void)setIntValue:(int)value;

// Sets the value property with the appropriate string representation
- (void)setBoolValue:(BOOL)value;

// Interprets the value as a numeric (level switch)
- (BOOL)isZeroLevelValue;

- (id)choiceForLevelValueZeroValue:(id)aZeroVal nonZeroValue:(id)aNonZeroValue nilValue:(id)aNoneValue;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue nonNilValue:(id)aNonNilValue;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

@end
