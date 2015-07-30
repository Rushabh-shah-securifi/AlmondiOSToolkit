//
//  CommandTypes.h
//  SecurifiToolkit
//
// Created by Matthew Sinclair-Day on 7/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "CommandTypes.h"

NSString *securifi_command_type_to_string(CommandType type) {
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

        case CommandType_DEVICE_LIST_AND_VALUES_RESPONSE:
            return [NSString stringWithFormat:@"DEVICE_LIST_AND_VALUES_RESPONSE_%d", type];
        case CommandType_ALMOND_COMMAND_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_COMMAND_RESPONSE_%d", type];
        case CommandType_ALMOND_NAME_AND_MAC_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_NAME_AND_MAC_REQUEST_%d", type];
        case CommandType_ALMOND_NAME_AND_MAC_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_NAME_AND_MAC_RESPONSE_%d", type];
        case CommandType_DEVICELOG_REQUEST:
            return [NSString stringWithFormat:@"DEVICELOG_REQUEST_%d", type];
        case CommandType_DEVICELOG_RESPONSE:
            return [NSString stringWithFormat:@"DEVICELOG_RESPONSE_%d", type];
        case CommandType_UPDATE_REQUEST:
            return [NSString stringWithFormat:@"UPDATE_REQUEST_%d", type];
        case CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE:
            return [NSString stringWithFormat:@"DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE_%d", type];
        case CommandType_GET_ALL_SCENES:
            return [NSString stringWithFormat:@"GET_ALL_SCENES_%d", type];
        case CommandType_LIST_SCENE_RESPONSE:
            return [NSString stringWithFormat:@"LIST_SCENE_RESPONSE_%d", type];
        case CommandType_DYNAMIC_DELETE_SCENE_REQUEST:
            return [NSString stringWithFormat:@"DYNAMIC_DELETE_SCENE_REQUEST_%d", type];
        case CommandType_WIFI_CLIENTS_LIST_REQUEST:
            return [NSString stringWithFormat:@"WIFI_CLIENTS_LIST_REQUEST_%d", type];
        case CommandType_WIFI_CLIENTS_LIST_RESPONSE:
            return [NSString stringWithFormat:@"WIFI_CLIENTS_LIST_RESPONSE_%d", type];
        case CommandType_COMMAND_RESPONSE:
            return [NSString stringWithFormat:@"COMMAND_RESPONSE_%d", type];
        case CommandType_DYNAMIC_CLIENT_UPDATE_REQUEST:
            return [NSString stringWithFormat:@"DYNAMIC_CLIENT_UPDATE_REQUEST_%d", type];
        case CommandType_DYNAMIC_CLIENT_ADD_REQUEST:
            return [NSString stringWithFormat:@"DYNAMIC_CLIENT_ADD_REQUEST_%d", type];
        case CommandType_DYNAMIC_CLIENT_REMOVE_REQUEST:
            return [NSString stringWithFormat:@"DYNAMIC_CLIENT_REMOVE_REQUEST_%d", type];
        case CommandType_DYNAMIC_CLIENT_JOIN_REQUEST:
            return [NSString stringWithFormat:@"DYNAMIC_CLIENT_JOIN_REQUEST_%d", type];
        case CommandType_DYNAMIC_CLIENT_LEFT_REQUEST:
            return [NSString stringWithFormat:@"DYNAMIC_CLIENT_LEFT_REQUEST_%d", type];
        case CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST:
            return [NSString stringWithFormat:@"WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST_%d", type];
        case CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST:
            return [NSString stringWithFormat:@"WIFI_CLIENT_GET_PREFERENCE_REQUEST_%d", type];
        case CommandType_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE:
            return [NSString stringWithFormat:@"WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE_%d", type];

        default: {
            return [NSString stringWithFormat:@"Unknown_%d", type];
        }
    }
}

