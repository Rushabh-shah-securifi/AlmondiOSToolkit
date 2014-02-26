//
//  Header.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "Base64.h"

#ifndef SecurifiToolkit_Header_h
#define SecurifiToolkit_Header_h

//PY: ec2-50-16-22-86.compute-1.amazonaws.com
//AD: "ec2-54-226-113-110.compute-1.amazonaws.com"
//NU: ec2-54-226-114-39.compute-1.amazonaws.com
//ec2-54-224-16-165.compute-1.amazonaws.com

//#define CLOUD_SERVER  @"ec2-54-226-114-39.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"nodeLB-1553508487.us-east-1.elb.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-226-113-110.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-205-177-169.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-242-74-175.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-226-236-86.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"ec2-54-80-216-255.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"nodeLB-1553508487.us-east-1.elb.amazonaws.com"
#define CLOUD_SERVER  @"cloud.securifi.com"
//#define CLOUD_SERVER  @"ec2-54-226-236-86.compute-1.amazonaws.com"
//#define CLOUD_SERVER  @"clouddev.securifi.com"
//#define CLOUD_SERVER  @"ec2-54-227-49-52.compute-1.amazonaws.com"
//Notifiers

#define NETWORK_DOWN_NOTIFIER               @"NetworkDOWN"
#define NETWORK_UP_NOTIFIER                 @"NetworkUP"
#define LOGIN_NOTIFIER                      @"loginResponse"
#define SIGN_UP_NOTIFIER                    @"SignupResponseNotifier"
#define AFFILIATION_CODE_NOTIFIER           @"AffiliationUserResponseNotifier"
#define AFFILIATION_COMPLETE_NOTIFIER       @"AffiliationUserCompleteNotifier"
#define ALMOND_LIST_NOTIFIER                @"AlmondListResponseNotifier"
#define HASH_NOTIFIER                       @"HashResponseNotifier"
#define DEVICE_DATA_NOTIFIER                @"DeviceListResponseNotifier"
#define DEVICE_VALUE_NOTIFIER               @"DeviceValueResponseNotifier"
#define MOBILE_COMMAND_NOTIFIER             @"MobileCommandResponseNotifier"
#define DEVICE_DATA_CLOUD_NOTIFIER          @"DeviceDataCloudResponse"
#define DEVICE_VALUE_CLOUD_NOTIFIER         @"DeviceValueListResponse"
#define GENERIC_COMMAND_NOTIFIER            @"GenericCommandResponse"
#define GENERIC_COMMAND_CLOUD_NOTIFIER      @"GenericCommandNotification"
#define VALIDATE_RESPONSE_NOTIFIER          @"ValidateAccountResponseNotifier"
#define RESET_PWD_RESPONSE_NOTIFIER         @"ResetPasswordtResponseNotifier"
#define DYNAMIC_ALMOND_LIST_ADD_NOTIFIER    @"DynamicAlmondListAddNotifier"
#define DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER @"DynamicAlmondListDeleteNotifier"
#define SENSOR_CHANGE_NOTIFIER              @"SensorChangeNotifier"
#define LOGOUT_NOTIFIER                     @"logoutResponse"
#define LOGOUT_ALL_NOTIFIER                     @"LogoutAllResponseNotifier"

#define PASSWORD @"tempPasswordPrefKey"
#define USERID @"userIDPrefKey"

