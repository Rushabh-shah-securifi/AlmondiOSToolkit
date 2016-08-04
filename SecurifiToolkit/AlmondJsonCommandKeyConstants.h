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
#define MOBILE_INTERNAL_INDEX @"MobileInternalIndex"
#define SUCCESS @"Success"
#define REASON @"Reason"

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
#define SLIDER @"SLIDER"
#define MULTI_BUTTON @"MULTI_BUTTON"
#define HUE @"HUE"
#define HUE_SLIDER @"HueSlider"
#define TEXT_VIEW @"TEXT_VIEW"
#define ACTUATOR @"Actuator"
#define SENSOR @"Sensor"
#define SINGLE_TEMP @"SINGLE_TEMP"

#define NAME_CHANGED @"NAME_CHANGE"
#define LOCATION_CHANGED @"LOCATION_CHANGE"
#define NOTIFYME @"NOTIFICATION"

//generic device key constants
#define DEVICE_NAME @"name"
#define DEVICE_DEFAULT_ICON @"defaultIcon"
#define IS_ACTION_DEVICE @"isActionDevice"
#define IS_ACTUATOR @"isActuator"
#define EXCLUDE_FROM @"ExcludeFrom"
#define INDEXES @"Indexes"
#define EVENT_TYPE @"EventType"
#define ISTRIGGER @"isTrigger"

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
#define DYNAMIC_CLIENT_REMOVEALL @"DynamicAllClientsRemoved"

#define MANUFACTURER @"Manufacturer"
#define RSSI @"RSSI"
#define LAST_ACTIVE_EPOCH @"LastActiveEpoch"

//DeviceParser
#define DEVICE_LIST @"DeviceList"
#define DYNAMIC_DEVICE_ADDED @"DynamicDeviceAdded"
#define DEVICES @"Devices"
#define DYNAMIC_DEVICE_UPDATED @"DynamicDeviceUpdated"
#define DYNAMIC_DEVICE_REMOVED @"DynamicDeviceRemoved"
#define DYNAMIC_ALL_DEVICES_REMOVED @"DynamicAllDevicesRemoved"
#define DYNAMIC_INDEX_UPDATE @"DynamicIndexUpdated"
#define DEVICE_VALUE @"DeviceValues"
#define D_TYPE @"Type"
#define D_NAME @"Name"

//help screen
#define GUIDES @"Guides"
#define WIZARDS @"Wizards"
#define HELP_TOPICS @"Help Topics"
#define SUPPORT @"Support"

#define COLOR @"color"
#define ITEMS @"items"
#define SCREENCOUNT @"screencount"
#define SCREENS @"screens"
#define TITLE @"title"
#define DESCRIPTION @"description"
#define IMAGE @"image"
#define S_ICON @"icon"

//Mesh_command
/*
 "{
 "CommandMode":"Reply",
 "CommandType":"MeshList",
 "MasterName":"Den",
 "ConnectedVia":"Directly",
 "AlmondMode":"Router Mode",
 "2.4GHzSSID":"Almond-6683",
 "5GHZSSID":"Almond-6683_5G",
 "Interface":"wired",
 
 "Slaves":[
 {"SlaveUniqueName":"Almond123","SlaveName":"Den","Interface":"Wired","SignalStrength":"Good (-40dBm)"},
 {"SlaveUniqueName":"Almond456","SlaveName":"Bedroom","Interface":"Wireless","SignalStrength":"Excellent (-10dBm)"},
 ]
 "MobileInternalIndex":"jUEppXS7ky0gbHnhGgo0uP6g15W27Gop",
 "Success":"true",
 "ReasonCode":"0"
 }"
 */
#define COMMAND_MODE @"CommandMode"
#define MASTER_NAME @"MasterName"
#define SLAVES @"Slaves"
#define SLAVE_UNIQUE_NAME @"SlaveUniqueName"
#define SLAVE_NAME @"SlaveName"
#define INTERFACE @"Interface"
#define CONNECTED_VIA @"ConnectedVia"
#define ALMOND_MODE @"AlmondMode"
#define TwoGHzSSID @"2.4GHzSSID"
#define FiveGHZSSID @"5GHZSSID"
#define ONLINE @"Online"
#define SIGNAL_STRENGTH @"SignalStrength"
#endif /* AlmondJsonCommandKeyConstants_h */
