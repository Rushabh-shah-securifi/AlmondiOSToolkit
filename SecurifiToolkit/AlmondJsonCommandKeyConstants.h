//
//  AlmondJsonCommandKeyConstants.h
//  SecurifiToolkit
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#ifndef AlmondJsonCommandKeyConstants_h
#define AlmondJsonCommandKeyConstants_h

//common
#define COMMAND_TYPE @"CommandType"

//generic index key constants
#define INDEX_NAME @"Name"
#define TYPE @"Type"
#define DATA_TYPE @"DataType"
#define PLACEMENT @"Placement"
#define HEADER @"Header"
#define HEADER_DETAIL @"Header_Detail"
#define DETAIL @"Detail"
#define LAYOUT @"Layout"
#define APP_LABEL @"AppLabel"
#define CONDITIONAL @"Conditional"
#define DEFAULT_VISIBILITY @"DefaultVisibility"
#define HAS_TOGGLE_ICON @"HasToggleIcon"
#define EXCLUDE_FROM @"ExcludeFrom"
#define INDEX_DEFAULT_ICON @"DefaultIcon"
#define VALUES @"Values"
#define TOGGLE_VALUE @"ToggleValue"
#define ICON @"Icon"
#define LABEL @"Label"
#define DEVICE_COMMAND_TYPE @"CommandType"
#define READ_ONLY @"ReadOnly"


#define FORMATTER @"Formatter"
#define MINMUM @"Min"
#define MAXIMUM @"Max"
#define RANGE @"Range"
#define UNIT @"Unit"
#define FACTOR @"Factor"

//value constants
#define TRUE_ @"true"
#define SLIDER @"Slider"
#define MULTI_BUTTON @"MULTI_BUTTON"
#define HUE @"Hue"
#define HUE_SLIDER @"HueSlider"
#define TEXT_VIEW @"TEXT_VIEW"
#define ACTUATOR @"Actuator"
#define SENSOR @"Sensor"

#define NAME_CHANGED @"NameChanged"
#define LOCATION_CHANGED @"LocationChanged"
#define NOTIFYME @"NotifyMe"

//generic device key constants
#define DEVICE_NAME @"name"
#define DEVICE_DEFAULT_ICON @"defaultIcon"
#define IS_ACTION_DEVICE @"isActionDevice"
#define IS_ACTUATOR @"isActuator"
#define EXCLUDE_FROM @"ExcludeFrom"
#define INDEXES @"Indexes"
#define EVENT_TYPE @"EventType"
#define ISTRIOGGER @"isTrigger"

#define ROW_NO @"row_no"
#define GENERIC_INDEX_ID @"genericIndexID"

#define GRID_VIEW @"GRID_VIEW"
#define LIST @"LIST"

//clients constants
#define ACTIVE @"Active"
#define INACTIVE @"InActive"
#define UNKNOWN @"UnKnown"

#define ALLOWED_TYPE_ALWAYS @"Always"
#define ALLOWED_TYPE_BLOCKED @"Blocked"
#define ALLOWED_TYPE_ONSCHEDULE @"OnSchedule"

//DevicePayload
#define MOBILE_INTERNAL_INDEX @"MobileInternalIndex"
#define UPDATE_DEVICE_INDEX @"UpdateDeviceIndex"
#define D_ID @"ID"
#define INDEX @"Index"
#define VALUE @"Value"
#define UPDATE_DEVICE_NAME @"UpdateDeviceName"
#define LOCATION @"Location"

//clientPayload
#define UPDATE_CLIENT @"UpdateClient"
#define C_ID @"ID"
#define CLIENT_NAME @"Name"
#define CONNECTION @"Connection"
#define MAC @"MAC"
#define CLIENT_TYPE @"Type"
#define LAST_KNOWN_IP @"LastKnownIP"
#define USE_AS_PRESENCE @"UseAsPresence"
#define WAIT @"Wait"
#define BLOCK @"Block"
#define SCHEDULE @"Schedule"
#define CLIENTS @"Clients"
#define CAN_BLOCK @"CanBlock"
#define CATEGORY @"Category"

//cientParser
#define CLIENTLIST @"ClientList"
#define ALMONDMAC @"AlmondMAC"

#define DYNAMIC_CLIENT_ADDED @"DynamicClientAdded"
#define DYNAMIC_CLIENT_UPDATED @"DynamicClientUpdated"
#define DYNAMIC_CLIENT_JOINED @"DynamicClientJoined"
#define DYNAMIC_CLIENT_LEFT @"DynamicClientLeft"
#define DYNAMIC_CLIENT_REMOVED @"DynamicClientRemoved"

#define MANUFACTURER @"Manufacturer"
#define RSSI @"RSSI"
#define LAST_ACTIVE_EPOCH @"LastActiveEpoch"

//DeviceParser
#define DEVICE_LIST @"DeviceList"
#define DYNAMIC_DEVICE_ADDED @"DynamicDeviceAdded"
#define DEVICES @"Devices"
#define DYNAMIC_DEVICE_UPDATED @"DynamicDeviceUpdated"
#define DYNAMIC_DEVICE_REMOVED @"DynamicDeviceRemoved"
#define DYNAMIC_DEVICE_REMOVED_ALL @"DynamicDeviceRemoveAll"
#define DYNAMIC_INDEX_UPDATE @"DynamicIndexUpdated"
#define DEVICE_VALUE @"DeviceValues"
#define D_TYPE @"Type"
#define D_NAME @"Name"

#endif /* AlmondJsonCommandKeyConstants_h */