//XMLS
#define FRESH_LOGIN_REQUEST_XML             @"<root><Login><EmailID>%@</EmailID><Password>%@</Password></Login></root>"
#define LOGIN_REQUEST_XML                   @"<root><Login><UserID>%@</UserID><TempPass>%@</TempPass></Login></root>"
#define LOGOUT_REQUEST_XML                  @"<root><Logout></Logout></root>"
#define SIGNUP_REQUEST_XML                  @"<root><Signup><EmailID>%@</EmailID><Password>%@</Password></Signup></root>"
#define CLOUDSANITY_REQUEST_XML             @"<root><CloudSanity>DEADBEEF</CloudSanity></root>"
#define AFFILIATION_CODE_REQUEST_XML        @"<root><AffiliationCodeRequest><Code>%@</Code></AffiliationCodeRequest></root>"
#define LOGOUT_ALL_REQUEST_XML              @"<root><LogoutAll><EmailID>%@</EmailID><Password>%@</Password></LogoutAll></root>"
#define ALMOND_LIST_REQUEST_XML             @"<root></root>"
#define DEVICE_DATA_HASH_REQUEST_XML        @"<root><DeviceDataHash><AlmondplusMAC>%@</AlmondplusMAC></DeviceDataHash></root>"
#define DEVICE_DATA_REQUEST_XML             @"<root><DeviceData><AlmondplusMAC>%@</AlmondplusMAC></DeviceData></root>"
#define DEVICE_VALUE_REQUEST_XML            @"<root><DeviceValue><AlmondplusMAC>%@</AlmondplusMAC></DeviceValue></root>"
#define MOBILE_COMMAND_REQUEST_XML          @"<root><MobileCommand><AlmondplusMAC>%@</AlmondplusMAC><Device ID=\"%@\"><NewValue Index=\"%@\">%@</NewValue></Device><MobileInternalIndex>%@</MobileInternalIndex></MobileCommand></root>"

#define GENERIC_COMMAND_REQUEST_XML         @"<root><GenericCommandRequest><AlmondplusMAC>%@</AlmondplusMAC><ApplicationID>%@</ApplicationID><MobileInternalIndex>%@</MobileInternalIndex><Data>%@</Data></GenericCommandRequest></root>"

#define VALIDATE_REQUEST_XML                @"<root><ValidateAccountRequest><EmailID>%@</EmailID></ValidateAccountRequest></root>"

#define RESET_PWD_REQUEST_XML                @"<root><ResetPasswordRequest><EmailID>%@</EmailID></ResetPasswordRequest></root>"
#define SENSOR_FORCED_UPDATE_REQUEST_XML    @"<root><DeviceDataForcedUpdate><AlmondplusMAC>%@</AlmondplusMAC><MobileInternalIndex>%@</MobileInternalIndex></DeviceDataForcedUpdate></root>"

#define SENSOR_CHANGE_REQUEST_XML    @"<root><SensorChange><AlmondplusMAC>%@</AlmondplusMAC><Device ID=\"%@\"><NewName>%@</NewName><NewLocation>%@</NewLocation></Device><MobileInternalIndex>%@</MobileInternalIndex></SensorChange></root>"

#define SENSOR_CHANGE_NAME_REQUEST_XML    @"<root><SensorChange><AlmondplusMAC>%@</AlmondplusMAC><Device ID=\"%@\"><NewName>%@</NewName></Device><MobileInternalIndex>%@</MobileInternalIndex></SensorChange></root>"

#define SENSOR_CHANGE_LOCATION_REQUEST_XML    @"<root><SensorChange><AlmondplusMAC>%@</AlmondplusMAC><Device ID=\"%@\"><NewLocation>%@</NewLocation></Device><MobileInternalIndex>%@</MobileInternalIndex></SensorChange></root>"


#define LOG_FILE_NAME  @"AlmondPlusLog.log"
#define SDK_LOG_FILE_NAME  @"AlmondPlusSDKLog.log"


#define AFFILIATION_CODE_CHAR_COUNT 6
#define SSID_CHAR_COUNT 32
#define WPAWPA2_MAX_CHAR_COUNT 32
#define WPA_MAX_CHAR_COUNT 32
#define WPA2_MAX_CHAR_COUNT 32
#define WPAWPA2_MIN_CHAR_COUNT 8
#define WPA_MIN_CHAR_COUNT 8
#define WPA2_MIN_CHAR_COUNT 8

#endif
