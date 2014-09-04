//
//  CommandTypes.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

typedef NS_ENUM(unsigned int, CommandType) {
    CommandType_LOGIN_COMMAND                       = 1,
    CommandType_LOGIN_RESPONSE                      = 2,
    CommandType_LOGOUT_COMMAND                      = 3,
    CommandType_LOGOUT_ALL_COMMAND                  = 4,
    CommandType_LOGOUT_ALL_RESPONSE                 = 5,
    CommandType_SIGNUP_COMMAND                      = 6,
    CommandType_SIGNUP_RESPONSE                     = 7,
    CommandType_VALIDATE_REQUEST                    = 10,
    CommandType_VALIDATE_RESPONSE                   = 11,
    CommandType_RESET_PASSWORD_REQUEST              = 14,
    CommandType_RESET_PASSWORD_RESPONSE             = 15,
    CommandType_LOGOUT_RESPONSE                     = 18,
    CommandType_AFFILIATION_CODE_REQUEST            = 23,
    //CommandType_AFFILIATION_CODE_RESPONSE           = 22,
    CommandType_AFFILIATION_USER_COMPLETE           = 26,
    CommandType_ALMOND_LIST                         = 71,
    CommandType_ALMOND_LIST_RESPONSE                = 72,
    CommandType_DEVICE_DATA_HASH                    = 73,
    CommandType_DEVICE_DATA_HASH_RESPONSE           = 74,
    CommandType_DEVICE_DATA                         = 75,
    CommandType_DEVICE_DATA_RESPONSE                = 76,
    CommandType_DEVICE_VALUE					    = 77,
    CommandType_DEVICE_VALUE_LIST_RESPONSE          = 78,
    CommandType_MOBILE_COMMAND                      = 61,
    CommandType_MOBILE_COMMAND_RESPONSE             = 64,
    CommandType_DYNAMIC_DEVICE_DATA                 = 81,
    CommandType_DYNAMIC_DEVICE_VALUE_LIST		    = 82,
    CommandType_DYNAMIC_ALMOND_ADD                  = 83,
    CommandType_DYNAMIC_ALMOND_DELETE               = 84,
    CommandType_DYNAMIC_ALMOND_NAME_CHANGE          = 85,

    CommandType_LOGIN_TEMPPASS_COMMAND  = 101,
    CommandType_CLOUD_SANITY            = 102,
    CommandType_CLOUD_SANITY_RESPONSE   = 103,
    CommandType_KEEP_ALIVE              = 104,

    CommandType_GENERIC_COMMAND_REQUEST             = 201,
    CommandType_GENERIC_COMMAND_RESPONSE            = 204,
    CommandType_GENERIC_COMMAND_NOTIFICATION        = 205,
    CommandType_SENSOR_CHANGE_REQUEST               = 301,
    CommandType_SENSOR_CHANGE_RESPONSE              = 304,
    CommandType_DEVICE_DATA_FORCED_UPDATE_REQUEST   = 321,

};
