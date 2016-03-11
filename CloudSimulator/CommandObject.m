//
//  CommandObject.m
//  SecurifiToolkit
//
//  Created by Masood on 29/09/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "CommandObject.h"

@implementation CommandObject


//+ (NSDictionary *)dictionary;
//
//// Foo.m
//+ (NSDictionary *)dictionary {
//    static NSDictionary *fooDict = nil;
//    if (fooDict == nil) {
//        // create dict
//    }
//    return fooDict;
//}

+ (instancetype)sharedInstance
{
    static CommandObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CommandObject alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void)initializeTrueResponseDictionary{
    
    self.trueResponseDict = [[NSDictionary alloc] init];
    self.trueResponseDict = @{
                              @"LOGIN_COMMAND_TempPass" : @1,
                              @"LOGIN_COMMAND_Login" : @1,
                              @"LOGOUT_COMMAND" : @1,
                              @"LOGOUT_ALL_COMMAND" : @1,
                              @"SIGNUP_COMMAND" : @1,
                              @"VALIDATE_REQUEST" : @1,
                              @"RESET_PASSWORD_REQUEST" : @1,
                              @"AFFILIATION_CODE_REQUEST" : @1,
                              @"ALMOND_LIST" : @1,
                              @"DEVICE_DATA_HASH" : @1,
                              @"DEVICE_DATA" : @1,
                              @"DEVICE_VALUE" : @1,
                              @"MOBILE_COMMAND" : @1,
                              @"MOBILE_COMMAND_Dynamic" : @1,
                              @"MOBILE_COMMAND_AlmondNameChange" : @1,
                              @"MOBILE_COMMAND_SensorChangeRequest" : @1,
                              @"MOBILE_COMMAND_AlmondModeChangeRequest" : @1,
                              @"CLOUD_SANITY" : @1,
                              @"NOTIFICATION_PREFERENCE_LIST_REQUEST" : @1,
                              @"GENERIC_COMMAND_REQUEST" : @1,
                              @"CHANGE_PASSWORD_REQUEST" : @1,
                              @"DELETE_ACCOUNT_REQUEST" : @1,
                              @"USER_INVITE_REQUEST" : @1,
                              @"ALMOND_AFFILIATION_DATA_REQUEST" : @1,
                              @"USER_PROFILE_REQUEST" : @1,
                              @"UPDATE_USER_PROFILE_REQUEST" : @1,
                              @"ME_AS_SECONDARY_USER_REQUEST" : @1,
                              @"DELETE_SECONDARY_USER_REQUEST" : @1,
                              @"DELETE_ME_AS_SECONDARY_USER_REQUEST" : @1,
                              @"UNLINK_ALMOND_REQUEST" : @1,
                              @"NOTIFICATION_REGISTRATION" : @1,
                              @"NOTIFICATION_DEREGISTRATION" : @1,
                              @"ALMOND_MODE_REQUEST" : @1,
                              @"DEVICELOG_REQUEST" : @1,//no issuccessful
                              @"UPDATE_REQUEST_SetScene" : @1,
                              @"UPDATE_REQUEST_CreateScene" : @1,
                              @"UPDATE_REQUEST_DeleteScene" : @1,
                              @"UPDATE_REQUEST_ActivateScene" : @1,
                              @"DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE" : @1,
                              @"UPDATE_REQUEST_UpdateClient" : @1,
                              @"UPDATE_REQUEST_UpdateClient_Dynamic" : @1,
                              @"UPDATE_REQUEST_RemoveClient" : @1,
                              @"UPDATE_REQUEST_RemoveClient_Dynamic" : @1,
                              @"GET_ALL_SCENES" : @1,
                              @"WIFI_CLIENTS_LIST_REQUEST" : @1,
                              @"WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST" : @1,
                              @"WIFI_CLIENT_GET_PREFERENCE_REQUEST" : @1,
                              };
    static int var = 0;
    if(var == 0){
        var = 1;
        self.isTrueDictInitialized = NO;
    }
    return ;
}