BOOL securifi_valid_command_type(CommandType type) {
    switch (type) {
        case CommandType_LOGIN_COMMAND:
        case CommandType_LOGIN_RESPONSE:
        case CommandType_LOGOUT_COMMAND:
        case CommandType_LOGOUT_ALL_COMMAND:
        case CommandType_LOGOUT_ALL_RESPONSE:
        case CommandType_SIGNUP_COMMAND:
        case CommandType_SIGNUP_RESPONSE:
        case CommandType_VALIDATE_REQUEST:
        case CommandType_VALIDATE_RESPONSE:
        case CommandType_RESET_PASSWORD_REQUEST:
        case CommandType_RESET_PASSWORD_RESPONSE:
        case CommandType_LOGOUT_RESPONSE:
        case CommandType_AFFILIATION_CODE_REQUEST:
        case CommandType_AFFILIATION_USER_COMPLETE:
        case CommandType_ALMOND_LIST:
        case CommandType_ALMOND_LIST_RESPONSE:
        case CommandType_DEVICE_DATA_HASH:
        case CommandType_DEVICE_DATA_HASH_RESPONSE:
        case CommandType_DEVICE_DATA:
        case CommandType_DEVICE_DATA_RESPONSE:
        case CommandType_DEVICE_LIST_AND_VALUES_RESPONSE:
        case CommandType_DEVICE_VALUE:
        case CommandType_DEVICE_VALUE_LIST_RESPONSE:
        case CommandType_MOBILE_COMMAND:
        case CommandType_MOBILE_COMMAND_RESPONSE:
        case CommandType_DYNAMIC_DEVICE_DATA:
        case CommandType_DYNAMIC_DEVICE_VALUE_LIST:
        case CommandType_DYNAMIC_ALMOND_ADD:
        case CommandType_DYNAMIC_ALMOND_DELETE:
        case CommandType_DYNAMIC_ALMOND_NAME_CHANGE:
        case CommandType_DYNAMIC_NOTIFICATION_PREFERENCE_LIST:
        case CommandType_DYNAMIC_ALMOND_MODE_CHANGE:
        case CommandType_LOGIN_TEMPPASS_COMMAND:
        case CommandType_CLOUD_SANITY:
        case CommandType_CLOUD_SANITY_RESPONSE:
        case CommandType_KEEP_ALIVE:
        case CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST:
        case CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE:
        case CommandType_GENERIC_COMMAND_REQUEST:
        case CommandType_GENERIC_COMMAND_RESPONSE:
        case CommandType_GENERIC_COMMAND_NOTIFICATION:
        case CommandType_NOTIFICATION_PREF_CHANGE_REQUEST:
        case CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE:
        case CommandType_SENSOR_CHANGE_RESPONSE:
        case CommandType_DEVICE_DATA_FORCED_UPDATE_REQUEST:
        case CommandType_ALMOND_NAME_CHANGE_REQUEST:
        case CommandType_ALMOND_NAME_CHANGE_RESPONSE:
        case CommandType_CHANGE_PASSWORD_REQUEST:
        case CommandType_CHANGE_PASSWORD_RESPONSE:
        case CommandType_DELETE_ACCOUNT_REQUEST:
        case CommandType_DELETE_ACCOUNT_RESPONSE:
        case CommandType_USER_INVITE_REQUEST:
        case CommandType_USER_INVITE_RESPONSE:
        case CommandType_ALMOND_AFFILIATION_DATA_REQUEST:
        case CommandType_ALMOND_AFFILIATION_DATA_RESPONSE:
        case CommandType_USER_PROFILE_REQUEST:
        case CommandType_USER_PROFILE_RESPONSE:
        case CommandType_UPDATE_USER_PROFILE_REQUEST:
        case CommandType_UPDATE_USER_PROFILE_RESPONSE:
        case CommandType_ME_AS_SECONDARY_USER_REQUEST:
        case CommandType_ME_AS_SECONDARY_USER_RESPONSE:
        case CommandType_DELETE_SECONDARY_USER_REQUEST:
        case CommandType_DELETE_SECONDARY_USER_RESPONSE:
        case CommandType_DELETE_ME_AS_SECONDARY_USER_REQUEST:
        case CommandType_DELETE_ME_AS_SECONDARY_USER_RESPONSE:
        case CommandType_UNLINK_ALMOND_REQUEST:
        case CommandType_UNLINK_ALMOND_RESPONSE:
        case CommandType_NOTIFICATION_REGISTRATION:
        case CommandType_NOTIFICATION_REGISTRATION_RESPONSE:
        case CommandType_NOTIFICATION_DEREGISTRATION:
        case CommandType_NOTIFICATION_DEREGISTRATION_RESPONSE:
        case CommandType_ALMOND_MODE_REQUEST:
        case CommandType_ALMOND_MODE_RESPONSE:
        case CommandType_ALMOND_MODE_CHANGE_REQUEST:
        case CommandType_ALMOND_MODE_CHANGE_RESPONSE:
        case CommandType_ALMOND_COMMAND_RESPONSE:
        case CommandType_ALMOND_NAME_AND_MAC_REQUEST:
        case CommandType_ALMOND_NAME_AND_MAC_RESPONSE:
        case CommandType_NOTIFICATIONS_SYNC_REQUEST:
        case CommandType_NOTIFICATIONS_SYNC_RESPONSE:
        case CommandType_NOTIFICATIONS_COUNT_REQUEST:
        case CommandType_NOTIFICATIONS_COUNT_RESPONSE:
        case CommandType_DEVICELOG_REQUEST:
        case CommandType_DEVICELOG_RESPONSE:
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST:
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE:
        case CommandType_UPDATE_REQUEST:
        case CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE:
        case CommandType_GET_ALL_SCENES:
        case CommandType_LIST_SCENE_RESPONSE:
        case CommandType_DYNAMIC_DELETE_SCENE_REQUEST:
        case CommandType_WIFI_CLIENTS_LIST_REQUEST:
        case CommandType_WIFI_CLIENTS_LIST_RESPONSE:
        case CommandType_COMMAND_RESPONSE:
        case CommandType_DYNAMIC_CLIENT_UPDATE_REQUEST:
        case CommandType_DYNAMIC_CLIENT_ADD_REQUEST:
        case CommandType_DYNAMIC_CLIENT_REMOVE_REQUEST:
        case CommandType_DYNAMIC_CLIENT_JOIN_REQUEST:
        case CommandType_DYNAMIC_CLIENT_LEFT_REQUEST:
        case CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST:
        case CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST:
        case CommandType_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE:
            return YES;

        default:
            return NO;
    }
}

BOOL securifi_valid_json_command_type(CommandType type) {
    switch (type) {
        case CommandType_NOTIFICATIONS_SYNC_RESPONSE:
        case CommandType_NOTIFICATIONS_COUNT_RESPONSE:
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE:
        case CommandType_DEVICELOG_RESPONSE:
        case CommandType_LIST_SCENE_RESPONSE:
        case CommandType_COMMAND_RESPONSE:
        case CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE:
        case CommandType_WIFI_CLIENTS_LIST_RESPONSE:
        case CommandType_DYNAMIC_CLIENT_UPDATE_REQUEST:
        case CommandType_DYNAMIC_CLIENT_ADD_REQUEST:
        case CommandType_DYNAMIC_CLIENT_LEFT_REQUEST:
        case CommandType_DYNAMIC_CLIENT_JOIN_REQUEST:
        case CommandType_DYNAMIC_CLIENT_REMOVE_REQUEST:
        case CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST:
        case CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST:
        case CommandType_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE:
        case (CommandType) 1551:
        case (CommandType) 99:
            return YES;

        default:
            return NO;
    }
}
