//
//  CommandTypes.h
//  SecurifiToolkit
//
// Created by Matthew Sinclair-Day on 7/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "CommandTypes.h"

NSString * commandTypeToString(CommandType type) {
    switch (type) {
        case CommandType_LOGIN_COMMAND:
            return [NSString stringWithFormat:@"LOGIN_COMMAND_%d", type];
        case CommandType_LOGIN_RESPONSE:
            return [NSString stringWithFormat:@"LOGIN_RESPONSE_%d", type];
        case CommandType_LOGOUT_COMMAND:
            return [NSString stringWithFormat:@"LOGOUT_COMMAND_%d", type];
        case CommandType_LOGOUT_ALL_COMMAND:
            return [NSString stringWithFormat:@"LOGOUT_ALL_COMMAND_%d", type];
        case CommandType_LOGOUT_ALL_RESPONSE:
            return [NSString stringWithFormat:@"LOGOUT_ALL_RESPONSE_%d", type];
        case CommandType_SIGNUP_COMMAND:
            return [NSString stringWithFormat:@"SIGNUP_COMMAND_%d", type];
        case CommandType_SIGNUP_RESPONSE:
            return [NSString stringWithFormat:@"SIGNUP_RESPONSE_%d", type];
        case CommandType_VALIDATE_REQUEST:
            return [NSString stringWithFormat:@"VALIDATE_REQUEST_%d", type];
        case CommandType_VALIDATE_RESPONSE:
            return [NSString stringWithFormat:@"VALIDATE_RESPONSE_%d", type];
        case CommandType_RESET_PASSWORD_REQUEST:
            return [NSString stringWithFormat:@"RESET_PASSWORD_REQUEST_%d", type];
        case CommandType_RESET_PASSWORD_RESPONSE:
            return [NSString stringWithFormat:@"RESET_PASSWORD_RESPONSE_%d", type];
        case CommandType_LOGOUT_RESPONSE:
            return [NSString stringWithFormat:@"LOGOUT_RESPONSE_%d", type];
        case CommandType_AFFILIATION_CODE_REQUEST:
            return [NSString stringWithFormat:@"AFFILIATION_CODE_REQUEST_%d", type];
        case CommandType_AFFILIATION_USER_COMPLETE:
            return [NSString stringWithFormat:@"AFFILIATION_USER_COMPLETE_%d", type];
        case CommandType_ALMOND_LIST:
            return [NSString stringWithFormat:@"ALMOND_LIST_%d", type];
        case CommandType_ALMOND_LIST_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_LIST_RESPONSE_%d", type];
        case CommandType_DEVICE_DATA_HASH:
            return [NSString stringWithFormat:@"DEVICE_DATA_HASH_%d", type];
        case CommandType_DEVICE_DATA_HASH_RESPONSE:
            return [NSString stringWithFormat:@"DEVICE_DATA_HASH_RESPONSE_%d", type];
        case CommandType_DEVICE_DATA:
            return [NSString stringWithFormat:@"DEVICE_DATA_%d", type];
        case CommandType_DEVICE_DATA_RESPONSE:
            return [NSString stringWithFormat:@"DEVICE_DATA_RESPONSE_%d", type];
        case CommandType_DEVICE_VALUE:
            return [NSString stringWithFormat:@"DEVICE_VALUE_%d", type];
        case CommandType_DEVICE_VALUE_LIST_RESPONSE:
            return [NSString stringWithFormat:@"DEVICE_VALUE_LIST_RESPONSE_%d", type];
        case CommandType_MOBILE_COMMAND:
            return [NSString stringWithFormat:@"MOBILE_COMMAND_%d", type];
        case CommandType_MOBILE_COMMAND_RESPONSE:
            return [NSString stringWithFormat:@"MOBILE_COMMAND_RESPONSE_%d", type];
        case CommandType_DYNAMIC_DEVICE_DATA:
            return [NSString stringWithFormat:@"DYNAMIC_DEVICE_DATA_%d", type];
        case CommandType_DYNAMIC_DEVICE_VALUE_LIST:
            return [NSString stringWithFormat:@"DYNAMIC_DEVICE_VALUE_LIST_%d", type];
        case CommandType_DYNAMIC_ALMOND_ADD:
            return [NSString stringWithFormat:@"DYNAMIC_ALMOND_ADD_%d", type];
        case CommandType_DYNAMIC_ALMOND_DELETE:
            return [NSString stringWithFormat:@"DYNAMIC_ALMOND_DELETE_%d", type];
        case CommandType_DYNAMIC_ALMOND_NAME_CHANGE:
            return [NSString stringWithFormat:@"DYNAMIC_ALMOND_NAME_CHANGE_%d", type];
        case CommandType_LOGIN_TEMPPASS_COMMAND:
            return [NSString stringWithFormat:@"LOGIN_TEMPPASS_COMMAND_%d", type];
        case CommandType_CLOUD_SANITY:
            return [NSString stringWithFormat:@"CLOUD_SANITY_%d", type];
        case CommandType_CLOUD_SANITY_RESPONSE:
            return [NSString stringWithFormat:@"CLOUD_SANITY_RESPONSE_%d", type];
        case CommandType_KEEP_ALIVE:
            return [NSString stringWithFormat:@"KEEP_ALIVE_%d", type];
        case CommandType_GENERIC_COMMAND_REQUEST:
            return [NSString stringWithFormat:@"GENERIC_COMMAND_REQUEST_%d", type];
        case CommandType_GENERIC_COMMAND_RESPONSE:
            return [NSString stringWithFormat:@"GENERIC_COMMAND_RESPONSE_%d", type];
        case CommandType_GENERIC_COMMAND_NOTIFICATION:
            return [NSString stringWithFormat:@"GENERIC_COMMAND_NOTIFICATION_%d", type];
//        case CommandType_SENSOR_CHANGE_REQUEST:
//            return [NSString stringWithFormat:@"SENSOR_CHANGE_REQUEST_%d", type];
//        case CommandType_SENSOR_CHANGE_RESPONSE:
//            return [NSString stringWithFormat:@"SENSOR_CHANGE_RESPONSE_%d", type];
        case CommandType_DEVICE_DATA_FORCED_UPDATE_REQUEST:
            return [NSString stringWithFormat:@"DEVICE_DATA_FORCED_UPDATE_REQUEST_%d", type];
        case CommandType_ALMOND_NAME_CHANGE_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_NAME_CHANGE_REQUEST_%d", type];
        case CommandType_ALMOND_NAME_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_NAME_CHANGE_RESPONSE_%d", type];
        case CommandType_ALMOND_MODE_CHANGE_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_MODE_CHANGE_REQUEST_%d", type];
        case CommandType_ALMOND_MODE_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_MODE_CHANGE_RESPONSE_%d", type];
        case CommandType_CHANGE_PASSWORD_REQUEST:
            return [NSString stringWithFormat:@"CHANGE_PASSWORD_REQUEST_%d", type];
        case CommandType_CHANGE_PASSWORD_RESPONSE:
            return [NSString stringWithFormat:@"CHANGE_PASSWORD_RESPONSE_%d", type];
        case CommandType_DELETE_ACCOUNT_REQUEST:
            return [NSString stringWithFormat:@"DELETE_ACCOUNT_REQUEST_%d", type];
        case CommandType_DELETE_ACCOUNT_RESPONSE:
            return [NSString stringWithFormat:@"DELETE_ACCOUNT_RESPONSE_%d", type];
        case CommandType_USER_INVITE_REQUEST:
            return [NSString stringWithFormat:@"USER_INVITE_REQUEST_%d", type];
        case CommandType_USER_INVITE_RESPONSE:
            return [NSString stringWithFormat:@"USER_INVITE_RESPONSE_%d", type];
        case CommandType_ALMOND_AFFILIATION_DATA_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_AFFILIATION_DATA_REQUEST_%d", type];
        case CommandType_ALMOND_AFFILIATION_DATA_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_AFFILIATION_DATA_RESPONSE_%d", type];
        case CommandType_USER_PROFILE_REQUEST:
            return [NSString stringWithFormat:@"USER_PROFILE_REQUEST_%d", type];
        case CommandType_USER_PROFILE_RESPONSE:
            return [NSString stringWithFormat:@"USER_PROFILE_RESPONSE_%d", type];
        case CommandType_UPDATE_USER_PROFILE_REQUEST:
            return [NSString stringWithFormat:@"UPDATE_USER_PROFILE_REQUEST_%d", type];
        case CommandType_UPDATE_USER_PROFILE_RESPONSE:
            return [NSString stringWithFormat:@"UPDATE_USER_PROFILE_RESPONSE_%d", type];
        case CommandType_ME_AS_SECONDARY_USER_REQUEST:
            return [NSString stringWithFormat:@"ME_AS_SECONDARY_USER_REQUEST_%d", type];
        case CommandType_ME_AS_SECONDARY_USER_RESPONSE:
            return [NSString stringWithFormat:@"ME_AS_SECONDARY_USER_RESPONSE_%d", type];
        case CommandType_DELETE_SECONDARY_USER_REQUEST:
            return [NSString stringWithFormat:@"DELETE_SECONDARY_USER_REQUEST_%d", type];
        case CommandType_DELETE_SECONDARY_USER_RESPONSE:
            return [NSString stringWithFormat:@"DELETE_SECONDARY_USER_RESPONSE_%d", type];
        case CommandType_DELETE_ME_AS_SECONDARY_USER_REQUEST:
            return [NSString stringWithFormat:@"DELETE_ME_AS_SECONDARY_USER_REQUEST_%d", type];
        case CommandType_DELETE_ME_AS_SECONDARY_USER_RESPONSE:
            return [NSString stringWithFormat:@"DELETE_ME_AS_SECONDARY_USER_RESPONSE_%d", type];
        case CommandType_UNLINK_ALMOND_REQUEST:
            return [NSString stringWithFormat:@"UNLINK_ALMOND_REQUEST_%d", type];
        case CommandType_UNLINK_ALMOND_RESPONSE:
            return [NSString stringWithFormat:@"UNLINK_ALMOND_RESPONSE_%d", type];
        case CommandType_NOTIFICATION_PREF_CHANGE_REQUEST:
            return [NSString stringWithFormat:@"NOTIFICATION_PREF_CHANGE_REQUEST_%d", type];
        case CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATION_PREF_CHANGE_RESPONSE_%d", type];
        case CommandType_NOTIFICATION_REGISTRATION:
            return [NSString stringWithFormat:@"NOTIFICATION_REGISTRATION_%d", type];
        case CommandType_NOTIFICATION_REGISTRATION_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATION_REGISTRATION_RESPONSE_%d", type];
        case CommandType_NOTIFICATION_DEREGISTRATION:
            return [NSString stringWithFormat:@"NOTIFICATION_DEREGISTRATION_%d", type];
        case CommandType_NOTIFICATION_DEREGISTRATION_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATION_DEREGISTRATION_RESPONSE_%d", type];
        case CommandType_DYNAMIC_NOTIFICATION_PREFERENCE_LIST:
            return [NSString stringWithFormat:@"DYNAMIC_NOTIFICATION_PREFERENCE_LIST_%d", type];
        case CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST:
            return [NSString stringWithFormat:@"NOTIFICATION_PREFERENCE_LIST_REQUEST_%d", type];
        case CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATION_PREFERENCE_LIST_RESPONSE_%d", type];
        case CommandType_DYNAMIC_ALMOND_MODE_CHANGE:
            return [NSString stringWithFormat:@"DYNAMIC_ALMOND_MODE_CHANGE_%d", type];
        case CommandType_SENSOR_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"SENSOR_CHANGE_RESPONSE_%d", type];
        case CommandType_ALMOND_MODE_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_MODE_REQUEST_%d", type];
        case CommandType_ALMOND_MODE_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_MODE_RESPONSE_%d", type];

        case CommandType_NOTIFICATIONS_SYNC_REQUEST:
            return [NSString stringWithFormat:@"NOTIFICATIONS_SYNC_REQUEST_%d", type];
        case CommandType_NOTIFICATIONS_SYNC_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATIONS_SYNC_RESPONSE_%d", type];

        case CommandType_NOTIFICATIONS_COUNT_REQUEST:
            return [NSString stringWithFormat:@"NOTIFICATIONS_COUNT_REQUEST_%d", type];
        case CommandType_NOTIFICATIONS_COUNT_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATIONS_COUNT_RESPONSE_%d", type];
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST:
            return [NSString stringWithFormat:@"NOTIFICATIONS_CLEAR_COUNT_REQUEST_%d", type];
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATIONS_CLEAR_COUNT_RESPONSE_%d", type];

        default: {
            return [NSString stringWithFormat:@"Unknown_%d", type];
        }
    }
}
