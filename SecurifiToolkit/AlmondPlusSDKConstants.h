//
//  Header.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#ifndef SecurifiToolkit_Header_h
#define SecurifiToolkit_Header_h

#import <SecurifiToolkit/Base64.h>

//Notifiers
#define CONNECTION_STATUS_CHANGE_NOTIFIER   @"CONNECTION_STATUS_CHANGE_NOTIFIER"
#define SIGN_UP_NOTIFIER                    @"SIGN_UP_NOTIFIER"
#define AFFILIATION_COMPLETE_NOTIFIER       @"AFFILIATION_COMPLETE_NOTIFIER"
#define MOBILE_COMMAND_NOTIFIER             @"MOBILE_COMMAND_NOTIFIER"
#define VALIDATE_RESPONSE_NOTIFIER          @"VALIDATE_RESPONSE_NOTIFIER"
#define RESET_PWD_RESPONSE_NOTIFIER         @"RESET_PWD_RESPONSE_NOTIFIER"
#define SENSOR_CHANGE_NOTIFIER              @"SENSOR_CHANGE_NOTIFIER"
#define LOGIN_PAGE_NOTIFIER                 @"LOGIN_PAGE_NOTIFIER"

// Accounts Settings
#define ACCOUNTS_RELATED                        @"ACCOUNTS_RELATED"
#define DYNAMIC_ACCOUNT_RESPONSE                @"DYNAMIC_ACCOUNT_RESPONSE"
#define RELOAD_ACCOUNTS_PAGE                    @"RELOAD_ACCOUNTS_PAGE"
#define USER_INVITE_RESPONSE                    @"USER_INVITE_REPONSE"
#define USER_PROFILE_NOTIFIER                   @"USER_PROFILE_NOTIFIER"
#define CHANGE_PWD_RESPONSE_NOTIFIER            @"CHANGE_PWD_RESPONSE_NOTIFIER"
#define DELETE_ACCOUNT_RESPONSE_NOTIFIER        @"DELETE_ACCOUNT_RESPONSE_NOTIFIER"
#define UPDATE_USER_PROFILE_NOTIFIER            @"UPDATE_USER_PROFILE_NOTIFIER"
#define ALMOND_AFFILIATION_DATA_NOTIFIER        @"ALMOND_AFFILIATION_DATA_NOTIFIER"
#define UNLINK_ALMOND_NOTIFIER                  @"UNLINK_ALMOND_NOTIFIER"
#define USER_INVITE_NOTIFIER                    @"USER_INVITE_NOTIFIER"
#define DELETE_SECONDARY_USER_NOTIFIER          @"DELETE_SECONDARY_USER_NOTIFIER"
#define ALMOND_NAME_CHANGE_NOTIFIER             @"ALMOND_NAME_CHANGE_NOTIFIER"
#define ME_AS_SECONDARY_USER_NOTIFIER           @"ME_AS_SECONDARY_USER_NOTIFIER"
#define DELETE_ME_AS_SECONDARY_USER_NOTIFIER    @"DELETE_ME_AS_SECONDARY_USER_NOTIFIER"

// Notifications
#define NOTIFICATION_REGISTRATION_NOTIFIER                  @"NOTIFICATION_REGISTRATION_NOTIFIER"

// Scenes and Wifi Clients
#define NOTIFICATION_GET_ALL_SCENES_NOTIFIER          					@"NOTIFICATION_GET_ALL_SCENES_NOTIFIER"
#define NOTIFICATION_COMMAND_RESPONSE_NOTIFIER          				@"NOTIFICATION_SET_CREATE_DELETE_ACTIVATE_SCENE_NOTIFIER"
#define NOTIFICATION_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE_NOTIFIER	@"NOTIFICATION_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE_NOTIFIER"
#define NOTIFICATION_UPDATE_SCENE_TABLEVIEW 	@"NOTIFICATION_UPDATE_SCENE_TABLEVIEW"


