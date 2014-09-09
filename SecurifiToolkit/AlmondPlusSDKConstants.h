//
//  Header.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#ifndef SecurifiToolkit_Header_h
#define SecurifiToolkit_Header_h

#import <SecurifiToolkit/Base64.h>


//PY: ec2-50-16-22-86.compute-1.amazonaws.com
//AD: "ec2-54-226-113-110.compute-1.amazonaws.com"
//NU: ec2-54-226-114-39.compute-1.amazonaws.com
//ec2-54-224-16-165.compute-1.amazonaws.com

#define CLOUD_PROD_SERVER  @"cloud.securifi.com"
#define CLOUD_DEV_SERVER  @"clouddev.securifi.com"

//#define CLOUD_SERVER  @"ec2-54-226-114-39.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"nodeLB-1553508487.us-east-1.elb.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-226-113-110.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-205-177-169.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-242-74-175.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-226-236-86.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-80-216-255.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"nodeLB-1553508487.us-east-1.elb.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-226-236-86.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-227-49-52.compute-1.amazonaws.com"
//Notifiers

#define NETWORK_CONNECTING_NOTIFIER         @"NETWORK_CONNECTING_NOTIFIER"
#define NETWORK_DOWN_NOTIFIER               @"NETWORK_DOWN_NOTIFIER"
#define NETWORK_UP_NOTIFIER                 @"NETWORK_UP_NOTIFIER"
#define LOGIN_NOTIFIER                      @"LOGIN_NOTIFIER"
#define SIGN_UP_NOTIFIER                    @"SIGN_UP_NOTIFIER"
#define AFFILIATION_CODE_NOTIFIER           @"AFFILIATION_CODE_NOTIFIER"
#define AFFILIATION_COMPLETE_NOTIFIER       @"AFFILIATION_COMPLETE_NOTIFIER"
#define ALMOND_LIST_NOTIFIER                @"ALMOND_LIST_NOTIFIER"
#define DEVICEDATA_HASH_NOTIFIER            @"DEVICEDATA_HASH_NOTIFIER"
#define DEVICE_DATA_NOTIFIER                @"DEVICE_DATA_NOTIFIER"
#define DEVICE_VALUE_LIST_NOTIFIER          @"DEVICE_VALUE_LIST_NOTIFIER"
#define MOBILE_COMMAND_NOTIFIER             @"MOBILE_COMMAND_NOTIFIER"
#define DYNAMIC_DEVICE_DATA_NOTIFIER        @"DYNAMIC_DEVICE_DATA_NOTIFIER"
#define DYNAMIC_DEVICE_VALUE_LIST_NOTIFIER  @"DYNAMIC_DEVICE_VALUE_LIST_NOTIFIER"
#define GENERIC_COMMAND_NOTIFIER            @"GENERIC_COMMAND_NOTIFIER"
#define GENERIC_COMMAND_CLOUD_NOTIFIER      @"GENERIC_COMMAND_CLOUD_NOTIFIER"
#define VALIDATE_RESPONSE_NOTIFIER          @"VALIDATE_RESPONSE_NOTIFIER"
#define RESET_PWD_RESPONSE_NOTIFIER         @"RESET_PWD_RESPONSE_NOTIFIER"
#define DYNAMIC_ALMOND_LIST_ADD_NOTIFIER    @"DYNAMIC_ALMOND_LIST_ADD_NOTIFIER"
#define DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER @"DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER"
#define SENSOR_CHANGE_NOTIFIER              @"SENSOR_CHANGE_NOTIFIER"
#define LOGOUT_NOTIFIER                     @"LOGOUT_NOTIFIER"
#define LOGOUT_ALL_NOTIFIER                 @"LOGOUT_ALL_NOTIFIER"
#define DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER @"DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER"

#define ALMONDLIST_FILENAME @"almondlist"
#define HASH_FILENAME @"hashlist"
#define DEVICELIST_FILENAME  @"devicelist"
#define DEVICEVALUE_FILENAME @"devicevalue"

#define LOG_FILE_NAME  @"AlmondPlusLog.log"
#define SDK_LOG_FILE_NAME  @"AlmondPlusSDKLog.log"

#define COLORS @"colors"
#define ALMONDLIST @"AlmondList"
#define SETTINGS_LIST @"Settings"

//XMLS
#define LOGOUT_REQUEST_XML                  @"<root><Logout></Logout></root>"
#define CLOUD_SANITY_REQUEST_XML            @"<root><CloudSanity>DEADBEEF</CloudSanity></root>"
#define ALMOND_LIST_REQUEST_XML             @"<root></root>"

#define AFFILIATION_CODE_CHAR_COUNT 6
#define SSID_CHAR_COUNT 32
#define WPAWPA2_MAX_CHAR_COUNT 32
#define WPA_MAX_CHAR_COUNT 32
#define WPA2_MAX_CHAR_COUNT 32
#define WPAWPA2_MIN_CHAR_COUNT 8
#define WPA_MIN_CHAR_COUNT 8
#define WPA2_MIN_CHAR_COUNT 8

#endif
