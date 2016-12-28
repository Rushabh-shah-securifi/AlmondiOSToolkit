//
//  CommandTypes.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

typedef NS_ENUM(unsigned int, CommandType) {
    CommandType_LOGIN_COMMAND                           = 1,
    CommandType_LOGIN_RESPONSE                          = 2,
    CommandType_LOGOUT_COMMAND                          = 3,
    CommandType_LOGOUT_ALL_COMMAND                      = 4,
    CommandType_LOGOUT_ALL_RESPONSE                     = 5,
    CommandType_SIGNUP_COMMAND                          = 6,
    CommandType_SIGNUP_RESPONSE                         = 7,
    CommandType_VALIDATE_REQUEST                        = 10,
    CommandType_VALIDATE_RESPONSE                       = 11,
    CommandType_RESET_PASSWORD_REQUEST                  = 14,
    CommandType_RESET_PASSWORD_RESPONSE                 = 15,
    CommandType_LOGOUT_RESPONSE                         = 18,
    CommandType_AFFILIATION_CODE_REQUEST                = 23,
    CommandType_AFFILIATION_USER_COMPLETE               = 26,
    CommandType_ALMOND_LIST_RESPONSE                    = 72,
    CommandType_MOBILE_COMMAND                          = 61,
    CommandType_MOBILE_COMMAND_RESPONSE                 = 64,
    CommandType_DYNAMIC_DEVICE_DATA                     = 81,
    CommandType_DYNAMIC_DEVICE_VALUE_LIST		        = 82,
    CommandType_DYNAMIC_ALMOND_ADD                      = 83,
    CommandType_DYNAMIC_ALMOND_DELETE                   = 84,
    CommandType_DYNAMIC_ALMOND_NAME_CHANGE              = 85,
    CommandType_ALMOND_PROPERTY_AND_DYNAMIC_COMMAND     = 1050,
    CommandType_DYNAMIC_NOTIFICATION_PREFERENCE_LIST    = 87,
    CommandType_DYNAMIC_ALMOND_MODE_CHANGE              = 89,
    
    CommandType_LOGIN_TEMPPASS_COMMAND                  = 101,
    CommandType_CLOUD_SANITY                            = 102,
    CommandType_CLOUD_SANITY_RESPONSE                   = 103,
    CommandType_KEEP_ALIVE                              = 104,
    CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST    = 113,
    CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE   = 114,
    
    CommandType_GENERIC_COMMAND_REQUEST                 = 201,
    CommandType_GENERIC_COMMAND_RESPONSE                = 204,
    CommandType_GENERIC_COMMAND_NOTIFICATION            = 205,
    CommandType_NOTIFICATION_PREF_CHANGE_REQUEST        = 300,
    CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE       = 301,
    CommandType_SENSOR_CHANGE_REQUEST                   = 301,
    CommandType_SENSOR_CHANGE_RESPONSE                  = 304,
    
    CommandType_DEVICE_DATA_FORCED_UPDATE_REQUEST       = 321,
    CommandType_ALMOND_NAME_CHANGE_REQUEST              = 401,
    CommandType_ALMOND_NAME_CHANGE_RESPONSE             = 404,
    
    CommandType_CHANGE_PASSWORD_REQUEST                 = 251,
    CommandType_CHANGE_PASSWORD_RESPONSE                = 252,
    CommandType_DELETE_ACCOUNT_REQUEST                  = 253,
    CommandType_DELETE_ACCOUNT_RESPONSE                 = 254,
    CommandType_USER_INVITE_REQUEST                     = 255,
    CommandType_USER_INVITE_RESPONSE                    = 256,
    CommandType_ALMOND_AFFILIATION_DATA_REQUEST         = 257,
    CommandType_ALMOND_AFFILIATION_DATA_RESPONSE        = 258,
    CommandType_USER_PROFILE_REQUEST                    = 1259,
    CommandType_USER_PROFILE_RESPONSE                   = 260,
    CommandType_UPDATE_USER_PROFILE_REQUEST             = 261,
    CommandType_UPDATE_USER_PROFILE_RESPONSE            = 262,
    CommandType_ME_AS_SECONDARY_USER_REQUEST            = 263,
    CommandType_ME_AS_SECONDARY_USER_RESPONSE           = 264,
    CommandType_DELETE_SECONDARY_USER_REQUEST           = 265,
    CommandType_DELETE_SECONDARY_USER_RESPONSE          = 266,
    CommandType_DELETE_ME_AS_SECONDARY_USER_REQUEST     = 267,
    CommandType_DELETE_ME_AS_SECONDARY_USER_RESPONSE    = 268,
    CommandType_UNLINK_ALMOND_REQUEST                   = 269,
    CommandType_UNLINK_ALMOND_RESPONSE                  = 270,
    
    CommandType_NOTIFICATION_REGISTRATION               = 281,
    CommandType_NOTIFICATION_REGISTRATION_RESPONSE      = 282,
    CommandType_NOTIFICATION_DEREGISTRATION             = 283,
    CommandType_NOTIFICATION_DEREGISTRATION_RESPONSE    = 284,
    
    CommandType_ALMOND_MODE_REQUEST                     = 151,
    CommandType_ALMOND_MODE_RESPONSE                    = 152,
    
    CommandType_ALMOND_MODE_CHANGE_REQUEST              = 635,  // 61 (635)
    CommandType_ALMOND_MODE_CHANGE_RESPONSE             = 638,  // 64 (638)
    CommandType_ALMOND_COMMAND_RESPONSE                 = 2001, // internally defined command type;
    
    CommandType_ALMOND_NAME_AND_MAC_REQUEST             = 1000, // local web socket command request
    CommandType_ALMOND_NAME_AND_MAC_RESPONSE            = 1001, // local web socket command response
    
    CommandType_NOTIFICATIONS_SYNC_REQUEST              = 800,
    CommandType_NOTIFICATIONS_SYNC_RESPONSE             = 801,
    CommandType_NOTIFICATIONS_COUNT_REQUEST             = 802,
    CommandType_NOTIFICATIONS_COUNT_RESPONSE            = 803,
    
    CommandType_DEVICELOG_REQUEST                       = 804,
    CommandType_DEVICELOG_RESPONSE                      = 805,
    
    CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST       = 806,
    CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE      = 807,
    
    CommandType_UPDATE_REQUEST                          = 1061,
    CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE= 1301,
    CommandType_GET_ALL_SCENES                          = 1027,//was 1041
    //    CommandType_LIST_SCENE_RESPONSE                     = 1027, //TEST 1042
    CommandType_WIFI_CLIENTS_LIST_REQUEST               = 1523,
    CommandType_DYNAMIC_DELETE_SCENE_REQUEST            = 1053,
    CommandType_WIFI_CLIENTS_LIST_RESPONSE              = 1524,
    CommandType_COMMAND_RESPONSE                        = 1064,// for all requests will get this as response(Set/update/remove/activate etc...)
    CommandType_DYNAMIC_CLIENT_UPDATE_REQUEST           = 1541,
    CommandType_DYNAMIC_CLIENT_ADD_REQUEST              = 1543,
    CommandType_DYNAMIC_CLIENT_REMOVE_REQUEST           = 1545,
    CommandType_DYNAMIC_CLIENT_JOIN_REQUEST             = 1547,
    CommandType_DYNAMIC_CLIENT_LEFT_REQUEST             = 1549,
    CommandType_DYNAMIC_WIFI_CLIENT_REMOVED_ALL         = 1551,
    
    CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST      = 1526,
    CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST   = 1525,
    
    
    CommandType_RULE_LIST                               = 1420,
    CommandType_RULE_COMMAND_RESPONSE                   = 7064,
    
    CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES       = 1200,
    CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES        = 1300,
    CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES         = 1400,
    CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES       = 1500,
    
    CommandType_MESH_COMMAND                            = 1600,
    CommandType_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE   = 93,
    CommandType_NOTIFICATION_PREF_CHANGE_DYNAMIC_RESPONSE = 90,
    

    
    CommandType_ROUTER_COMMAND_REQUEST_RESPONSE         = 1100,

    CommandType_ACCOUNTS_RELATED                        = 1110,
    CommandType_ACCOUNTS_DYNAMIC_RESPONSE               = 1111,
    CommandType_ALMOND_LIST                             = 1112,
    CommandType_ALMOND_DYNAMIC_RESPONSE                 = 1113,

    CommandType_SUBSCRIPTIONS                           = 1010,
    CommandType_SUBSCRIBE_ME                            = 1011,
    CommandType_DYNAMIC_SUBSCRIBE_ME                    = 1012,
    CommandType_IOT_SCAN_RESULTS_REQUEST                = 1013,
   
};

// returns a string name for the specified type; useful for logging
NSString *securifi_command_type_to_string(CommandType type);

// indicates whether the type is actually a command supported by this system
BOOL securifi_valid_command_type(CommandType type);

// indicates whether the command uses a JSON payload
BOOL securifi_valid_json_command_type(CommandType type);
