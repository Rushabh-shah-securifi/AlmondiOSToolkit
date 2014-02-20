//
//  CommandTypes.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#ifndef SecurifiToolkit_CommandTypes_h
#define SecurifiToolkit_CommandTypes_h

#define LOGIN_COMMAND                       1
#define LOGIN_RESPONSE                      2
#define LOGOUT_COMMAND                      3
#define LOGOUT_ALL_COMMAND                  4
#define LOGOUT_ALL_RESPONSE                 5
#define SIGNUP_COMMAND                      6
#define SIGNUP_RESPONSE                     7
#define VALIDATE_REQUEST                    10
#define VALIDATE_RESPONSE                   11
#define RESET_PASSWORD_REQUEST              14
#define RESET_PASSWORD_RESPONSE             15
#define AFFILIATION_CODE_REQUEST            23
//#define AFFILIATION_CODE_RESPONSE           22
#define AFFILIATION_USER_COMPLETE           26
#define ALMOND_LIST                         71
#define ALMOND_LIST_RESPONSE                72
#define DEVICEDATA_HASH                     73
#define DEVICEDATA_HASH_RESPONSE            74
#define DEVICEDATA                          75
#define DEVICEDATA_RESPONSE                 76
#define DEVICE_VALUE						77
#define DEVICE_VALUE_LIST_RESPONSE          78
#define MOBILE_COMMAND                      61
#define MOBILE_COMMAND_RESPONSE             64
#define DYNAMIC_DEVICE_DATA                 81
#define DYNAMIC_DEVICE_VALUE_LIST			82
#define DYNAMIC_ALMOND_ADD                  83
#define DYNAMIC_ALMOND_DELETE               84
#define GENERIC_COMMAND_REQUEST             201
#define GENERIC_COMMAND_RESPONSE            204
#define GENERIC_COMMAND_NOTIFICATION        205
#define SENSOR_CHANGE_REQUEST               301
#define SENSOR_CHANGE_RESPONSE              304
#define DEVICE_DATA_FORCED_UPDATE_REQUEST   321

#endif
