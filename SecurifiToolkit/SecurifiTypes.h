//
// Created by Matthew Sinclair-Day on 1/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#ifndef SecurifiTypes_Header_h
#define SecurifiTypes_Header_h


// standard type used for ID values
typedef unsigned int sfi_id;

typedef NS_ENUM(unsigned int, SFIDeviceType) {
    SFIDeviceType_BinarySwitch_0                = 100,//this is for scenes Home/Away row
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
    SFIDeviceType_ZigbeeDoorLock_28             = 28,
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
    SFIDeviceType_SetPointThermostat_46         = 46,
    SFIDeviceType_HueLamp_48                    = 48,
    SFIDeviceType_MultiSensor_49                = 49,
    SFIDeviceType_SecurifiSmartSwitch_50        = 50,
    SFIDeviceType_51                            = 51,
    SFIDeviceType_RollerShutter_52              = 52,
    SFIDeviceType_GarageDoorOpener_53           = 53,
    SFIDeviceType_ZWtoACIRExtender_54           = 54,
    SFIDeviceType_MultiSoundSiren_55            = 55,
    SFIDeviceType_EnergyReader_56               = 56,
    SFIDeviceType_NestThermostat_57             = 57,
    SFIDeviceType_NestSmokeDetector_58          = 58,
    SFIDeviceType_BuiltInSiren_60               = 60,
    SFIDeviceType_WIFIClient                    = 500,//added for notifications for quick solution
    SFIDeviceType_REBOOT_ALMOND                 = 501,
    SFIDeviceType_Weather                       = 502,
    
    SFIDeviceType_count                         = 61, // always set to the last value; assumes sequence is continuous
};

// Converts a type into a standard mnemonic name suitable for event logging
NSString *securifi_name_to_device_type(SFIDeviceType type);

// ===========================================================================================================