-(NSMutableArray *)addDeviceData{
    NSMutableArray* Listarray = [[NSMutableArray alloc] init];
    // MULTILEVEL SWITCH
    [self storeDeviceData:1234 deviceType:SFIDeviceType_MultiLevelSwitch_2 deviceID:1 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Multilevel Switch" friendlyDeviceType:@"zeewave" deviceName:@"SWITCH MULTILEVEL" listarray:Listarray];
    
    //Binary sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_BinarySensor_3 deviceID:2 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"sensor" deviceTypeName:@"Binary Sensor" friendlyDeviceType:@"BinarySensor" deviceName:@"SENSOR BINARY" listarray:Listarray];
    
    //device 3 OnOffMultilevelSwitch
    [self storeDeviceData:1234 deviceType:SFIDeviceType_MultiLevelOnOff_4 deviceID:3 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:2 deviceFunction:@"switch" deviceTypeName:@"Switch Binary" friendlyDeviceType:@"BinarySwitch" deviceName:@"OnOffMultilevelSwitch" listarray:Listarray];
    
    //device 4 - Z-wave DoorLock
    [self storeDeviceData:1234 deviceType:SFIDeviceType_DoorLock_5 deviceID:4 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:2 deviceFunction:@"Lock" deviceTypeName:@"Lock Door" friendlyDeviceType:@"DoorLock" deviceName:@"Z-wave DoorLock" listarray:Listarray];
    
    //device 5 SFIDeviceType_Alarm_6
    [self storeDeviceData:1234 deviceType:SFIDeviceType_Alarm_6 deviceID:5 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Alarm" deviceTypeName:@"Alarm" friendlyDeviceType:@"Alarm" deviceName:@"myAlarm" listarray:Listarray];
    
    //device 6 SFIDeviceType_Thermostat_7
    [self storeDeviceData:1234 deviceType:SFIDeviceType_Thermostat_7 deviceID:6 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:7 deviceFunction:@"thermostat" deviceTypeName:@"thermostat" friendlyDeviceType:@"thermostat" deviceName:@"mythermostat:)" listarray:Listarray];
    //keyfob
    [self storeDeviceData:1234 deviceType:SFIDeviceType_KeyFob_19 deviceID:7 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"thermostat" deviceTypeName:@"Keyfob" friendlyDeviceType:@"keyfob" deviceName:@"KeyFob" listarray:Listarray];
    
    //device keypad
    [self storeDeviceData:1234 deviceType:SFIDeviceType_Keypad_20 deviceID:8 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"thermostat" deviceTypeName:@"Unknown Sensor" friendlyDeviceType:@"UnKnown Sensor" deviceName:@"UnKnown Sensor" listarray:Listarray];
    
    //device keypad
    [self storeDeviceData:1234 deviceType:SFIDeviceType_StandardWarningDevice_21 deviceID:9 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"thermostat" deviceTypeName:@"Alarm" friendlyDeviceType:@"Alarm" deviceName:@"Alarm" listarray:Listarray];
    
    //device smartACswitch
    
    [self storeDeviceData:1234 deviceType:SFIDeviceType_SmartACSwitch_22 deviceID:10 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"Alarm" deviceName:@"AC Switch" listarray:Listarray];
    
    
    //Occupancy sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_OccupancySensor_24 deviceID:11 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:3 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"Alarm" deviceName:@"Occupancy Sensor" listarray:Listarray];
    
    
    //Light sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_LightSensor_25 deviceID:12 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"Sensor" deviceName:@"Light Sensor" listarray:Listarray];
    
    //window covering
    [self storeDeviceData:1234 deviceType:SFIDeviceType_WindowCovering_26 deviceID:13 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"Window covering" deviceName:@"Window Covering" listarray:Listarray];
    
    //temparature sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_TemperatureSensor_27 deviceID:14 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:2 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"Window covering" deviceName:@"Temperature Sensor" listarray:Listarray];
    
    
    //temparature sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_ZigbeeDoorLock_28 deviceID:15 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:2 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"zigbeelock" deviceName:@"ZigbeeDoorLock" listarray:Listarray];
    
    
    //color control || PressureSensor ||FlowSensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_ColorControl_29 deviceID:16 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:5 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"zigbeelock" deviceName:@"color control" listarray:Listarray];
    
    //temparature sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_SmokeDetector_36 deviceID:17 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"zigbeelock" deviceName:@"Z-wave Smoke Sensor" listarray:Listarray];
    
    //temparature sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_FloodSensor_37 deviceID:18 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"Z-wave water" deviceName:@"Z-wave Water Sensor" listarray:Listarray];
    
    
    //vibration sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_ShockSensor_38 deviceID:19 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"Z-wave water" deviceName:@"Vibration Sensor" listarray:Listarray];
    
    
    
    //doorsensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_DoorSensor_39 deviceID:20 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"DoorSensor" friendlyDeviceType:@"BinarySensor" deviceName:@"Door Sensor" listarray:Listarray];
    
    //moisture sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_MoistureSensor_40 deviceID:21 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:2 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"Z-wave moisture" deviceName:@"Moisture Sensor" listarray:Listarray];
    
    
    //movement sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_MovementSensor_41 deviceID:22 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"Switch" friendlyDeviceType:@"Z-wave motion" deviceName:@"Motion Sensor" listarray:Listarray];
    
    //siren
    [self storeDeviceData:1234 deviceType:SFIDeviceType_Siren_42 deviceID:23 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"MultiSoundSiren" friendlyDeviceType:@"MultilevelSwitch" deviceName:@"Alarm" listarray:Listarray];
    
    //Binary Power Switch
    [self storeDeviceData:1234 deviceType:SFIDeviceType_BinaryPowerSwitch_45 deviceID:125 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:2 deviceFunction:@"Switch" deviceTypeName:@"BinaryPowerSwitch" friendlyDeviceType:@"BinaryPowerSwitch" deviceName:@"Binary Power Switch" listarray:Listarray];
    
    //hue lamp
    [self storeDeviceData:1234 deviceType:SFIDeviceType_HueLamp_48 deviceID:25 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:4 deviceFunction:@"Switch" deviceTypeName:@"HueLamp" friendlyDeviceType:@"HueLamp" deviceName:@"hue lamp" listarray:Listarray];
    
    //securifismartswitch
    [self storeDeviceData:1234 deviceType:SFIDeviceType_SecurifiSmartSwitch_50 deviceID:26 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SecurifiSmartSwitch" friendlyDeviceType:@"SecurifiSmartSwitch" deviceName:@"Securifismartswitch" listarray:Listarray];
    
    
    //garagedoor opener
    [self storeDeviceData:1234 deviceType:SFIDeviceType_GarageDoorOpener_53 deviceID:27 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"GarageDoorOpener" friendlyDeviceType:@"GarageDoorOpener" deviceName:@"GarageDoorOpener" listarray:Listarray];
    
    //nestTharmostat
    [self storeDeviceData:1234 deviceType:SFIDeviceType_NestThermostat_57 deviceID:128 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:7 deviceFunction:@"Switch" deviceTypeName:@"NestThermostat" friendlyDeviceType:@"NestThermostat" deviceName:@"NestThermostat" listarray:Listarray];
    
    //NestSmokeDetector
    [self storeDeviceData:1234 deviceType:SFIDeviceType_NestSmokeDetector_58 deviceID:29 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"NestSmokeDetector" friendlyDeviceType:@"NestSmokeDetector" deviceName:@"NestSmokeDetector" listarray:Listarray];
    
    //SWITCH BINARY
    [self storeDeviceData:1234 deviceType:SFIDeviceType_BinarySwitch_1 deviceID:30 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"SWITCH BINARY" deviceName:@"SWITCH BINARY" listarray:Listarray];
    
    //SFIDeviceType_Controller_8 || SFIDeviceType_SceneController_9 || SFIDeviceType_StandardCIE_10
    [self storeDeviceData:1234 deviceType:SFIDeviceType_StandardCIE_10 deviceID:31 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"SWITCH BINARY" deviceName:@"UnKnown Sensor" listarray:Listarray];
    
    
    //motionsensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_MotionSensor_11 deviceID:32 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"SWITCH BINARY" deviceName:@"Motion Sensor" listarray:Listarray];
    
    
    //contactswitch
    [self storeDeviceData:1234 deviceType:SFIDeviceType_ContactSwitch_12 deviceID:33 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"SWITCH BINARY" deviceName:@"Door Sensor" listarray:Listarray];
    
    
    //firesensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_FireSensor_13 deviceID:34 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"SWITCH BINARY" deviceName:@"Fire Sensor" listarray:Listarray];
    
    
    //water sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_WaterSensor_14 deviceID:35 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"Water Sensor" deviceName:@"Water Sensor" listarray:Listarray];
    
    
    //gas sensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_GasSensor_15 deviceID:36 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"Gas Sensor" deviceName:@"Gas Sensor" listarray:Listarray];
    
    
    //personal emergency
    [self storeDeviceData:1234 deviceType:SFIDeviceType_PersonalEmergencyDevice_16 deviceID:37 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"SWITCH BINARY" deviceName:@"emergency UnKnown Sensor" listarray:Listarray];
    
    
    //VibrationOrMovementSensor
    [self storeDeviceData:1234 deviceType:SFIDeviceType_VibrationOrMovementSensor_17 deviceID:38 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"Vibration Sensor" deviceName:@"Vibration Sensor" listarray:Listarray];
    
    //remote control
    [self storeDeviceData:1234 deviceType:SFIDeviceType_RemoteControl_18 deviceID:39 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"Switch" deviceTypeName:@"SWITCH BINARY" friendlyDeviceType:@"Vibration Sensor" deviceName:@"remote UnKnown Sensor" listarray:Listarray];
    
    return Listarray;
}

-(NSMutableArray*)addDeviceValues{
    //device 1
    SFIDeviceKnownValues *knownvalues1=[[SFIDeviceKnownValues alloc]init];
    knownvalues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:[NSString stringWithFormat:@"%d",2]];
    NSArray *knownvaluearray=[[NSArray alloc]initWithObjects:knownvalues1, nil];
    SFIDeviceValue *devicevalue = [self createDeviceValue:(unsigned int)1 deviceID:(unsigned int)1 isPresent:(BOOL)NO knownValueArray:knownvaluearray];
    
    //device 2
    SFIDeviceKnownValues *knownvalues2=[[SFIDeviceKnownValues alloc]init];
    knownvalues2 =[self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"true"];
    NSArray *knownvaluearray2=[[NSArray alloc]initWithObjects:knownvalues2 ,nil];
    SFIDeviceValue *devicevalue2=[self createDeviceValue:(unsigned int)1 deviceID:(unsigned int)2 isPresent:(BOOL)NO knownValueArray:knownvaluearray2];
    
    //device 3
    SFIDeviceKnownValues *knownvalues3=[[SFIDeviceKnownValues alloc]init];
    knownvalues3=[self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SENSOR MULTILEVEL" value_:@"150"];
    SFIDeviceKnownValues *knownvalues4=[[SFIDeviceKnownValues alloc]init];
    knownvalues4 =[self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    NSArray *knownvaluearray3=[[NSArray alloc]initWithObjects:knownvalues3 ,knownvalues4, nil];
    
    SFIDeviceValue *devicevalue3=[self createDeviceValue:(unsigned int)2 deviceID:(unsigned int)3 isPresent:(BOOL)NO knownValueArray:knownvaluearray3];
    
    //device 4
    SFIDeviceKnownValues *doorLockKnownValues=[[SFIDeviceKnownValues alloc]init];
    doorLockKnownValues =[self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_LOCK_STATE valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:@"90"];
    NSArray *doorLockKnownValuesArray=[[NSArray alloc]initWithObjects:doorLockKnownValues ,nil];
    SFIDeviceValue *doorLockDeviceValue=[self createDeviceValue:(unsigned int)1 deviceID:(unsigned int)4 isPresent:(BOOL)NO knownValueArray:doorLockKnownValuesArray];
    
    //device 5
    SFIDeviceKnownValues *alarmKnownValues=[[SFIDeviceKnownValues alloc]init];
    alarmKnownValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"mystate" valuename_:@"abcd" value_:@"50"];
    NSArray *alarmKnownValuesArray=[[NSArray alloc]initWithObjects:alarmKnownValues, nil];
    SFIDeviceValue *alarmDeviceValue=[self createDeviceValue:(unsigned int)1 deviceID:(unsigned int)5 isPresent:(BOOL)NO knownValueArray:alarmKnownValuesArray];
    
    //device 6 thermostat
    SFIDeviceKnownValues *thermoKnowsvalues1=[[SFIDeviceKnownValues alloc]init];
    
    thermoKnowsvalues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_MULTILEVEL valuetype_:@"STATE" valuename_:@"SENSOR MULTILEVEL" value_:@"15"];
    
    SFIDeviceKnownValues *thermoKnowsvalues2=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"THERMOSTAT OPERATING STATE" value_:@"Heating"];
    
    SFIDeviceKnownValues *thermoKnowsvalues3=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT SETPOINT COOLING" value_:@"70"];
    
    SFIDeviceKnownValues *thermoKnowsvalues4=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues4 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT" value_:@"57"];
    
    SFIDeviceKnownValues *thermoKnowsvalues5=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues5 =[self createKnownValuesWithIndex:5 PropertyType_:SFIDevicePropertyType_THERMOSTAT_MODE valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT" value_:@"Auto"];
    
    SFIDeviceKnownValues *thermoKnowsvalues6=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues6 =[self createKnownValuesWithIndex:6 PropertyType_:SFIDevicePropertyType_THERMOSTAT_FAN_MODE valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT FAN MODE" value_:@"Auto"];
    
    SFIDeviceKnownValues *thermoKnowsvalues7=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues7 = [self createKnownValuesWithIndex:7 PropertyType_:SFIDevicePropertyType_THERMOSTAT_FAN_STATE valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT FAN STAT" value_:@"On"];
    
    
    NSArray *thermostatKnowsValuesArray =[[NSArray alloc]initWithObjects: thermoKnowsvalues1,thermoKnowsvalues2 ,thermoKnowsvalues3,thermoKnowsvalues4,thermoKnowsvalues5,thermoKnowsvalues6,thermoKnowsvalues7,nil];
    SFIDeviceValue *thermodevicevalue=[self createDeviceValue:7 deviceID:6 isPresent:NO knownValueArray:thermostatKnowsValuesArray];
    
    //device keyFob
    
    SFIDeviceKnownValues *KeyfobKnownValues=[[SFIDeviceKnownValues alloc]init];
    KeyfobKnownValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_ARMMODE valuetype_:@"STATE" valuename_:@"ARMMODE" value_:@"2"];
    
    NSArray *keyFobKnownValuesArray=[[NSArray alloc]initWithObjects:KeyfobKnownValues, nil];
    
    SFIDeviceValue *keyFobDeviceValue=[self createDeviceValue:1 deviceID:7 isPresent:YES knownValueArray:keyFobKnownValuesArray];
    
    //device keyPad
    
    SFIDeviceKnownValues *KeyPadKnownValues=[[SFIDeviceKnownValues alloc]init];
    KeyPadKnownValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *keyPadKnownValuesArray=[[NSArray alloc]initWithObjects:KeyPadKnownValues, nil];
    
    SFIDeviceValue *keyPadDeviceValue=[self createDeviceValue:1 deviceID:8 isPresent:NO knownValueArray:keyPadKnownValuesArray];
    
    //device warningdevice
    
    SFIDeviceKnownValues *WarningdeviceValues=[[SFIDeviceKnownValues alloc]init];
    WarningdeviceValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_ALARM_STATE valuetype_:@"ALARM_STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *warningdeviceValuesArray=[[NSArray alloc]initWithObjects:WarningdeviceValues, nil];
    
    SFIDeviceValue *warningDeviceValue=[self createDeviceValue:1 deviceID:9 isPresent:NO knownValueArray:warningdeviceValuesArray];
    
    //light sensor
    
    SFIDeviceKnownValues *lightsensorValues=[[SFIDeviceKnownValues alloc]init];
    lightsensorValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_ILLUMINANCE valuetype_:@"STATE" valuename_:@"ILLUMINANCE" value_:@"true"];
    
    NSArray *lightsensordeviceValuesArray=[[NSArray alloc]initWithObjects:lightsensorValues, nil];
    
    SFIDeviceValue *lightsensorDeviceValue=[[SFIDeviceValue alloc]init];
    lightsensorDeviceValue=[self createDeviceValue:1 deviceID:12 isPresent:NO knownValueArray:lightsensordeviceValuesArray];
    
    //windowcovering
    
    SFIDeviceKnownValues *windowcovering=[[SFIDeviceKnownValues alloc]init];
    windowcovering = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *windowcoverdeviceValuesArray=[[NSArray alloc]initWithObjects:windowcovering, nil];
    
    SFIDeviceValue *windowcoverDeviceValue=[[SFIDeviceValue alloc]init];
    windowcoverDeviceValue=[self createDeviceValue:1 deviceID:13 isPresent:NO knownValueArray:windowcoverdeviceValuesArray];
    
    //temperature sensor
    
    SFIDeviceKnownValues *temperaturesensor1=[[SFIDeviceKnownValues alloc]init];
    temperaturesensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"TEMPERATURE" value_:@"20"];
    
    SFIDeviceKnownValues *temperaturesensor2=[[SFIDeviceKnownValues alloc]init];
    temperaturesensor2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_HUMIDITY valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"HUMIDITY" value_:@"42"];
    
    NSArray *temperaturesensordeviceValuesArray=[[NSArray alloc]initWithObjects:temperaturesensor1, temperaturesensor2,nil];
    
    SFIDeviceValue *temperaturesensorDeviceValue=[self createDeviceValue:2 deviceID:14 isPresent:NO knownValueArray:temperaturesensordeviceValuesArray];
    
    //zigbee door lock
    
    SFIDeviceKnownValues *zigbeedoorlock1=[[SFIDeviceKnownValues alloc]init];
    zigbeedoorlock1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_LOCK_STATE valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:@"0"];
    
    SFIDeviceKnownValues *zigbeedoorlock2=[[SFIDeviceKnownValues alloc]init];
    zigbeedoorlock2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_USER_CODE valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:nil];
    
    NSArray *zigbeedeviceValuesArray=[[NSArray alloc]initWithObjects:zigbeedoorlock1, zigbeedoorlock2,nil];
    
    SFIDeviceValue *zigbeeDeviceValue=[self createDeviceValue:2 deviceID:15 isPresent:NO knownValueArray:zigbeedeviceValuesArray];
    
    //color control
    
    SFIDeviceKnownValues *colorcontrol1=[[SFIDeviceKnownValues alloc]init];
    colorcontrol1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    
    
    SFIDeviceKnownValues *colorcontrol2=[[SFIDeviceKnownValues alloc]init];
    colorcontrol2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_CURRENT_HUE valuetype_:@"STATE" valuename_:@"HUE" value_:@"20"];
    SFIDeviceKnownValues *colorcontrol3=[[SFIDeviceKnownValues alloc]init];
    colorcontrol3 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:@"90"];
    
    
    SFIDeviceKnownValues *colorcontrol4=[[SFIDeviceKnownValues alloc]init];
    colorcontrol4 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_COLOR_TEMPERATURE valuetype_:@"STATE" valuename_:@"COLOR_TEMPERATURE" value_:@"34"];
    
    SFIDeviceKnownValues *colorcontrol5=[[SFIDeviceKnownValues alloc]init];
    colorcontrol5 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_CURRENT_SATURATION valuetype_:@"STATE" valuename_:@"COLOR_TEMPERATURE" value_:@"34"];
    
    NSArray *colorcontroldeviceValuesArray=[[NSArray alloc]initWithObjects:colorcontrol1,colorcontrol2, colorcontrol3,colorcontrol4,colorcontrol5,nil];
    
    SFIDeviceValue *colorcontrolDeviceValue=[self createDeviceValue:(int)[colorcontroldeviceValuesArray count] deviceID:16 isPresent:NO knownValueArray:colorcontroldeviceValuesArray];
    
    //smoke dector
    
    SFIDeviceKnownValues *smokedetector=[[SFIDeviceKnownValues alloc]init];
    smokedetector = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BASIC" value_:@"20"];
    
    NSArray *smaokedectorValuesArray=[[NSArray alloc]initWithObjects:smokedetector,nil];
    
    SFIDeviceValue *smaokedectorDeviceValue=[self createDeviceValue:1 deviceID:17 isPresent:NO knownValueArray:smaokedectorValuesArray];
    
    //flood dector
    SFIDeviceKnownValues *floodsensor=[[SFIDeviceKnownValues alloc]init];
    floodsensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BASIC" value_:@"20"];
    
    NSArray *floodsensorValuesArray=[[NSArray alloc]initWithObjects:floodsensor,nil];
    
    SFIDeviceValue *floodsensorDeviceValue=[self createDeviceValue:1 deviceID:18 isPresent:NO knownValueArray:floodsensorValuesArray];
    
    //vibration dector
    
    SFIDeviceKnownValues *shocksensor=[[SFIDeviceKnownValues alloc]init];
    shocksensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"false"];
    
    NSArray *shocksensorValuesArray=[[NSArray alloc]initWithObjects:shocksensor,nil];
    
    SFIDeviceValue *shocksensorDeviceValue=[self createDeviceValue:1 deviceID:19 isPresent:NO knownValueArray:shocksensorValuesArray];
    
    //door sensor
    
    SFIDeviceKnownValues *doorsensor=[[SFIDeviceKnownValues alloc]init];
    doorsensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"false"];
    NSArray *doorsensorValuesArray=[[NSArray alloc]initWithObjects:doorsensor,nil];
    
    SFIDeviceValue *doorsensorDeviceValue=[self createDeviceValue:1 deviceID:20 isPresent:NO knownValueArray:doorsensorValuesArray];
    
    //moisture sensor
    
    SFIDeviceKnownValues *moisturesensor=[[SFIDeviceKnownValues alloc]init];
    moisturesensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BASIC" value_:@"10"];
    
    SFIDeviceKnownValues *moisturesensor1=[[SFIDeviceKnownValues alloc]init];
    moisturesensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"TEMPERATURE" value_:@"20"];
    
    NSArray *moisturesensorValuesArray=[[NSArray alloc]initWithObjects:moisturesensor,nil];
    
    SFIDeviceValue *moisturesensorDeviceValue=[self createDeviceValue:2 deviceID:21 isPresent:NO knownValueArray:moisturesensorValuesArray];
    
    //motion sensor
    
    SFIDeviceKnownValues *motionsensor=[[SFIDeviceKnownValues alloc]init];
    motionsensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"false"];
    NSArray *motionsensorValuesArray=[[NSArray alloc]initWithObjects:motionsensor,nil];
    
    SFIDeviceValue *motionsensorDeviceValue=[self createDeviceValue:1 deviceID:22 isPresent:NO knownValueArray:motionsensorValuesArray];
    
    //siren
    
    SFIDeviceKnownValues *siren=[[SFIDeviceKnownValues alloc]init];
    siren = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"false"];
    NSArray *sirenValuesArray=[[NSArray alloc]initWithObjects:siren,nil];
    
    SFIDeviceValue *sirenDeviceValue=[self createDeviceValue:1 deviceID:23 isPresent:NO knownValueArray:sirenValuesArray];
    //binary power switch
    
    SFIDeviceKnownValues *PowerswitchValues=[[SFIDeviceKnownValues alloc]init];
    PowerswitchValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    
    SFIDeviceKnownValues *PowerswitchValues1=[[SFIDeviceKnownValues alloc]init];
    PowerswitchValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_POWER valuetype_:@"POWER" valuename_:@"PRIMARY ATTRIBUTE" value_:@"10"];
    
    NSArray *powerswitchValuesArray=[[NSArray alloc]initWithObjects:PowerswitchValues,PowerswitchValues1, nil];
    
    SFIDeviceValue *powerswitchDeviceValue=[[SFIDeviceValue alloc]init];
    powerswitchDeviceValue=[self createDeviceValue:2 deviceID:125 isPresent:NO knownValueArray:powerswitchValuesArray];
    
    
    //hue lamp
    
    SFIDeviceKnownValues *huelampValues1=[[SFIDeviceKnownValues alloc]init];
    huelampValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    
    SFIDeviceKnownValues *huelampValues2=[[SFIDeviceKnownValues alloc]init];
    huelampValues2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_COLOR_HUE valuetype_:@"POWER" valuename_:@"HUE" value_:@"10"];
    SFIDeviceKnownValues *huelampValues3=[[SFIDeviceKnownValues alloc]init];
    huelampValues3 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SATURATION valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    
    SFIDeviceKnownValues *huelampValues4=[[SFIDeviceKnownValues alloc]init];
    huelampValues4 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"POWER" valuename_:@"PRIMARY ATTRIBUTE" value_:@"10"];
    
    NSArray *hueValuesArray=[[NSArray alloc]initWithObjects:huelampValues1,huelampValues2,huelampValues3,huelampValues4, nil];
    
    SFIDeviceValue *huebulbDeviceValue=[[SFIDeviceValue alloc]init];
    huebulbDeviceValue=[self createDeviceValue:2 deviceID:25 isPresent:NO knownValueArray:hueValuesArray];
    
    
    //securifi smartswitch
    
    SFIDeviceKnownValues *SFIswitchValues1=[[SFIDeviceKnownValues alloc]init];
    SFIswitchValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    
    
    NSArray *SFIswitchValuesArray=[[NSArray alloc]initWithObjects:SFIswitchValues1,nil];
    
    SFIDeviceValue *SFIswitchDeviceValue=[[SFIDeviceValue alloc]init];
    SFIswitchDeviceValue=[self createDeviceValue:1 deviceID:26 isPresent:NO knownValueArray:SFIswitchValuesArray];
    
    
    //garage door opener
    
    SFIDeviceKnownValues *garagedooropenerValues1=[[SFIDeviceKnownValues alloc]init];
    garagedooropenerValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BARRIER_OPERATOR valuetype_:@"STATE" valuename_:@"BARRIER OPERATOR" value_:@"true"];
    
    
    
    NSArray *garageopenerValuesArray=[[NSArray alloc]initWithObjects:garagedooropenerValues1,nil];
    
    SFIDeviceValue *garagedooropenerDeviceValue=[[SFIDeviceValue alloc]init];
    garagedooropenerDeviceValue=[self createDeviceValue:1 deviceID:27 isPresent:NO knownValueArray:garageopenerValuesArray];
    
    //nesttharmostat
    
    SFIDeviceKnownValues *nesttharmostatValues1=[[SFIDeviceKnownValues alloc]init];
    nesttharmostatValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT_MODE" value_:@"heat"];
    SFIDeviceKnownValues *nesttharmostatValues2=[[SFIDeviceKnownValues alloc]init];
    nesttharmostatValues2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_AWAY_MODE valuetype_:@"STATE" valuename_:@"AWAY_MODE" value_:@"home"];
    
    SFIDeviceKnownValues *nesttharmostatValues3=[[SFIDeviceKnownValues alloc]init];
    nesttharmostatValues3 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_THERMOSTAT_TARGET valuetype_:@"STATE" valuename_:@"THERMOSTAT_TARGET" value_:@"10"];
    
    SFIDeviceKnownValues *nesttharmostatValues4=[[SFIDeviceKnownValues alloc]init];
    nesttharmostatValues4 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_RESPONSE_CODE valuetype_:@"STATE" valuename_:@"THERMOSTAT_RESPONSE_CODE" value_:@"true"];
    
    SFIDeviceKnownValues *nesttharmostatValues5=[[SFIDeviceKnownValues alloc]init];
    nesttharmostatValues5 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_THERMOSTAT_RANGE_LOW valuetype_:@"STATE" valuename_:@"THERMOSTAT_RANGE_LOW" value_:@"20"];
    
    SFIDeviceKnownValues *nesttharmostatValues6=[[SFIDeviceKnownValues alloc]init];
    nesttharmostatValues6 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH valuetype_:@"STATE" valuename_:@"THERMOSTAT_RANGE_HIGH" value_:@"10"];
    
    SFIDeviceKnownValues *nesttharmostatValues7=[[SFIDeviceKnownValues alloc]init];
    nesttharmostatValues7 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"TEMPERATURE" value_:@"70"];
    
    
    NSArray *nesttharmostatValuesArray=[[NSArray alloc]initWithObjects:nesttharmostatValues1,nesttharmostatValues2,nesttharmostatValues3,nesttharmostatValues4,nesttharmostatValues5,nesttharmostatValues6,nesttharmostatValues7,nil];
    
    SFIDeviceValue *nesttharmostatDeviceValue=[[SFIDeviceValue alloc]init];
    nesttharmostatDeviceValue=[self createDeviceValue:1 deviceID:128 isPresent:NO knownValueArray:nesttharmostatValuesArray];
    
    //nest smoke detector
    
    SFIDeviceKnownValues *nestsmokedetector1=[[SFIDeviceKnownValues alloc]init];
    nestsmokedetector1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_RESPONSE_CODE valuetype_:@"STATE" valuename_:@"RESPONSE_CODE" value_:@"70"];
    
    SFIDeviceKnownValues *nestsmokedetector2=[[SFIDeviceKnownValues alloc]init];
    nestsmokedetector2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_AWAY_MODE valuetype_:@"STATE" valuename_:@"AWAY_MODE" value_:@"home"];
    
    NSArray *nestsmokedetectorValuesArray=[[NSArray alloc]initWithObjects:nestsmokedetector1,nil];
    
    SFIDeviceValue *nestsmokedetectorDeviceValue=[[SFIDeviceValue alloc]init];
    nestsmokedetectorDeviceValue=[self createDeviceValue:1 deviceID:28 isPresent:NO knownValueArray:nestsmokedetectorValuesArray];
    
    
    //device smatACswitch
    
    SFIDeviceKnownValues *SmartAcdeviceValues=[[SFIDeviceKnownValues alloc]init];
    SmartAcdeviceValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    
    NSArray *SmartACdeviceValuesArray=[[NSArray alloc]initWithObjects:SmartAcdeviceValues, nil];
    
    SFIDeviceValue *SmartACDeviceValue=[self createDeviceValue:1 deviceID:10 isPresent:NO knownValueArray:SmartACdeviceValuesArray];
    
    //occupancy sensor
    SFIDeviceKnownValues *occupancydevicevalues1=[[SFIDeviceKnownValues alloc]init];
    occupancydevicevalues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_OCCUPANCY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    
    SFIDeviceKnownValues *occupancydevicevalues2=[[SFIDeviceKnownValues alloc]init];
    occupancydevicevalues2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"20"];
    
    SFIDeviceKnownValues *occupancydevicevalues3=[[SFIDeviceKnownValues alloc]init];
    occupancydevicevalues3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_HUMIDITY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"28"];
    
    NSArray *OccupancyValuesArray=[[NSArray alloc]initWithObjects:occupancydevicevalues1, occupancydevicevalues2,occupancydevicevalues3,nil];
    
    SFIDeviceValue *occupancydevicevalue=[self createDeviceValue:3 deviceID:11 isPresent:NO knownValueArray:OccupancyValuesArray];
    
    //switch binary
    
    SFIDeviceKnownValues *switchbinary1=[[SFIDeviceKnownValues alloc]init];
    switchbinary1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    
    NSArray *switchbinaryValuesArray=[[NSArray alloc]initWithObjects:switchbinary1,nil];
    
    SFIDeviceValue *switchbinaryDeviceValue=[[SFIDeviceValue alloc]init];
    switchbinaryDeviceValue=[self createDeviceValue:1 deviceID:30 isPresent:NO knownValueArray:switchbinaryValuesArray];
    
    //standardICE
    
    SFIDeviceKnownValues *standardICE=[[SFIDeviceKnownValues alloc]init];
    standardICE = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *standardICEValuesArray=[[NSArray alloc]initWithObjects:standardICE,nil];
    
    SFIDeviceValue *standardICEDeviceValue=[[SFIDeviceValue alloc]init];
    standardICEDeviceValue=[self createDeviceValue:1 deviceID:31 isPresent:NO knownValueArray:standardICEValuesArray];
    
    //motion sensor
    
    SFIDeviceKnownValues *motionsensorvalue=[[SFIDeviceKnownValues alloc]init];
    motionsensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *motionsensorvaluesArray=[[NSArray alloc]initWithObjects:motionsensorvalue,nil];
    
    SFIDeviceValue *motionsensorDeviceValue1=[[SFIDeviceValue alloc]init];
    motionsensorDeviceValue1=[self createDeviceValue:1 deviceID:32 isPresent:NO knownValueArray:motionsensorvaluesArray];
    
    //contact switch
    
    SFIDeviceKnownValues *contactswitcvalue=[[SFIDeviceKnownValues alloc]init];
    contactswitcvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *contactswitcvaluesArray=[[NSArray alloc]initWithObjects:contactswitcvalue,nil];
    
    SFIDeviceValue *contactswitcDeviceValue=[[SFIDeviceValue alloc]init];
    contactswitcDeviceValue=[self createDeviceValue:1 deviceID:33 isPresent:NO knownValueArray:contactswitcvaluesArray];
    
    //fire sensor
    
    SFIDeviceKnownValues *firesensorvalue=[[SFIDeviceKnownValues alloc]init];
    firesensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *firesensorvaluevaluesArray=[[NSArray alloc]initWithObjects:firesensorvalue,nil];
    
    SFIDeviceValue *firesensorvalueDeviceValue=[[SFIDeviceValue alloc]init];
    firesensorvalueDeviceValue=[self createDeviceValue:1 deviceID:34 isPresent:NO knownValueArray:firesensorvaluevaluesArray];
    
    //water sensor
    
    SFIDeviceKnownValues *watersensorvalue=[[SFIDeviceKnownValues alloc]init];
    watersensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *watersensorvaluevaluesArray=[[NSArray alloc]initWithObjects:watersensorvalue,nil];
    
    SFIDeviceValue *watersensorvalueDeviceValue=[[SFIDeviceValue alloc]init];
    watersensorvalueDeviceValue=[self createDeviceValue:1 deviceID:35 isPresent:NO knownValueArray:watersensorvaluevaluesArray];
    
    
    //gas sensor
    SFIDeviceKnownValues *gassensorvalue=[[SFIDeviceKnownValues alloc]init];
    gassensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *gassensorvaluesArray=[[NSArray alloc]initWithObjects:gassensorvalue,nil];
    
    SFIDeviceValue *gassensorDeviceValue1=[[SFIDeviceValue alloc]init];
    gassensorDeviceValue1=[self createDeviceValue:1 deviceID:36 isPresent:NO knownValueArray:gassensorvaluesArray];
    
    //PersonalEmergencyDevice
    
    SFIDeviceKnownValues *PersonalEmergencyDevicevalue=[[SFIDeviceKnownValues alloc]init];
    PersonalEmergencyDevicevalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *PersonalEmergencyvaluesArray=[[NSArray alloc]initWithObjects:PersonalEmergencyDevicevalue,nil];
    
    SFIDeviceValue *PersonalEmergencyDeviceValue1=[[SFIDeviceValue alloc]init];
    PersonalEmergencyDeviceValue1=[self createDeviceValue:1 deviceID:37 isPresent:NO knownValueArray:PersonalEmergencyvaluesArray];
    
    //VibrationOrMovementSensor
    
    SFIDeviceKnownValues *VibrationOrMovementSensorsensorvalue=[[SFIDeviceKnownValues alloc]init];
    VibrationOrMovementSensorsensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *VibrationOrMovementSensorsensorvaluesArray=[[NSArray alloc]initWithObjects:VibrationOrMovementSensorsensorvalue,nil];
    
    SFIDeviceValue *VibrationOrMovementSensorsensorDeviceValue1=[[SFIDeviceValue alloc]init];
    VibrationOrMovementSensorsensorDeviceValue1=[self createDeviceValue:1 deviceID:38 isPresent:NO knownValueArray:VibrationOrMovementSensorsensorvaluesArray];
    
    //remotecontroler
    
    SFIDeviceKnownValues *remotecontrolervalue=[[SFIDeviceKnownValues alloc]init];
    remotecontrolervalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *remotecontrolervaluesArray=[[NSArray alloc]initWithObjects:remotecontrolervalue,nil];
    
    SFIDeviceValue *remotecontrolerDeviceValue1=[[SFIDeviceValue alloc]init];
    remotecontrolerDeviceValue1=[self createDeviceValue:1 deviceID:39 isPresent:NO knownValueArray:remotecontrolervaluesArray];
    
    NSMutableArray* deviceValueArray = [[NSMutableArray alloc]initWithObjects:devicevalue, devicevalue2, devicevalue3, doorLockDeviceValue, alarmDeviceValue, thermodevicevalue,keyFobDeviceValue,keyPadDeviceValue,warningDeviceValue ,SmartACDeviceValue,occupancydevicevalue,lightsensorDeviceValue,windowcoverDeviceValue,temperaturesensorDeviceValue,zigbeeDeviceValue,colorcontrolDeviceValue,smaokedectorDeviceValue,floodsensorDeviceValue,moisturesensorDeviceValue,motionsensorDeviceValue,sirenDeviceValue,powerswitchDeviceValue,huebulbDeviceValue,SFIswitchDeviceValue,garagedooropenerDeviceValue,switchbinaryDeviceValue,standardICEDeviceValue,motionsensorDeviceValue1,contactswitcDeviceValue,firesensorvalueDeviceValue,watersensorvalueDeviceValue,gassensorDeviceValue1,PersonalEmergencyDeviceValue1,VibrationOrMovementSensorsensorDeviceValue1,remotecontrolerDeviceValue1,doorsensorDeviceValue,shocksensorDeviceValue,nil];
    return deviceValueArray;
}

