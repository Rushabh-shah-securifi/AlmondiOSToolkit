//
//  NotificationPreferenceListCallbacks.h
//  SecurifiToolkit
//
//  Created by Masood on 11/1/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "NotificationPreferenceResponse.h"
#import "Network.h"
#import "NetworkState.h"
#import "NotificationRegistrationResponse.h"
#import "NotificationPreferenceListResponse.h"
#import "DynamicNotificationPreferenceList.h"
#import "NotificationListResponse.h"
#import "NotificationCountResponse.h"
#import "NotificationClearCountResponse.h"

@interface NotificationPreferenceListCallbacks : NSObject

+ (void)onDeviceNotificationPreferenceChangeResponseCallback:(NotificationPreferenceResponse*)res network:(Network *)network;

+ (void)onNotificationRegistrationResponseCallback:(NotificationRegistrationResponse *)obj;

+ (void)onNotificationDeregistrationResponseCallback:(id)sender;

+ (void)onNotificationPrefListChange:(NotificationPreferenceListResponse *)res;

+ (void)onDynamicNotificationPrefListChange:(DynamicNotificationPreferenceList *)obj;

+ (void)onNotificationListSyncResponse:(NotificationListResponse *)res network:(Network *)network;

+ (void)internalTryProcessNotificationSyncPoints;

+ (void)onNotificationCountResponse:(NotificationCountResponse *)res;

+ (void)onNotificationClearCountResponse:(NotificationClearCountResponse*)res;

@end