typedef NS_ENUM(unsigned int, SFIDevicePropertyType) {
    SFIDevicePropertyType_UNKNOWN = 0,
    SFIDevicePropertyType_AC_CURRENTDIVISOR,
    SFIDevicePropertyType_AC_CURRENTMULTIPLIER,
    SFIDevicePropertyType_AC_FAN_MODE,
    SFIDevicePropertyType_AC_FREQUENCY,
    SFIDevicePropertyType_AC_FREQUENCYDIVISOR,
    SFIDevicePropertyType_AC_FREQUENCYMULTIPLIER,
    SFIDevicePropertyType_AC_MODE,
    SFIDevicePropertyType_AC_POWERDIVISOR,
    SFIDevicePropertyType_AC_POWERMULTIPLIER,
    SFIDevicePropertyType_AC_SETPOINT_HEATING,
    SFIDevicePropertyType_AC_SETPOINT_COOLING,
    SFIDevicePropertyType_AC_SWING,
    SFIDevicePropertyType_AC_VOLTAGEDIVISOR,
    SFIDevicePropertyType_AC_VOLTAGEMULTIPLIER,
    SFIDevicePropertyType_ACTIVE_POWER,
    SFIDevicePropertyType_ALARM_STATE,
    SFIDevicePropertyType_ARMMODE,
    SFIDevicePropertyType_BARRIER_OPERATOR,
    SFIDevicePropertyType_BASIC,
    SFIDevicePropertyType_BATTERY,
    SFIDevicePropertyType_BRIGHTNESS,
    SFIDevicePropertyType_COLOR_HUE,
    SFIDevicePropertyType_COLOR_TEMPERATURE,
    SFIDevicePropertyType_CONFIGURATION,
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
    SFIDevicePropertyType_ILLUMINANCE_PERCENT,
    SFIDevicePropertyType_IR_CODE,
    SFIDevicePropertyType_LOCK_CONF,
    SFIDevicePropertyType_LOCK_STATE,
    SFIDevicePropertyType_LOW_BATTERY,
    SFIDevicePropertyType_MAXIMUM_USERS,
    SFIDevicePropertyType_MEASURED_VALUE,
    SFIDevicePropertyType_METERING_DEVICETYPE,
    SFIDevicePropertyType_OCCUPANCY,
    SFIDevicePropertyType_PANIC_ALARM,
    SFIDevicePropertyType_POWER,
    SFIDevicePropertyType_RMS_CURRENT,
    SFIDevicePropertyType_RMS_VOLTAGE,
    SFIDevicePropertyType_SATURATION,
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
    SFIDevicePropertyType_THERMOSTAT_SETPOINT,
    SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING,
    SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING,
    SFIDevicePropertyType_TOLERANCE,
    SFIDevicePropertyType_UNITS,
    SFIDevicePropertyType_USER_CODE,
    SFIDevicePropertyType_CAN_COOL,//md01
    SFIDevicePropertyType_CAN_HEAT,//md01
    SFIDevicePropertyType_HAS_FAN,//md01
    SFIDevicePropertyType_NEST_ID,//md01
    SFIDevicePropertyType_CO_ALARM_STATE,//md01
    SFIDevicePropertyType_SMOKE_ALARM_STATE,//md01
    SFIDevicePropertyType_ISONLINE,//md01
    SFIDevicePropertyType_AWAY_MODE,//md01
    SFIDevicePropertyType_RESPONSE_CODE,//md01
    SFIDevicePropertyType_THERMOSTAT_TARGET,//md01
    SFIDevicePropertyType_THERMOSTAT_RANGE_LOW,//md01
    SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH,//md01
    SFIDevicePropertyType_CURRENT_TEMPERATURE,//md01
    SFIDevicePropertyType_IS_USING_EMERGENCY_HEAT,//md01
    SFIDevicePropertyType_HVAC_STATE,//md01
    SFIDevicePropertyType_HAS_LEAF,//md01
    SFIDevicePropertyType_NEST_THERMOSTAT_MODE,//md01
    SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE,//md01
    SFIDevicePropertyType_STOP,//md01
    SFIDevicePropertyType_UP_DOWN,//md01
    SFIDevicePropertyType_LUMINANCE_PERCENT,//md01
    SFIDevicePropertyType_ENERGY,//md01
    SFIDevicePropertyType_CLAMP1_POWER,//md01
    SFIDevicePropertyType_CLAMP1_ENERGY,//md01
    SFIDevicePropertyType_CLAMP2_POWER,//md01
    SFIDevicePropertyType_CLAMP2_ENERGY,//md01
    SFIDevicePropertyType_SWITCH_BINARY1,
    SFIDevicePropertyType_SWITCH_BINARY2,
    SFIDevicePropertyType_TONE_SELECTED, //mk
    SFIDevicePropertyType_REBOOT,
    SFIDevicePropertyType_count, // always keep this as the last one; provides a way to iterate through sequence
};

SFIDevicePropertyType securifi_name_to_property_type(NSString *valueName);

NSString *securifi_property_type_to_name(SFIDevicePropertyType propertyType);

// ===========================================================================================================

// Indicates whether communication with an Almond is being done through the Cloud or through a local connection
typedef NS_ENUM(unsigned int, SFIAlmondConnectionMode) {
    SFIAlmondConnectionMode_cloud,
    SFIAlmondConnectionMode_local
};

typedef NS_ENUM(unsigned int, SFIAlmondConnectionStatus) {
    SFIAlmondConnectionStatus_disconnected,     // link is down; default state on link instantiation and prior to bring-up
    SFIAlmondConnectionStatus_connecting,       // link in process of being established and authenticated
    SFIAlmondConnectionStatus_connected,        // link is established and normally operating
    SFIAlmondConnectionStatus_error,            // indicates connection error of some sort
    SFIAlmondConnectionStatus_error_mode,       // indicates that the almond is not compatible with the selected connection mode
};

// Per almond "mode" setting indicating
typedef NS_ENUM(unsigned int, SFIAlmondMode) {
    SFIAlmondMode_unknown           = 0,
    SFIAlmondMode_home              = 2,
    SFIAlmondMode_away              = 3,
};

// Per device notification preferences
typedef NS_ENUM(int, SFINotificationMode) {
    SFINotificationMode_unknown                 = -1,
    SFINotificationMode_off                     = 0,
    SFINotificationMode_always                  = 1,
    SFINotificationMode_home                    = 2,
    SFINotificationMode_away                    = 3,
};

#endif