-(NSMutableArray *)dynamicDeviceValueUpdate:(MobileCommandRequest*)mobilerequest{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    if(mobilerequest.deviceType == SFIDeviceType_MultiLevelSwitch_2){
        
        NSLog(@"mockcloud.m -> dynamic update multilevel switch");
        SFIDeviceKnownValues *knownvalues1=[[SFIDeviceKnownValues alloc]init];
        knownvalues1 =[self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *knownvaluearray=[[NSArray alloc]initWithObjects:knownvalues1 ,nil];
        SFIDeviceValue *devicevalue=[self createDeviceValue:(unsigned int)1 deviceID:(unsigned int)1 isPresent:(BOOL)NO knownValueArray:knownvaluearray];
        arr=[[NSMutableArray alloc]initWithObjects:devicevalue, nil];
    }
    
    
    else if(mobilerequest.deviceType == SFIDeviceType_BinarySensor_3){
        //device 2
        SFIDeviceKnownValues *knownvalues2=[[SFIDeviceKnownValues alloc]init];
        knownvalues2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        NSArray *knownvaluearray2=[[NSArray alloc]initWithObjects:knownvalues2 ,nil];
        SFIDeviceValue *devicevalue2=[self createDeviceValue:(unsigned int)1 deviceID:(unsigned int)2 isPresent:(BOOL)NO knownValueArray:knownvaluearray2];
        arr=[[NSMutableArray alloc]initWithObjects:devicevalue2, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_MultiLevelOnOff_4){
        NSLog(@"mockcloud.m -> dynamic update multilevel onoff");
        
        //device 3
        SFIDeviceKnownValues *knownvalues3=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"1"]){
            knownvalues3 =[self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SENSOR MULTILEVEL" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
            
        }
        
        SFIDeviceKnownValues *knownvalues4=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"2"]){
            knownvalues4 =[self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
            
        }
        
        NSArray *knownvaluearray3=[[NSArray alloc]initWithObjects:knownvalues3 ,knownvalues4, nil];
        SFIDeviceValue *devicevalue3=[self createDeviceValue:(unsigned int)2 deviceID:(unsigned int)3 isPresent:(BOOL)NO knownValueArray:knownvaluearray3];
        arr=[[NSMutableArray alloc]initWithObjects:devicevalue3, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_DoorLock_5){
        NSLog(@"mockcloud.m -> dynamic update doorlock");
        
        //device 4
        SFIDeviceKnownValues *doorLockKnownValues=[[SFIDeviceKnownValues alloc]init];
        doorLockKnownValues =[self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        NSArray *doorLockKnownValuesArray=[[NSArray alloc]initWithObjects:doorLockKnownValues ,nil];
        SFIDeviceValue *doorLockDeviceValue=[self createDeviceValue:(unsigned int)1 deviceID:(unsigned int)4 isPresent:(BOOL)NO knownValueArray:doorLockKnownValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:doorLockDeviceValue, nil];
        
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_Alarm_6){
        NSLog(@"mockcloud.m -> dynamic update alarm");
        //device 5
        SFIDeviceKnownValues *alarmKnownValues=[[SFIDeviceKnownValues alloc]init];
        alarmKnownValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"mystate" valuename_:@"abcd" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        NSArray *alarmKnownValuesArray=[[NSArray alloc]initWithObjects:alarmKnownValues, nil];
        SFIDeviceValue *alarmDeviceValue=[self createDeviceValue:(unsigned int)1 deviceID:(unsigned int)5 isPresent:(BOOL)NO knownValueArray:alarmKnownValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:alarmDeviceValue, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_Thermostat_7){
        //device 6
        SFIDeviceKnownValues *thermoKnowsvalues1=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"1"]){
            thermoKnowsvalues1 =[self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_MULTILEVEL valuetype_:@"STATE" valuename_:@"SENSOR MULTILEVEL" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *thermoKnowsvalues2=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"2"]){
            thermoKnowsvalues2 =[self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"THERMOSTAT OPERATING STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *thermoKnowsvalues3=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"3"]){
            thermoKnowsvalues3 =[self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT SETPOINT COOLING" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *thermoKnowsvalues4=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"4"]){
            thermoKnowsvalues4 =[self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *thermoKnowsvalues5=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"5"]){
            thermoKnowsvalues5 = [self createKnownValuesWithIndex:5 PropertyType_:SFIDevicePropertyType_THERMOSTAT_MODE valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
            
        }
        SFIDeviceKnownValues *thermoKnowsvalues6=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"6"]){
            thermoKnowsvalues6 = [self createKnownValuesWithIndex:6 PropertyType_:SFIDevicePropertyType_THERMOSTAT_FAN_MODE valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT FAN MODE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
            
        }
        SFIDeviceKnownValues *thermoKnowsvalues7=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"7"]){
            thermoKnowsvalues7 = [self createKnownValuesWithIndex:7 PropertyType_:SFIDevicePropertyType_SENSOR_MULTILEVEL valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT FAN STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        NSArray *thermostatKnowsValuesArray =[[NSArray alloc]initWithObjects: thermoKnowsvalues1,thermoKnowsvalues2 ,thermoKnowsvalues3,thermoKnowsvalues4,thermoKnowsvalues5,thermoKnowsvalues6,thermoKnowsvalues7,nil];
        
        
        SFIDeviceValue *thermodevicevalue=[self createDeviceValue:(unsigned int)7 deviceID:(unsigned int)6 isPresent:(BOOL)NO knownValueArray:thermostatKnowsValuesArray];
        arr = [[NSMutableArray alloc]initWithObjects:thermodevicevalue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_KeyFob_19){
        NSLog(@"mockcloud.m -> dynamic update keyfob");
        
        //keyfob
        SFIDeviceKnownValues *KeyfobKnownValues=[[SFIDeviceKnownValues alloc]init];
        KeyfobKnownValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_ARMMODE valuetype_:@"STATE" valuename_:@"ARMMODE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *keyFobKnownValuesArray=[[NSArray alloc]initWithObjects:KeyfobKnownValues, nil];
        
        SFIDeviceValue *keyFobDeviceValue=[self createDeviceValue:1 deviceID:7 isPresent:NO knownValueArray:keyFobKnownValuesArray];
        
        
        arr=[[NSMutableArray alloc]initWithObjects:keyFobDeviceValue, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_Keypad_20){
        NSLog(@"mockcloud.m -> dynamic update keypad");
        
        //keypad
        SFIDeviceKnownValues *KeyPadKnownValues=[[SFIDeviceKnownValues alloc]init];
        KeyPadKnownValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *keyPadKnownValuesArray=[[NSArray alloc]initWithObjects:KeyPadKnownValues, nil];
        
        SFIDeviceValue *keyPadDeviceValue=[self createDeviceValue:1 deviceID:8 isPresent:NO knownValueArray:keyPadKnownValuesArray];
        
        arr=[[NSMutableArray alloc]initWithObjects:keyPadDeviceValue, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_StandardWarningDevice_21){
        NSLog(@"mockcloud.m -> dynamic update StandardWarningDevice");
        
        SFIDeviceKnownValues *WarningdeviceValues=[[SFIDeviceKnownValues alloc]init];
        WarningdeviceValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_ALARM_STATE valuetype_:@"ALARM_STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *warningdeviceValuesArray=[[NSArray alloc]initWithObjects:WarningdeviceValues, nil];
        SFIDeviceValue *warningDeviceValue=[self createDeviceValue:1 deviceID:9 isPresent:NO knownValueArray:warningdeviceValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:warningDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_LightSensor_25){
        NSLog(@"mockcloud.m -> dynamic update LightSensor");
        SFIDeviceKnownValues *lightsensorValues=[[SFIDeviceKnownValues alloc]init];
        lightsensorValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_ILLUMINANCE valuetype_:@"STATE" valuename_:@"ILLUMINANCE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *lightsensordeviceValuesArray=[[NSArray alloc]initWithObjects:lightsensorValues, nil];
        
        SFIDeviceValue *lightsensorDeviceValue=[[SFIDeviceValue alloc]init];
        lightsensorDeviceValue=[self createDeviceValue:1 deviceID:12 isPresent:NO knownValueArray:lightsensordeviceValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:lightsensorDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_WindowCovering_26){
        NSLog(@"mockcloud.m -> dynamic update windowcovering");
        SFIDeviceKnownValues *windowcovering=[[SFIDeviceKnownValues alloc]init];
        windowcovering = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *windowcoverdeviceValuesArray=[[NSArray alloc]initWithObjects:windowcovering, nil];
        
        SFIDeviceValue *windowcoverDeviceValue=[[SFIDeviceValue alloc]init];
        windowcoverDeviceValue=[self createDeviceValue:1 deviceID:13 isPresent:NO knownValueArray:windowcoverdeviceValuesArray];
        
        arr=[[NSMutableArray alloc]initWithObjects:windowcoverDeviceValue, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_TemperatureSensor_27){
        NSLog(@"mockcloud.m -> dynamic update temperaturesensor");
        SFIDeviceKnownValues *temperaturesensor1=[[SFIDeviceKnownValues alloc]init];
        if ([mobilerequest.indexID isEqualToString:@"1"]) {
            
            temperaturesensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"TEMPERATURE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *temperaturesensor2=[[SFIDeviceKnownValues alloc]init];
        if ([mobilerequest.indexID isEqualToString:@"2"]) {
            
            temperaturesensor2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_HUMIDITY valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"HUMIDITY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        NSArray *temperaturesensordeviceValuesArray=[[NSArray alloc]initWithObjects:temperaturesensor1, temperaturesensor2,nil];
        
        SFIDeviceValue *temperaturesensorDeviceValue=[self createDeviceValue:2 deviceID:14 isPresent:NO knownValueArray:temperaturesensordeviceValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:temperaturesensorDeviceValue, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_ZigbeeDoorLock_28){
        NSLog(@"mockcloud.m -> dynamic update zigbee doorlock");
        SFIDeviceKnownValues *zigbeedoorlock1=[[SFIDeviceKnownValues alloc]init];
        if ([mobilerequest.indexID isEqualToString:@"1"]) {
            
            zigbeedoorlock1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_LOCK_STATE valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *zigbeedoorlock2=[[SFIDeviceKnownValues alloc]init];
        if ([mobilerequest.indexID isEqualToString:@"2"]) {
            
            zigbeedoorlock2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_USER_CODE valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        
        NSArray *zigbeedeviceValuesArray=[[NSArray alloc]initWithObjects:zigbeedoorlock1, zigbeedoorlock2,nil];
        
        SFIDeviceValue *zigbeeDeviceValue=[self createDeviceValue:2 deviceID:15 isPresent:NO knownValueArray:zigbeedeviceValuesArray];                    arr=[[NSMutableArray alloc]initWithObjects:zigbeeDeviceValue, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_ColorControl_29){
        NSLog(@"mockcloud.m -> dynamic update zigbee colorcontrol");
        SFIDeviceKnownValues *colorcontrol1=[[SFIDeviceKnownValues alloc]init];
        if ([mobilerequest.indexID isEqualToString:@"1"]) {
            
            colorcontrol1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *colorcontrol2=[[SFIDeviceKnownValues alloc]init];
        if ([mobilerequest.indexID isEqualToString:@"2"]) {
            
            colorcontrol2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_CURRENT_HUE valuetype_:@"STATE" valuename_:@"HUE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *colorcontrol3=[[SFIDeviceKnownValues alloc]init];
        if ([mobilerequest.indexID isEqualToString:@"3"]) {
            
            colorcontrol3 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *colorcontrol4=[[SFIDeviceKnownValues alloc]init];
        if ([mobilerequest.indexID isEqualToString:@"4"]) {
            
            colorcontrol4 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_COLOR_TEMPERATURE valuetype_:@"STATE" valuename_:@"COLOR_TEMPERATURE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        SFIDeviceKnownValues *colorcontrol5=[[SFIDeviceKnownValues alloc]init];
        if ([mobilerequest.indexID isEqualToString:@"5"]) {
            colorcontrol5 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_CURRENT_SATURATION valuetype_:@"STATE" valuename_:@"COLOR_TEMPERATURE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        
        NSArray *colorcontroldeviceValuesArray=[[NSArray alloc]initWithObjects:colorcontrol2,colorcontrol1, colorcontrol4,colorcontrol3,colorcontrol5,nil];
        
        SFIDeviceValue *colorcontrolDeviceValue=[self createDeviceValue:(int)[colorcontroldeviceValuesArray count] deviceID:16 isPresent:NO knownValueArray:colorcontroldeviceValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:colorcontrolDeviceValue, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_SmokeDetector_36){
        NSLog(@"mockcloud.m -> dynamic update smaokedetector");
        SFIDeviceKnownValues *smokedetector=[[SFIDeviceKnownValues alloc]init];
        smokedetector = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BASIC" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *smaokedectorValuesArray=[[NSArray alloc]initWithObjects:smokedetector,nil];
        
        SFIDeviceValue *smaokedectorDeviceValue=[self createDeviceValue:1 deviceID:17 isPresent:NO knownValueArray:smaokedectorValuesArray];
        
        arr=[[NSMutableArray alloc]initWithObjects:smaokedectorDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_FloodSensor_37){
        NSLog(@"mockcloud.m -> dynamic update floodsensor");
        //rushabh
        SFIDeviceKnownValues *floodsensor=[[SFIDeviceKnownValues alloc]init];
        floodsensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BASIC" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *floodsensorValuesArray=[[NSArray alloc]initWithObjects:floodsensor,nil];
        
        SFIDeviceValue *floodsensorDeviceValue=[self createDeviceValue:1 deviceID:18 isPresent:NO knownValueArray:floodsensorValuesArray];
        
        arr=[[NSMutableArray alloc]initWithObjects:floodsensorDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_ShockSensor_38){
        NSLog(@"mockcloud.m -> dynamic update shocksensor");
        SFIDeviceKnownValues *shocksensor=[[SFIDeviceKnownValues alloc]init];
        shocksensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        //            SFIDeviceKnownValues *shocksensor1=[[SFIDeviceKnownValues alloc]init];
        //            shocksensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"Byte" valuename_:@"BATTERY" value_:@"5"];
        
        NSArray *shocksensorValuesArray=[[NSArray alloc]initWithObjects:shocksensor,nil];
        
        SFIDeviceValue *shocksensorDeviceValue=[self createDeviceValue:1 deviceID:19 isPresent:NO knownValueArray:shocksensorValuesArray];
        
        arr=[[NSMutableArray alloc]initWithObjects:shocksensorDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_DoorSensor_39){
        NSLog(@"mockcloud.m -> dynamic update doorsensor");
        SFIDeviceKnownValues *doorsensor=[[SFIDeviceKnownValues alloc]init];
        doorsensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        NSArray *doorsensorValuesArray=[[NSArray alloc]initWithObjects:doorsensor,nil];
        
        SFIDeviceValue *doorsensorDeviceValue=[self createDeviceValue:1 deviceID:20 isPresent:NO knownValueArray:doorsensorValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:doorsensorDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_MoistureSensor_40){
        NSLog(@"mockcloud.m -> dynamic update moisture");
        SFIDeviceKnownValues *moisturesensor=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"1"]){
            moisturesensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BASIC" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *moisturesensor1=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"2"]){
            
            moisturesensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"TEMPERATURE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        NSArray *moisturesensorValuesArray=[[NSArray alloc]initWithObjects:moisturesensor,nil];
        
        SFIDeviceValue *moisturesensorDeviceValue=[self createDeviceValue:2 deviceID:21 isPresent:NO knownValueArray:moisturesensorValuesArray];
        
        arr=[[NSMutableArray alloc]initWithObjects:moisturesensorDeviceValue, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_MovementSensor_41){
        NSLog(@"mockcloud.m -> dynamic update movement");
        SFIDeviceKnownValues *motionsensor=[[SFIDeviceKnownValues alloc]init];
        motionsensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        NSArray *motionsensorValuesArray=[[NSArray alloc]initWithObjects:motionsensor,nil];
        
        SFIDeviceValue *motionsensorDeviceValue=[self createDeviceValue:1 deviceID:22 isPresent:NO knownValueArray:motionsensorValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:motionsensorDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_Siren_42){
        NSLog(@"mockcloud.m -> dynamic update siren");
        SFIDeviceKnownValues *siren=[[SFIDeviceKnownValues alloc]init];
        siren = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        NSArray *sirenValuesArray=[[NSArray alloc]initWithObjects:siren,nil];
        
        SFIDeviceValue *sirenDeviceValue=[self createDeviceValue:1 deviceID:23 isPresent:NO knownValueArray:sirenValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:sirenDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_BinaryPowerSwitch_45){
        NSLog(@"mockcloud.m -> dynamic update powerswitch");
        SFIDeviceKnownValues *PowerswitchValues1=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"1"]){
            PowerswitchValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_POWER valuetype_:@"POWER" valuename_:@"PRIMARY ATTRIBUTE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *PowerswitchValues=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"2"]){
            
            PowerswitchValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        NSArray *powerswitchValuesArray=[[NSArray alloc]initWithObjects:PowerswitchValues,PowerswitchValues1, nil];
        
        SFIDeviceValue *powerswitchDeviceValue=[[SFIDeviceValue alloc]init];
        powerswitchDeviceValue=[self createDeviceValue:2 deviceID:125 isPresent:NO knownValueArray:powerswitchValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:powerswitchDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_HueLamp_48){
        NSLog(@"mockcloud.m -> dynamic update huelamp");
        SFIDeviceKnownValues *huelampValues1=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"1"]){
            huelampValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *huelampValues2=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"2"]){
            
            huelampValues2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_COLOR_HUE valuetype_:@"POWER" valuename_:@"HUE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *huelampValues3=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"3"]){
            huelampValues3 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SATURATION valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *huelampValues4=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"4"]){
            
            huelampValues4 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"POWER" valuename_:@"PRIMARY ATTRIBUTE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        NSArray *hueValuesArray=[[NSArray alloc]initWithObjects:huelampValues1,huelampValues2,huelampValues3,huelampValues4, nil];
        
        SFIDeviceValue *huebulbDeviceValue=[[SFIDeviceValue alloc]init];
        huebulbDeviceValue=[self createDeviceValue:2 deviceID:25 isPresent:NO knownValueArray:hueValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:huebulbDeviceValue, nil];
    }
    
    else if(mobilerequest.deviceType == SFIDeviceType_GarageDoorOpener_53){
        NSLog(@"mockcloud.m -> dynamic update sfismart garagedooropener");
        SFIDeviceKnownValues *garagedooropenerValues1=[[SFIDeviceKnownValues alloc]init];
        garagedooropenerValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BARRIER_OPERATOR valuetype_:@"STATE" valuename_:@"BARRIER OPERATOR" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        
        
        NSArray *garageopenerValuesArray=[[NSArray alloc]initWithObjects:garagedooropenerValues1,nil];
        
        SFIDeviceValue *garagedooropenerDeviceValue=[[SFIDeviceValue alloc]init];
        garagedooropenerDeviceValue=[self createDeviceValue:1 deviceID:27 isPresent:NO knownValueArray:garageopenerValuesArray];
        
        arr=[[NSMutableArray alloc]initWithObjects:garagedooropenerDeviceValue, nil];
    }
    
    
    else if(mobilerequest.deviceType == SFIDeviceType_SecurifiSmartSwitch_50){
        NSLog(@"mockcloud.m -> dynamic update sfismart switch");
        SFIDeviceKnownValues *SFIswitchValues1=[[SFIDeviceKnownValues alloc]init];
        SFIswitchValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        NSArray *SFIswitchValuesArray=[[NSArray alloc]initWithObjects:SFIswitchValues1,nil];
        
        SFIDeviceValue *SFIswitchDeviceValue=[[SFIDeviceValue alloc]init];
        SFIswitchDeviceValue=[self createDeviceValue:1 deviceID:26 isPresent:NO knownValueArray:SFIswitchValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:SFIswitchDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_NestThermostat_57){
        NSLog(@"mockcloud.m -> dynamic update sfismart nestthermostat");
        SFIDeviceKnownValues *nesttharmostatValues1=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"1"]){
            nesttharmostatValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT_MODE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        SFIDeviceKnownValues *nesttharmostatValues2=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"2"]){
            nesttharmostatValues2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_AWAY_MODE valuetype_:@"STATE" valuename_:@"AWAY_MODE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *nesttharmostatValues3=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"3"]){
            nesttharmostatValues3 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_THERMOSTAT_TARGET valuetype_:@"STATE" valuename_:@"THERMOSTAT_TARGET" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *nesttharmostatValues4=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"4"]){
            nesttharmostatValues4 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_RESPONSE_CODE valuetype_:@"STATE" valuename_:@"THERMOSTAT_RESPONSE_CODE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *nesttharmostatValues5=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"5"]){
            nesttharmostatValues5 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_THERMOSTAT_RANGE_LOW valuetype_:@"STATE" valuename_:@"THERMOSTAT_RANGE_LOW" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *nesttharmostatValues6=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"6"]){
            nesttharmostatValues6 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH valuetype_:@"STATE" valuename_:@"THERMOSTAT_RANGE_HIGH" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *nesttharmostatValues7=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"7"]){
            nesttharmostatValues7 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"TEMPERATURE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        NSArray *nesttharmostatValuesArray=[[NSArray alloc]initWithObjects:nesttharmostatValues1,nesttharmostatValues2,nesttharmostatValues3,nesttharmostatValues4,nesttharmostatValues5,nesttharmostatValues6,nesttharmostatValues7,nil];
        
        SFIDeviceValue *nesttharmostatDeviceValue=[[SFIDeviceValue alloc]init];
        nesttharmostatDeviceValue=[self createDeviceValue:1 deviceID:128 isPresent:NO knownValueArray:nesttharmostatValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:nesttharmostatDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_NestSmokeDetector_58){
        NSLog(@"mockcloud.m -> dynamic update sfismart nestsmaokedetector");
        SFIDeviceKnownValues *nestsmokedetector1=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"1"]){
            nestsmokedetector1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_RESPONSE_CODE valuetype_:@"STATE" valuename_:@"RESPONSE_CODE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        SFIDeviceKnownValues *nestsmokedetector2=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"2"]){
            nestsmokedetector2 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_AWAY_MODE valuetype_:@"STATE" valuename_:@"AWAY_MODE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        NSArray *nestsmokedetectorValuesArray=[[NSArray alloc]initWithObjects:nestsmokedetector1,nil];
        
        SFIDeviceValue *nestsmokedetectorDeviceValue=[[SFIDeviceValue alloc]init];
        nestsmokedetectorDeviceValue=[self createDeviceValue:1 deviceID:28 isPresent:NO knownValueArray:nestsmokedetectorValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:nestsmokedetectorDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_SmartACSwitch_22){
        NSLog(@"mockcloud.m -> dynamic update smartas switch");
        SFIDeviceKnownValues *SmartAcdeviceValues=[[SFIDeviceKnownValues alloc]init];
        SmartAcdeviceValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *SmartACdeviceValuesArray=[[NSArray alloc]initWithObjects:SmartAcdeviceValues, nil];
        
        SFIDeviceValue *SmartACDeviceValue=[self createDeviceValue:1 deviceID:10 isPresent:NO knownValueArray:SmartACdeviceValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:SmartACDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_OccupancySensor_24){
        NSLog(@"mockcloud.m -> dynamic update sfismart occupancy sensor");
        SFIDeviceKnownValues *occupancydevicevalues1=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"1"]){
            occupancydevicevalues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_OCCUPANCY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        SFIDeviceKnownValues *occupancydevicevalues2=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"2"]){
            occupancydevicevalues2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        SFIDeviceKnownValues *occupancydevicevalues3=[[SFIDeviceKnownValues alloc]init];
        if([mobilerequest.indexID isEqualToString:@"3"]){
            occupancydevicevalues3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_HUMIDITY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        }
        
        NSArray *OccupancyValuesArray=[[NSArray alloc]initWithObjects:occupancydevicevalues1, occupancydevicevalues2,occupancydevicevalues3,nil];
        
        SFIDeviceValue *occupancydevicevalue=[self createDeviceValue:3 deviceID:11 isPresent:NO knownValueArray:OccupancyValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:occupancydevicevalue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_BinarySwitch_1){
        NSLog(@"mockcloud.m -> dynamic update smartas binary1");
        SFIDeviceKnownValues *switchbinary1=[[SFIDeviceKnownValues alloc]init];
        switchbinary1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *switchbinaryValuesArray=[[NSArray alloc]initWithObjects:switchbinary1,nil];
        
        SFIDeviceValue *switchbinaryDeviceValue=[[SFIDeviceValue alloc]init];
        switchbinaryDeviceValue=[self createDeviceValue:1 deviceID:30 isPresent:NO knownValueArray:switchbinaryValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:switchbinaryDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_StandardCIE_10){
        NSLog(@"mockcloud.m -> dynamic update smartas standardCIE");
        SFIDeviceKnownValues *standardICE=[[SFIDeviceKnownValues alloc]init];
        standardICE = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *standardICEValuesArray=[[NSArray alloc]initWithObjects:standardICE,nil];
        
        SFIDeviceValue *standardICEDeviceValue=[[SFIDeviceValue alloc]init];
        standardICEDeviceValue=[self createDeviceValue:1 deviceID:31 isPresent:NO knownValueArray:standardICEValuesArray];
        arr=[[NSMutableArray alloc]initWithObjects:standardICEDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_MotionSensor_11){
        NSLog(@"mockcloud.m -> dynamic update motion sensor");
        SFIDeviceKnownValues *motionsensorvalue=[[SFIDeviceKnownValues alloc]init];
        motionsensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *motionsensorvaluesArray=[[NSArray alloc]initWithObjects:motionsensorvalue,nil];
        
        SFIDeviceValue *motionsensorDeviceValue1=[[SFIDeviceValue alloc]init];
        motionsensorDeviceValue1=[self createDeviceValue:1 deviceID:32 isPresent:NO knownValueArray:motionsensorvaluesArray];
        arr=[[NSMutableArray alloc]initWithObjects:motionsensorDeviceValue1, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_ContactSwitch_12){
        NSLog(@"mockcloud.m -> dynamic update contact switch");
        SFIDeviceKnownValues *contactswitcvalue=[[SFIDeviceKnownValues alloc]init];
        contactswitcvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *contactswitcvaluesArray=[[NSArray alloc]initWithObjects:contactswitcvalue,nil];
        
        SFIDeviceValue *contactswitcDeviceValue=[[SFIDeviceValue alloc]init];
        contactswitcDeviceValue=[self createDeviceValue:1 deviceID:33 isPresent:NO knownValueArray:contactswitcvaluesArray];
        arr=[[NSMutableArray alloc]initWithObjects:contactswitcDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_FireSensor_13){
        NSLog(@"mockcloud.m -> dynamic update fire sensor");
        SFIDeviceKnownValues *firesensorvalue=[[SFIDeviceKnownValues alloc]init];
        firesensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *firesensorvaluevaluesArray=[[NSArray alloc]initWithObjects:firesensorvalue,nil];
        
        SFIDeviceValue *firesensorvalueDeviceValue=[[SFIDeviceValue alloc]init];
        firesensorvalueDeviceValue=[self createDeviceValue:1 deviceID:34 isPresent:NO knownValueArray:firesensorvaluevaluesArray];
        arr=[[NSMutableArray alloc]initWithObjects:firesensorvalueDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_WaterSensor_14){
        NSLog(@"mockcloud.m -> dynamic update water sensor");
        SFIDeviceKnownValues *watersensorvalue=[[SFIDeviceKnownValues alloc]init];
        watersensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *watersensorvaluevaluesArray=[[NSArray alloc]initWithObjects:watersensorvalue,nil];
        
        SFIDeviceValue *watersensorvalueDeviceValue=[[SFIDeviceValue alloc]init];
        watersensorvalueDeviceValue=[self createDeviceValue:1 deviceID:35 isPresent:NO knownValueArray:watersensorvaluevaluesArray];
        arr=[[NSMutableArray alloc]initWithObjects:watersensorvalueDeviceValue, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_GasSensor_15){
        NSLog(@"mockcloud.m -> dynamic update gas sensor");
        SFIDeviceKnownValues *gassensorvalue=[[SFIDeviceKnownValues alloc]init];
        gassensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *gassensorvaluesArray=[[NSArray alloc]initWithObjects:gassensorvalue,nil];
        
        SFIDeviceValue *gassensorDeviceValue1=[[SFIDeviceValue alloc]init];
        gassensorDeviceValue1=[self createDeviceValue:1 deviceID:36 isPresent:NO knownValueArray:gassensorvaluesArray];
        arr=[[NSMutableArray alloc]initWithObjects:gassensorDeviceValue1, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_PersonalEmergencyDevice_16){
        NSLog(@"mockcloud.m -> dynamic update PersonalEmergencyDevice");
        SFIDeviceKnownValues *PersonalEmergencyDevicevalue=[[SFIDeviceKnownValues alloc]init];
        PersonalEmergencyDevicevalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *PersonalEmergencyvaluesArray=[[NSArray alloc]initWithObjects:PersonalEmergencyDevicevalue,nil];
        
        SFIDeviceValue *PersonalEmergencyDeviceValue1=[[SFIDeviceValue alloc]init];
        PersonalEmergencyDeviceValue1=[self createDeviceValue:1 deviceID:37 isPresent:NO knownValueArray:PersonalEmergencyvaluesArray];
        arr=[[NSMutableArray alloc]initWithObjects:PersonalEmergencyDeviceValue1, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_VibrationOrMovementSensor_17){
        NSLog(@"mockcloud.m -> dynamic update VibrationOrMovementSensor");
        SFIDeviceKnownValues *VibrationOrMovementSensorsensorvalue=[[SFIDeviceKnownValues alloc]init];
        VibrationOrMovementSensorsensorvalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *VibrationOrMovementSensorsensorvaluesArray=[[NSArray alloc]initWithObjects:VibrationOrMovementSensorsensorvalue,nil];
        
        SFIDeviceValue *VibrationOrMovementSensorsensorDeviceValue1=[[SFIDeviceValue alloc]init];
        VibrationOrMovementSensorsensorDeviceValue1=[self createDeviceValue:1 deviceID:38 isPresent:NO knownValueArray:VibrationOrMovementSensorsensorvaluesArray];
        
        arr=[[NSMutableArray alloc]initWithObjects:VibrationOrMovementSensorsensorDeviceValue1, nil];
    }
    else if(mobilerequest.deviceType == SFIDeviceType_RemoteControl_18){
        NSLog(@"mockcloud.m -> dynamic update remotecontrol");
        SFIDeviceKnownValues *remotecontrolervalue=[[SFIDeviceKnownValues alloc]init];
        remotecontrolervalue = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:[NSString stringWithFormat:@"%@",mobilerequest.changedValue]];
        
        NSArray *remotecontrolervaluesArray=[[NSArray alloc]initWithObjects:remotecontrolervalue,nil];
        
        SFIDeviceValue *remotecontrolerDeviceValue1=[[SFIDeviceValue alloc]init];
        remotecontrolerDeviceValue1=[self createDeviceValue:1 deviceID:39 isPresent:NO knownValueArray:remotecontrolervaluesArray];
        arr=[[NSMutableArray alloc]initWithObjects:remotecontrolerDeviceValue1, nil];
    }
    return arr;
}

-(NSString *)encodeGenericData:(NSString *) dataIncomming{
    NSLog(@"mock cloud data incomming: %@ ", dataIncomming);
    
    NSString *almondRouterSummary = @"<root><AlmondRouterSummary action=\"get\">1</AlmondRouterSummary></root>";
    NSString *almondWirelessSettings = @"<root><AlmondWirelessSettings action=\"get\">1</AlmondWirelessSettings></root>";
    NSString *almondConnectedDevices = @"<root><AlmondConnectedDevices action=\"get\">1</AlmondConnectedDevices></root>";
    NSString *almondBlockedMacs = @"<root><AlmondBlockedMACs action=\"get\">1</AlmondBlockedMACs></root>";
    NSString *reboot = @"<root><Reboot>1</Reboot></root>​";
    NSString *almondLogs = @"<root><SendLogs><Reason>Unable to get notification</Reason></SendLogs></root>";
    NSString *firmWareUpdate = @"<root><FirmwareUpdate Available=\"1/0\"><Version>AP2-R070-L009-W016-ZW016-ZB005</Version></FirmwareUpdate></root>";
    NSString *str;
    
    
    if([almondRouterSummary isEqualToString:dataIncomming]){
        NSLog(@"inside almond router summary");
        
        str = @"<root><AlmondRouterSummary><AlmondWirelessSettingsSummary count=\"4\"><WirelessSetting index=\"1\" enabled=\"true\"><SSID>Almond+ 5GHz-Ud87bv</SSID></WirelessSetting><WirelessSetting index=\"2\" enabled=\"true\"><SSID>Almond+</SSID></WirelessSetting><WirelessSetting index=\"3\" enabled=\"false\"><SSID>Guest-5GHz</SSID></WirelessSetting><WirelessSetting index=\"4\" enabled=\"false\"><SSID>Guest-2.4GHz</SSID></WirelessSetting></AlmondWirelessSettingsSummary><AlmondConnectedDevicesSummary count=\"2\"></AlmondConnectedDevicesSummary><AlmondBlockedMACSummary count=\"0\"></AlmondBlockedMACSummary><AlmondBlockedContentSummary count=\"0\"></AlmondBlockedContentSummary><RouterUptime>36 minutes</RouterUptime><Uptime>2206</Uptime><Url>10.10.10.254</Url><Login>root</Login><TempPass>AkAi9Z2WNwwP2Fqf2w7OpvWwevsxnlp1sYyptAV3kgI=</TempPass><FirmwareVersion>AP2-R080cj-L009-W016-ZW016-ZB005</FirmwareVersion></AlmondRouterSummary></root>";
        
    }
    else if([almondWirelessSettings isEqualToString:dataIncomming]){
        NSLog(@"Inside almond wireless settings: ");
        
        str  = @"<root><AlmondWirelessSettings count=\"2\"><WirelessSetting index=\"1\" enabled=\"true\"><SSID>AlmondNetwork</SSID><Password>1234567890</Password><Channel>1</Channel><EncryptionType>AES</EncryptionType><Security>WPA2PSK</Security><WirelessMode>802.11bgn</WirelessMode><CountryRegion>0</CountryRegion></WirelessSetting><WirelessSetting index=\"2\" enabled=\"true\"><SSID>Guest</SSID><Password>1111222200</Password><Channel>1</Channel><EncryptionType>AES</EncryptionType><Security>WPA2PSK</Security><WirelessMode>802.11bgn</WirelessMode><CountryRegion>0</CountryRegion></WirelessSetting></AlmondWirelessSettings></root>";
    }
    else if([almondConnectedDevices isEqualToString:dataIncomming]){
        NSLog(@"Inside alond connected devvicess");
        str  = @"<root><AlmondConnectedDevices count=\"5\"><ConnectedDevice><Name>ashutosh</Name><IP>1678379540</IP><MAC>10:60:4b:d9:60:84</MAC></ConnectedDevice><ConnectedDevice><Name></Name><IP>1695156756</IP><MAC>00:00:00:00:00:00</MAC></ConnectedDevice><ConnectedDevice><Name>GT-S5253</Name><IP>1711933972</IP><MAC>00:07:ab:c2:57:98</MAC></ConnectedDevice><ConnectedDevice><Name>android-c95b260</Name><IP>1728711188</IP><MAC>a0:f4:50:ef:a1:71</MAC></ConnectedDevice><ConnectedDevice><Name>android-a3a41ac</Name><IP>1745488404</IP><MAC>3c:43:8e:b2:1a:9b</MAC></ConnectedDevice></AlmondConnectedDevices></root>";
    }
    else if([almondBlockedMacs isEqualToString:dataIncomming]){
        NSLog(@"inside almond blocked macs ");
        str  = @"<root><AlmondBlockedMACs count=\"2\"><BlockedMAC>10:60:4b:d9:60:84</BlockedMAC><BlockedMAC>00:07:ab:c2:57:98</BlockedMAC></AlmondBlockedMACs></root>";
    }
    else if ([reboot caseInsensitiveCompare:dataIncomming]){
        NSLog(@"generic command reboot");
        str  = @"<root><Reboot>1</Reboot></root>";
    }
    else if([almondLogs caseInsensitiveCompare:dataIncomming]){
        NSLog(@"generic command almond logs");
        str  = @"<root><SendLogsResponse success=\"true\"><Reason>Logs uploaded successfully</Reason></SendLogsResponse></root>";
    }
    
    else if([firmWareUpdate caseInsensitiveCompare:dataIncomming]){
        NSLog(@"generic command firmware update");
        str  = @"<root><FirmwareUpdateResponse success=\"true\"><Percentage>10-100</Percentage></FirmwareUpdateResponse></root>";
    }
    
    else {
        str = @"generic data";
        
    }
    return [self encodeGenericDataForString:str];
}

-(SFINotification*)createnotification:(long )notificationId externalIDa:(NSString*)externalID almondMACa:(NSString*)almondMAC timea:(NSTimeInterval)time devicenamea:(NSString*)devicename deviceida:(unsigned int)deviceID devicetypea:(unsigned int)devicetype valueindexa:(unsigned int)valueindex valuetypea:(unsigned int)valuetype valuea:(NSString*)value vieweda:(BOOL)viewed debugcountera:(long)debugcounter{
    
    SFINotification *notification=[[SFINotification alloc]init];
    notification.notificationId=notificationId;
    notification.externalId=externalID;
    
    notification.almondMAC=almondMAC;
    notification.time=time;
    notification.deviceName=devicename;
    notification.deviceId=deviceID;
    notification.deviceType=devicetype;
    notification.valueIndex=valueindex;
    
    notification.valueType=valuetype;//propertytype
    notification.value=value;
    notification.debugCounter=3;
    notification.viewed=viewed;
    notification.debugCounter=debugcounter;
    return notification;
}



-(void) storeDeviceData:(unsigned int)deviceType_dummy deviceType:(int)devicetype deviceID:(int)deviceid OZWNode:(NSString *)ozwnode
            zigBeeEUI64:(NSString *) zigbeeeui64 zigBeeShortID:(NSString*)zigbeeshortid associationTimestamp:(NSString*)associationtimestamp
       deviceTechnology:(int)devicetechnology notificationMode:(int)notificationmode almondMAC:(NSString*)almondmac
      allowNotification:(NSString*)allownotification location:(NSString*)location valueCount:(int)valuecount
         deviceFunction:(NSString*)devicefunction deviceTypeName:(NSString*)devicetypename friendlyDeviceType:(NSString*)friendlydevicetype deviceName:(NSString*)devicename listarray:(NSMutableArray*)Listarray
{
    SFIDevice *device=[[SFIDevice alloc]init];
    
    device.deviceType=devicetype;
    device.deviceID=deviceid;
    device.OZWNode=ozwnode;
    device.zigBeeEUI64=zigbeeeui64;
    device.zigBeeShortID=zigbeeshortid;
    device.associationTimestamp=associationtimestamp;
    device.deviceTechnology=devicetechnology;
    device.notificationMode=notificationmode;
    device.almondMAC=almondmac;
    device.allowNotification=allownotification;
    device.location=location;
    device.valueCount=valuecount;
    device.deviceFunction=devicefunction;
    device.deviceTypeName=devicetypename;
    device.friendlyDeviceType=friendlydevicetype;
    device.deviceName=devicename;
    
    [Listarray addObject:device];
    return ;
}

-(SFIDeviceKnownValues *) createKnownValuesWithIndex:(int)index PropertyType_:(int)propertytype valuetype_:(NSString *)valuetype valuename_:(NSString *)valuename value_:(NSString *)value
{
    SFIDeviceKnownValues *knownvalues=[[SFIDeviceKnownValues alloc]init];
    knownvalues.index=index;
    knownvalues.propertyType=propertytype;
    knownvalues.valueType=valuetype;
    knownvalues.value=value;
    knownvalues.valueName=valuename;
    
    return knownvalues;
}

-(SFIDeviceValue *)createDeviceValue:(unsigned int)valueCount deviceID:(unsigned int)deviceid isPresent:(BOOL)ispresent knownValueArray:(NSArray *)knownvaluearray{
    SFIDeviceValue *devicevalue=[[SFIDeviceValue alloc]init];
    devicevalue.valueCount=valueCount;
    devicevalue.deviceID=deviceid;
    devicevalue.isPresent=ispresent;
    [devicevalue replaceKnownDeviceValues:knownvaluearray];
    return devicevalue;
}

-(LoginResponse*) createLoginResponseWithUserID:(NSString*)userID tempPass:(NSString*)temppass reason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful{
    LoginResponse *loginResponse = [[LoginResponse alloc] init];
    loginResponse.userID = userID;
    loginResponse.tempPass = temppass;
    loginResponse.reason = reason;
    loginResponse.reasonCode = reasoncode;
    loginResponse.isSuccessful = isSuccessful;
    return loginResponse;
}

-(LogoutAllResponse*) logoutAllResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful{
    LogoutAllResponse *logoutAllResponse = [[LogoutAllResponse alloc] init];
    logoutAllResponse.reason = reason;
    logoutAllResponse.reasonCode = reasoncode;
    logoutAllResponse.isSuccessful = isSuccessful;
    return logoutAllResponse;
}

-(SignupResponse*) signupResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful{
    SignupResponse *signupResponse = [[SignupResponse alloc] init];
    signupResponse.Reason = reason;
    signupResponse.reasonCode = reasoncode;
    signupResponse.isSuccessful = isSuccessful;
    return signupResponse;
}
-(ValidateAccountResponse*) validateAccountResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful{
    ValidateAccountResponse *validateResponse = [[ValidateAccountResponse alloc] init];
    validateResponse.reason = reason;
    validateResponse.reasonCode = reasoncode;
    validateResponse.isSuccessful = isSuccessful;
    return validateResponse;
}
-(ResetPasswordResponse*) resetPasswordResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful{
    ResetPasswordResponse *resetPasswordResponse = [[ResetPasswordResponse alloc] init];
    resetPasswordResponse.reason = reason;
    resetPasswordResponse.reasonCode = reasoncode;
    resetPasswordResponse.isSuccessful = isSuccessful;
    return resetPasswordResponse;
}
-(AffiliationUserComplete*) AffiliationUserCompleteWithAlmondPlusName:(NSString*)almondPlusName almondPlusMAC:(NSString*)almondPlusMAC reason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful wifiSSID:(NSString*)wifiSSID wifiPassword:(NSString*)wifiPassword{
    AffiliationUserComplete *affiliationUserComplete = [[AffiliationUserComplete alloc] init];
    affiliationUserComplete.almondplusName = almondPlusName;
    affiliationUserComplete.almondplusMAC = almondPlusMAC;
    affiliationUserComplete.reason = reason;
    affiliationUserComplete.reasonCode = reasoncode;
    affiliationUserComplete.isSuccessful = isSuccessful;
    affiliationUserComplete.wifiSSID =  wifiSSID;
    affiliationUserComplete.wifiPassword = wifiPassword;
    return affiliationUserComplete;
}

-(AlmondListResponse *)almondListResponseWithAction:(NSString *)action deviceCount:(unsigned int)deviceCount almondPlusMACList:(NSMutableArray *)almondPlusMACList isSuccessful:(BOOL)isSuccessful reason:(NSString *)reason{
    AlmondListResponse *almondListResponse=[[AlmondListResponse alloc]init];
    almondListResponse.deviceCount=deviceCount;
    almondListResponse.almondPlusMACList=almondPlusMACList;
    almondListResponse.isSuccessful = isSuccessful;
    almondListResponse.reason = reason;
    almondListResponse.action=action;
    return almondListResponse;
}
-(SFIAlmondPlus*) createAlmondPlusWithAlmondPlusName:(NSString*)almondPlusName almondPlusMAC:(NSString*)almondPlusMAC index:(int)index colorCodeIndex:(int)colorCodeIndex userCount:(int)userCount accessEmailIDs:(NSMutableArray*)accessEmailIDs isExpanded:(BOOL)isExpanded ownerEmailID:(NSString*)ownerEmailID linkType:(unsigned int)linkType{
    SFIAlmondPlus *almondPlus = [[SFIAlmondPlus alloc] init];
    almondPlus.almondplusName = almondPlusName;
    almondPlus.almondplusMAC = almondPlusMAC;
    almondPlus.index = index;
    almondPlus.colorCodeIndex = colorCodeIndex;
    almondPlus.userCount = userCount;
    almondPlus.accessEmailIDs = accessEmailIDs;
    almondPlus.isExpanded =  isExpanded;
    almondPlus.ownerEmailID = ownerEmailID;
    almondPlus.linkType = linkType;
    return almondPlus;
}
-(DeviceDataHashResponse*) deviceDataHashResponseWithAlmondHash:(NSString*)almondHash isSuccessful:(BOOL)isSuccessful reason:(NSString*)reason{
    DeviceDataHashResponse *deviceDataHashResponse = [[DeviceDataHashResponse alloc] init];
    deviceDataHashResponse.almondHash = almondHash;
    deviceDataHashResponse.isSuccessful = isSuccessful;
    deviceDataHashResponse.reason = reason;
    return deviceDataHashResponse;
}
-(DeviceListResponse *)deviceListResponseWithAlmondMAC:(NSString *)almondMAC deviceCount:(unsigned int)deviceCount deviceList:(NSMutableArray *)deviceList isSuccessful:(BOOL)isSuccessful reason:(NSString *)reason{
    DeviceListResponse *deviceListResp=[[DeviceListResponse alloc]init];
    deviceListResp.almondMAC=almondMAC;
    deviceListResp.deviceCount=deviceCount;
    deviceListResp.deviceList=deviceList;
    deviceListResp.isSuccessful = isSuccessful;
    deviceListResp.reason = reason;
    return deviceListResp;
}

-(DeviceValueResponse *)deviceValueResponseWithAlmondMAC:(NSString *)almondMAC deviceCount:(unsigned int)deviceCount deviceValueList:(NSMutableArray *)deviceValueList isSuccessful:(BOOL)isSuccessful reason:(NSString *)reason{
    DeviceValueResponse *deviceValueResp=[[DeviceValueResponse alloc]init];
    deviceValueResp.almondMAC=almondMAC;
    deviceValueResp.deviceCount=deviceCount;
    deviceValueResp.deviceValueList=deviceValueList;
    deviceValueResp.isSuccessful = isSuccessful;
    deviceValueResp.reason = reason;
    return deviceValueResp;
}
-(MobileCommandResponse*) mobileCommandRespWithisSuccessful:(BOOL)isSuccessful reason:(NSString*)reason mobileInternalIndex:(unsigned int)mobileInternalIndex{
    MobileCommandResponse *mobileCommandResp = [[MobileCommandResponse alloc] init];
    mobileCommandResp.isSuccessful = isSuccessful;
    mobileCommandResp.reason = reason;
    mobileCommandResp.mobileInternalIndex = mobileInternalIndex;
    return mobileCommandResp;
}
-(AlmondNameChangeResponse*) almondNameChangeResponseWithinternalIndex:(NSString*) internalIndex isSuccessful:(BOOL)isSuccessful{
    AlmondNameChangeResponse *almondNameChangeResp = [[AlmondNameChangeResponse alloc] init];
    almondNameChangeResp.internalIndex = internalIndex;
    almondNameChangeResp.isSuccessful = isSuccessful;
    return almondNameChangeResp;
}
-(SensorChangeResponse*) sensorChangeResponseWithinternalIndex:(unsigned int) mobileInternalIndex isSuccessful:(BOOL)isSuccessful{
    SensorChangeResponse *sensorChangeResp = [[SensorChangeResponse alloc] init];
    sensorChangeResp.mobileInternalIndex = mobileInternalIndex;
    sensorChangeResp.isSuccessful = isSuccessful;
    return sensorChangeResp;
}
-(AlmondModeChangeResponse*) almondModeChangeResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful{
    AlmondModeChangeResponse *almondModeChangeResp = [[AlmondModeChangeResponse alloc] init];
    almondModeChangeResp.reason = reason;
    almondModeChangeResp.reasonCode = reasoncode;
    almondModeChangeResp.success = isSuccessful;
    return almondModeChangeResp;
}
-(NotificationPreferenceListResponse*) notificationPreferenceListResponseWithAlmondMAC:(NSString *)almondMAC reason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful preferenceCount:(int)preferenceCount notificationUser:(SFINotificationUser *)notificationUser notificationDeviceList:(NSMutableArray *)notificationDeviceList{
    NotificationPreferenceListResponse *notificationPreferenceListResp = [[NotificationPreferenceListResponse alloc] init];
    notificationPreferenceListResp.almondMAC=almondMAC;
    notificationPreferenceListResp.reason = reason;
    notificationPreferenceListResp.reasonCode = reasoncode;
    notificationPreferenceListResp.isSuccessful = isSuccessful;
    notificationPreferenceListResp.preferenceCount = preferenceCount;
    notificationPreferenceListResp.notificationUser = notificationUser;
    notificationPreferenceListResp.notificationDeviceList = notificationDeviceList;
    return notificationPreferenceListResp;
}
-(SFINotificationDevice*) notificationDeviceWithDeviceID:(int)deviceID valueIndex:(int)valueIndex notificationMode:(SFINotificationMode)notificationMode{
    SFINotificationDevice *notificationDevice = [[SFINotificationDevice alloc] init];
    notificationDevice.deviceID=deviceID;
    notificationDevice.valueIndex = valueIndex;
    notificationDevice.notificationMode = notificationMode;
    return notificationDevice;
}

-(SFINotificationUser*) notificationUserWithUserID:(NSString *)userID preferenceCount:(int)preferenceCount notificationDeviceList:(NSArray *)notificationDeviceList{
    SFINotificationUser *notificationDevice = [[SFINotificationUser alloc] init];
    notificationDevice.userID=userID;
    notificationDevice.preferenceCount = preferenceCount;
    notificationDevice.notificationDeviceList = notificationDeviceList;
    return notificationDevice;
}
-(NSString *)encodeGenericDataForString:(NSString *)str {
    NSData *myData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *genericData = [NSMutableData new];
    
    uint32_t length = (int)[str length];
    uint32_t commandType = CommandType_GENERIC_COMMAND_REQUEST;
    
    [genericData appendBytes:&length length:sizeof(length)];
    [genericData appendBytes:&commandType length:sizeof(commandType)];
    [genericData appendData:myData];
    NSString *base64String = [genericData base64EncodedStringWithOptions:0];
    return base64String;
}
//encode (emulate almond)
-(GenericCommandResponse*) genericCommandResponseWithAlmondMAC:(NSString*)almondMAC reason:(NSString*)reason mobileInternalIndex:(unsigned int)mobileInternalIndex isSuccessful:(BOOL)isSuccessful applicationID:(NSString*)applicationID genericData:(NSString*)genericData{
    GenericCommandResponse *genericCommandResponse = [[GenericCommandResponse alloc] init];
    genericCommandResponse.almondMAC = almondMAC;
    genericCommandResponse.reason = reason;
    genericCommandResponse.mobileInternalIndex = mobileInternalIndex;
    genericCommandResponse.isSuccessful = isSuccessful;
    genericCommandResponse.applicationID =  applicationID;
    genericCommandResponse.genericData = genericData;
    return genericCommandResponse;
}
-(ChangePasswordResponse*) changePasswordResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason{
    ChangePasswordResponse *changePasswordResponse = [[ChangePasswordResponse alloc] init];
    changePasswordResponse.isSuccessful = isSuccessful;
    changePasswordResponse.reasonCode = reasoncode;
    changePasswordResponse.reason = reason;
    return changePasswordResponse;
}
-(DeleteAccountResponse*) deleteAccountResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason{
    DeleteAccountResponse *deleteAccountResponse = [[DeleteAccountResponse alloc] init];
    deleteAccountResponse.isSuccessful = isSuccessful;
    deleteAccountResponse.reasonCode = reasoncode;
    deleteAccountResponse.reason = reason;
    return deleteAccountResponse;
}
-(UserInviteResponse*) userInviteResponseWithisSuccessful:(BOOL)isSuccessful internalIndex:(NSString*)internalIndex reasonCode:(int)reasoncode reason:(NSString*)reason{
    UserInviteResponse *userInviteResp = [[UserInviteResponse alloc] init];
    userInviteResp.isSuccessful = isSuccessful;
    userInviteResp.internalIndex = internalIndex;
    userInviteResp.reasonCode = reasoncode;
    userInviteResp.reason = reason;
    return userInviteResp;
}
-(AlmondAffiliationDataResponse*) almondAffiliationDataResponseWithisSuccessful:(BOOL)isSuccessful almondCount:(int)almondCount reason:(NSString*)reason almondList:(NSMutableArray *)almondList{
    AlmondAffiliationDataResponse *almondAffiliationDataResp = [[AlmondAffiliationDataResponse alloc] init];
    almondAffiliationDataResp.isSuccessful = isSuccessful;
    almondAffiliationDataResp.almondCount = almondCount;
    almondAffiliationDataResp.reason = reason;
    almondAffiliationDataResp.almondList = almondList;
    return almondAffiliationDataResp;
}
-(UpdateUserProfileResponse*) updateUserProfileResponseWithisSuccessful:(BOOL)isSuccessful internalIndex:(NSString*)internalIndex reasonCode:(int)reasoncode reason:(NSString*)reason{
    UpdateUserProfileResponse *updateUserProfileResp = [[UpdateUserProfileResponse alloc] init];
    updateUserProfileResp.isSuccessful = isSuccessful;
    updateUserProfileResp.internalIndex = internalIndex;
    updateUserProfileResp.reasonCode = reasoncode;
    updateUserProfileResp.reason = reason;
    return updateUserProfileResp;
}

-(UserProfileResponse*) userProfileResponseWithisSuccessful:(BOOL)isSuccessful firstName:(NSString*)firstName lastName:(NSString*)lastName addressLine1:(NSString*)addressLine1 addressLine2:(NSString*)addressLine2 addressLine3:(NSString*)addressLine3 country:(NSString*)country zipCode:(NSString*)zipCode reasonCode:(int)reasoncode reason:(NSString*)reason{
    UserProfileResponse *userProfileResp = [[UserProfileResponse alloc] init];
    userProfileResp.isSuccessful = isSuccessful;
    userProfileResp.firstName = firstName;
    userProfileResp.lastName = lastName;
    userProfileResp.addressLine1 = addressLine1;
    userProfileResp.addressLine2 = addressLine2;
    
    userProfileResp.addressLine3 = addressLine3;
    userProfileResp.country = country;
    userProfileResp.zipCode = zipCode;
    userProfileResp.reasonCode = reasoncode;
    userProfileResp.reason = reason;
    return userProfileResp;
}
-(MeAsSecondaryUserResponse*) meAsSecondaryUserResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason almondCount:(int)almondCount almondList:(NSMutableArray *)almondList {
    MeAsSecondaryUserResponse *meAsSecondaryUserResp = [[MeAsSecondaryUserResponse alloc] init];
    meAsSecondaryUserResp.isSuccessful = isSuccessful;
    meAsSecondaryUserResp.reasonCode = reasoncode;
    meAsSecondaryUserResp.reason = reason;
    meAsSecondaryUserResp.almondCount = almondCount;
    meAsSecondaryUserResp.almondList = almondList;
    return meAsSecondaryUserResp;
}

-(DeleteSecondaryUserResponse*) deleteSecondaryUserResponseWithisSuccessful:(BOOL)isSuccessful internalIndex:(NSString*)internalIndex reasonCode:(int)reasoncode reason:(NSString*)reason{
    DeleteSecondaryUserResponse *deleteSecondaryUserResp = [[DeleteSecondaryUserResponse alloc] init];
    deleteSecondaryUserResp.isSuccessful = isSuccessful;
    deleteSecondaryUserResp.internalIndex = internalIndex;
    deleteSecondaryUserResp.reasonCode = reasoncode;
    deleteSecondaryUserResp.reason = reason;
    return deleteSecondaryUserResp;
}
-(DeleteMeAsSecondaryUserResponse*) deleteMeAsSecondaryUserResponseWithisSuccessful:(BOOL)isSuccessful internalIndex:(NSString*)internalIndex reasonCode:(int)reasoncode reason:(NSString*)reason{
    DeleteMeAsSecondaryUserResponse *deleteMeAsSecondaryUserResponse = [[DeleteMeAsSecondaryUserResponse alloc] init];
    deleteMeAsSecondaryUserResponse.isSuccessful = isSuccessful;
    deleteMeAsSecondaryUserResponse.internalIndex = internalIndex;
    deleteMeAsSecondaryUserResponse.reasonCode = reasoncode;
    deleteMeAsSecondaryUserResponse.reason = reason;
    return deleteMeAsSecondaryUserResponse;
}
-(UnlinkAlmondResponse*) unlinkAlmondResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason{
    UnlinkAlmondResponse *unlinkAlmondResp = [[UnlinkAlmondResponse alloc] init];
    unlinkAlmondResp.isSuccessful = isSuccessful;
    unlinkAlmondResp.reasonCode = reasoncode;
    unlinkAlmondResp.reason = reason;
    return unlinkAlmondResp;
}
-(NotificationRegistrationResponse*) notificationRegistrationResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason{
    NotificationRegistrationResponse *notificationRegistrationResp = [[NotificationRegistrationResponse alloc] init];
    notificationRegistrationResp.isSuccessful = isSuccessful;
    notificationRegistrationResp.reasonCode = reasoncode;
    notificationRegistrationResp.reason = reason;
    return notificationRegistrationResp;
}

-(NotificationDeleteRegistrationResponse*) notificationDeleteRegistrationResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason{
    NotificationDeleteRegistrationResponse *notificationDeleteRegistrationResp = [[NotificationDeleteRegistrationResponse alloc] init];
    notificationDeleteRegistrationResp.isSuccessful = isSuccessful;
    notificationDeleteRegistrationResp.reasonCode = reasoncode;
    notificationDeleteRegistrationResp.reason = reason;
    return notificationDeleteRegistrationResp;
}

-(AlmondModeResponse *)almondModeResponseForUserId:(NSString*)userId AlmondMAC:(NSString *)almondMAC success:(BOOL)success reasonCode:(unsigned int)reasonCode reason:(NSString *)reason mode:(unsigned int)mode{
    AlmondModeResponse *almondModeResp=[[AlmondModeResponse alloc]init];
    almondModeResp.userId=userId;
    almondModeResp.almondMAC=almondMAC;
    almondModeResp.success = success;
    almondModeResp.reasonCode=reasonCode;
    almondModeResp.reason = reason;
    almondModeResp.mode = mode;
    return almondModeResp;
}
-(NotificationListResponse*) notificationListResponseWithPageState:(NSString *)pageState requestId:(NSString *)requestId notifications:(NSArray *)notifications newCount:(NSInteger)newCount{
    NotificationListResponse *notificationListResp = [[NotificationListResponse alloc] init];
    notificationListResp.pageState = pageState;
    notificationListResp.requestId = requestId;
    notificationListResp.notifications = notifications;
    notificationListResp.newCount = newCount;
    return notificationListResp;
}
-(NSData *) encodeDynamicCreateSceneWithDict:(NSDictionary *)mainDict {
    NSString *almondplusMAC = [mainDict valueForKey:@"AlmondplusMAC"];
    NSLog(@"almondplusmac: %@", almondplusMAC);
    NSArray *sceneEntryList = [mainDict valueForKey:@"SceneEntryList"];
    NSDictionary *sceneDict = sceneEntryList[0];
    //to do - a loop to get all sceneEntrylist
    // a loop to make json, string append
    
    NSInteger randomDeviceValue;
    randomDeviceValue = arc4random() % 100000;
    NSString *sceneName = [mainDict valueForKey:@"SceneName"];
    
    NSLog(@"cloud dynamic create scene entry list:%@", sceneDict);
    
    NSString *dynamicCreateScene = [NSString stringWithFormat:@"{\"CommandType\":\"DynamicSceneAdded\",\"HashNow\":\"44c1d03821da8d6a089d2fd5b0e7301b\",\"AlmondMAC\":\"%@\",\"Scenes\":{\"ID\":\"%ld\",\"Active\":\"true\",\"SceneName\":\"%@\",\"LastActiveEpoch\":\"251176214925585\",\"SceneEntryList\":[{\"DeviceID\":\"1\",\"Index\":\"1\",\"Value\":\"false\",\"Valid\":\"true\"},{\"DeviceID\":\"4\",\"Index\":\"1\",\"Value\":\"78\",\"Valid\":\"false\"}]}}", almondplusMAC, (long)randomDeviceValue, sceneName];
    return [dynamicCreateScene dataUsingEncoding:NSUTF8StringEncoding];
}
-(NSData *) encodeDynamicUpdateSceneWithDict:(NSDictionary *)mainDict {
    NSInteger sceneID = [[mainDict valueForKey:@"ID"] integerValue];
    NSString *almondplusMAC = [mainDict valueForKey:@"AlmondplusMAC"];
    NSString *sceneName = [mainDict valueForKey:@"SceneName"];
    NSLog(@"scene name: %@", sceneName);
    NSArray *sceneEntryList = [mainDict valueForKey:@"SceneEntryList"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sceneEntryList
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:nil];
    NSString* newStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"new str: %@", newStr);
    //todo add sceneEntryList
    NSString *dynamciUpdateSceneResponse = [NSString stringWithFormat:@"{\"CommandType\":\"DynamicSceneUpdated\",\"HashNow\": \"44c1d03821da8d6a089d2fd5b0e7301b\",\"AlmondMAC\":\"%@\",\"Scenes\":{\"ID\":\"%ld\",\"Active\":\"true\",\"Name\":\"%@\",\"LastActiveEpoch\":\"251176214925585\",\"SceneEntryList\":%@}}", almondplusMAC, (long)sceneID, sceneName, newStr];
    
    NSLog(@"dynamic set/update: %@", dynamciUpdateSceneResponse);
    
    return [dynamciUpdateSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
}
-(NSData *) encodeDynamicDeleteSceneWithDict:(NSDictionary *)mainDict {
    NSInteger sceneID = [[mainDict valueForKey:@"ID"] integerValue];
    NSString *almondplusMAC = [mainDict valueForKey:@"AlmondplusMAC"];
    
    NSString *dynamcideleteSceneResponse = [NSString stringWithFormat:@"{\"CommandType\":\"DynamicSceneRemoved\",\"Scenes\":{\"ID\":\"%ld\"},\"HashNow\":\"46a5sd4fa65sd4f\",\"AlmondMAC\":\"%@\"}",(long)sceneID, almondplusMAC];
    
    return [dynamcideleteSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
}
-(NSData *) encodeDynamicActivateSceneWithDict:(NSDictionary *)mainDict {
    NSLog(@"main dict activate: %@", mainDict);
    NSString *sceneID = [mainDict valueForKey:@"ID"];
    NSString *almondplusMAC = [mainDict valueForKey:@"AlmondplusMAC"];
    
    NSString *dynamciActivateSceneResponse = [NSString stringWithFormat:@"{\"CommandType\":\"DynamicSceneActivated\",\"HashNow\":\"44c1d03821da8d6a08e7301b\",\"AlmondMAC\":\"%@\",\"Scenes\":{\"ID\":\"%@\",\"Active\":\"true\",\"LastActiveEpoch\":\"251176214925585\"}}", almondplusMAC, sceneID];
    return [dynamciActivateSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
}
-(NSData *) encodeUpdateClientWithDict:(NSDictionary *)mainDict{
    NSArray *clientsArray = [mainDict valueForKey:@"Clients"];
    NSDictionary *clientsDict = clientsArray[0];
    
    NSString *ID = [clientsDict valueForKey:@"ID"];
    NSString *Name = @"dynamic client1";
    NSString *MAC = [clientsDict valueForKey:@"MAC"];
    NSString *Connection = @"wired";
    NSString *Type = @"other";
    NSString *LastKnownIP = [clientsDict valueForKey:@"LastKnownIP"];
    NSString *Active = [clientsDict valueForKey:@"Active"];
    NSString *UseAsPresence = [clientsDict valueForKey:@"UseAsPresence"];
    
    NSString *almondMac = [mainDict valueForKey:@"AlmondMAC"];
    NSLog(@"id: %@", ID);
    
    NSLog(@"dynamic client update");
    //changing command type from "DynamicClientUpdate" to "ClientUpdate"
    NSString *dynamciClientUpdate = [NSString stringWithFormat:@"{\"CommandType\":\"ClientUpdate\",\"Clients\":[{\"ID\":\"%@\",\"Name\":\"%@\",\"MAC\":\"%@\",\"Connection\":\"%@\",\"Type\":\"%@\",\"LastKnownIP\":\"%@\",\"Active\":\"%@\",\"UseAsPresence\":\"%@\"}],\"AlmondMAC\":\"%@\",\"HashNow\":\"7efeb1a4da6e3ddd2b4e352bea828d04\"}", ID, Name, MAC, Connection, Type, LastKnownIP, Active, UseAsPresence, almondMac];
    NSLog(@"dynamicClientUpdate: %@", dynamciClientUpdate);
    return [dynamciClientUpdate dataUsingEncoding:NSUTF8StringEncoding];
}
-(NSData *) encodeRemoveClientWithDict:(NSDictionary *)mainDict{
    NSArray *clientsArray = [mainDict valueForKey:@"Clients"];
    NSDictionary *clientsDict = clientsArray[0];
    NSLog(@"main dict %@", mainDict);
    NSLog(@"clients dict: %@", clientsDict);
    NSString *clientID = [clientsDict valueForKey:@"ID"];
    NSString *MAC = [clientsDict valueForKey:@"MAC"];
    NSString *almondMac = [mainDict valueForKey:@"AlmondMAC"];
    NSLog(@"MAC: %@", MAC);
    NSLog(@"almond mac: %@", almondMac);
    //changing command type from "DynamicClientUpdate" to "RemoveClient"
    NSString *dynamciremove = [NSString stringWithFormat:@"{\"CommandType\":\"RemoveClient\",\"AlmondMAC\":\"%@\",\"Clients\":[{\"ID\":\"%@\",\"MAC\":\"%@\"}],\"HashNow\":\"7efeb1a4da6e3ddd2b4e352bea828d04\"}", almondMac, clientID, MAC];
    NSLog(@"dynamicremove: %@", dynamciremove);
    return [dynamciremove dataUsingEncoding:NSUTF8StringEncoding];
}@end
