#import "SecurifiTypes.h"

NSString *securifi_name_to_device_type(SFIDeviceType type) {
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
        case SFIDeviceType_SetPointThermostat_46:return @"46_SetPointThermostat";
        case SFIDeviceType_HueLamp_48:return @"48_HueLamp";
        case SFIDeviceType_NestThermostat_57:return @"57_NestThermostat";
        case SFIDeviceType_NestSmokeDetector_58:return @"58_NestSmokeDetector";
        case SFIDeviceType_SecurifiSmartSwitch_50:return @"50_SecurifiSmartSwitch";
        case SFIDeviceType_51:return @"51_SFIDeviceType";
        case SFIDeviceType_RollerShutter_52:return @"52_RollerShutter";
        case SFIDeviceType_GarageDoorOpener_53:return @"53_GarageDoorOpener";
        default: return [NSString stringWithFormat:@"%d_UnknownDevice", type];
    }
}

NSDictionary *securifi_property_name_to_type_dictionary() {
    static NSDictionary *lookupTable;
    
    if (lookupTable == nil) {
        lookupTable = @{
                        // Normalize all names to upper case
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
                        @"ALARM_STATE" : @(SFIDevicePropertyType_ALARM_STATE),
                        @"ARMMODE" : @(SFIDevicePropertyType_ARMMODE),
                        @"BARRIER OPERATOR" : @(SFIDevicePropertyType_BARRIER_OPERATOR),
                        @"BASIC" : @(SFIDevicePropertyType_BASIC),
                        @"BATTERY" : @(SFIDevicePropertyType_BATTERY),
                        @"BRIGHTNESS" : @(SFIDevicePropertyType_BRIGHTNESS),
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
                        @"HUE" : @(SFIDevicePropertyType_COLOR_HUE),
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
                        @"POWER" : @(SFIDevicePropertyType_POWER),
                        @"RMS_CURRENT" : @(SFIDevicePropertyType_RMS_CURRENT),
                        @"RMS_VOLTAGE" : @(SFIDevicePropertyType_RMS_VOLTAGE),
                        @"SATURATION" : @(SFIDevicePropertyType_SATURATION),
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
                        @"THERMOSTAT SETPOINT" : @(SFIDevicePropertyType_THERMOSTAT_SETPOINT),
                        @"THERMOSTAT SETPOINT COOLING" : @(SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING),
                        @"THERMOSTAT SETPOINT HEATING" : @(SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING),
                        @"TOLERANCE" : @(SFIDevicePropertyType_TOLERANCE),
                        @"UNITS" : @(SFIDevicePropertyType_UNITS),
                        @"USER_CODE" : @(SFIDevicePropertyType_USER_CODE),
                        @"CAN_COOL" : @(SFIDevicePropertyType_CAN_COOL),//md01
                        @"CAN_HEAT" : @(SFIDevicePropertyType_CAN_HEAT),//md01
                        @"HAS_FAN" : @(SFIDevicePropertyType_HAS_FAN),//md01
                        @"NEST_ID" : @(SFIDevicePropertyType_NEST_ID),//md01
                        @"CO_ALARM_STATE" : @(SFIDevicePropertyType_CO_ALARM_STATE),//md01
                        @"SMOKE_ALARM_STATE" : @(SFIDevicePropertyType_SMOKE_ALARM_STATE),//md01
                        @"ISONLINE" : @(SFIDevicePropertyType_ISONLINE),//md01
                        @"AWAY_MODE" : @(SFIDevicePropertyType_AWAY_MODE),//md01
                        @"RESPONSE_CODE" : @(SFIDevicePropertyType_RESPONSE_CODE),//md01
                        @"THERMOSTAT_MODE" : @(SFIDevicePropertyType_NEST_THERMOSTAT_MODE),
                        @"THERMOSTAT_FAN_STATE" : @(SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE),
                        @"THERMOSTAT_TARGET" : @(SFIDevicePropertyType_THERMOSTAT_TARGET),//md01
                        @"THERMOSTAT_RANGE_LOW" : @(SFIDevicePropertyType_THERMOSTAT_RANGE_LOW),//md01
                        @"THERMOSTAT_RANGE_HIGH" : @(SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH),//md01
                        @"CURRENT_TEMPERATURE" : @(SFIDevicePropertyType_CURRENT_TEMPERATURE),//md01
                        @"IS_USING_EMERGENCY_HEAT" : @(SFIDevicePropertyType_IS_USING_EMERGENCY_HEAT),//md01
                        @"HVAC_STATE" : @(SFIDevicePropertyType_HVAC_STATE),//md01
                        @"HAS_LEAF" : @(SFIDevicePropertyType_HAS_LEAF),//md01
                        @"AC MODE" : @(SFIDevicePropertyType_AC_MODE),//md01
                        @"AC SETPOINT COOLING" : @(SFIDevicePropertyType_AC_SETPOINT_COOLING),//md01
                        @"AC SETPOINT HEATING" : @(SFIDevicePropertyType_AC_SETPOINT_HEATING),//md01
                        @"AC FAN MODE" : @(SFIDevicePropertyType_AC_FAN_MODE),//md01
                        @"CONFIGURATION" : @(SFIDevicePropertyType_CONFIGURATION),//md01
                        @"IR CODE" : @(SFIDevicePropertyType_IR_CODE),//md01
                        @"AC SWING" : @(SFIDevicePropertyType_AC_SWING),//md01
                        @"STOP" : @(SFIDevicePropertyType_STOP),//md01
                        @"UP_DOWN" : @(SFIDevicePropertyType_UP_DOWN),//md01
                        };
    }
    return
    lookupTable;
}

SFIDevicePropertyType securifi_name_to_property_type(NSString *valueName) {
    if (valueName == nil) {
        return SFIDevicePropertyType_UNKNOWN;
    }
    // normalize all names
    valueName = [valueName uppercaseString];
    
    NSDictionary *lookupTable = securifi_property_name_to_type_dictionary();
    
    NSNumber *o = lookupTable[valueName];
    if (!o) {
        return SFIDevicePropertyType_UNKNOWN;
    }
    return (SFIDevicePropertyType) [o intValue];
}

NSString *securifi_property_type_to_name(SFIDevicePropertyType propertyType) {
    static NSDictionary *lookupTable;
    
    if (lookupTable == nil) {
        NSDictionary *namesToType = securifi_property_name_to_type_dictionary();
        NSMutableDictionary *typeToName = [NSMutableDictionary dictionary];
        
        for (NSString *key in namesToType.allKeys) {
            NSNumber *value = namesToType[key];
            typeToName[value] = key;
        }
        
        lookupTable = [NSDictionary dictionaryWithDictionary:typeToName];
    }
    
    NSNumber *key = @(propertyType);
    return lookupTable[key];
}