#define NOTIFICATION_WIFI_CLIENT_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER    @"NOTIFICATION_WIFI_CLIENT_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER"
#define NOTIFICATION_DYNAMIC_CLIENTLIST_ADD_UPDATE_REMOVE_NOTIFIER                          @"NOTIFICATION_DYNAMIC_CLIENTLIST_ADD_UPDATE_REMOVE_NOTIFIER"

#define NOTIFICATION_SCENE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER @"NOTIFICATION_SCENE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER"

#define NOTIFICATION_RULE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER @"NOTIFICATION_RULE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER"

#define NOTIFICATION_WIFI_CLIENT_GET_PREFERENCE_REQUEST_NOTIFIER 		@"NOTIFICATION_WIFI_CLIENT_GET_PREFERENCE_REQUEST_NOTIFIER"
#define NOTIFICATION_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST_NOTIFIER 	@"NOTIFICATION_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST_NOTIFIER"
#define NOTIFICATION_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE_NOTIFIER 	@"NOTIFICATION_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE_NOTIFIER"

//Rules
#define RULE_LIST_NOTIFIER                                 @"RULE_LIST_NOTIFIER"
#define RULE_COMMAND_RESPONSE_NOTIFIER                     @"RULE_COMMAND_RESPONSE_NOTIFIER"
#define SAVED_TABLEVIEW_RULE_COMMAND                       @"SAVED_TABLEVIEW_RULE_COMMAND"

//Device
#define NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER    @"NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER"
#define NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER    @"NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER"
//#define NOTIFICATION_UPDATE_DEVICE_INDEX_NOTIFIER @"NOTIFICATION_UPDATE_DEVICE_INDEX_NOTIFIER"
//#define NOTIFICATION_UPDATE_DEVICE_NAME_NOTIFIER @"NOTIFICATION_UPDATE_DEVICE_NAME_NOTIFIER"

//Router
#define NOTIFICATION_ROUTER_RESPONSE_NOTIFIER    @"NOTIFICATION_ROUTER_RESPONSE_NOTIFIER"
#define NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER    @"NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER"

//Notification
#define NOTIFICATION_CommandType_NOTIFICATION_PREF_CHANGE_DYNAMIC_RESPONSE    @"NOTIFICATION_CommandType_NOTIFICATION_PREF_CHANGE_DYNAMIC_RESPONSE"
#define NOTIFICATION_IMAGE_FETCH    @"NOTIFICATION_IMAGE_FETCH"


//Mesh
#define NOTIFICATION_COMMAND_TYPE_MESH_RESPONSE    @"NOTIFICATION_COMMAND_TYPE_MESH_RESPONSE"

//Subscription
#define SUBSCRIBE_ME_NOTIFIER    @"SUBSCRIBE_ME_NOTIFIER"
#define NOTIFICATION_COMMAND_TYPE_IOT_SCAN_RESULT    @"NOTIFICATION_COMMAND_TYPE_IOT_SCAN_RESULT"
#define NOTIFICATION_IOT_SCAN_RESULT_CONTROLLER_NOTIFIER    @"NOTIFICATION_IOT_SCAN_RESULT_CONTROLLER_NOTIFIER"

#define NOTIFICATION_SUBSCRIPTION_RESPONSE    @"NOTIFICATION_SUBSCRIPTION_RESPONSE"
#define NOTIFICATION_SUBSCRIPTION_PARSED    @"NOTIFICATION_SUBSCRIPTION_PARSED"

//Almond Properties
#define ALMOND_PROPERTY_CHANGE_DYNAMIC_NOTIFIER    @"ALMOND_PROPERTY_CHANGE_DYNAMIC_NOTIFIER"
#define NOTIFICATION_ALMOND_PROPERTIES_PARSED    @"NOTIFICATION_ALMOND_PROPERTIES_PARSED"

// XML
#define LOGOUT_REQUEST_XML                  @"<root><Logout></Logout></root>"
#define CLOUD_SANITY_REQUEST_XML            @"<root><CloudSanity>DEADBEEF</CloudSanity></root>"
#define ALMOND_LIST_REQUEST_XML             @"<root></root>"
#define PRESENT_IOT_QUICK_TIPS              @"PRESENT_IOT_QUICK_TIPS"

#endif
