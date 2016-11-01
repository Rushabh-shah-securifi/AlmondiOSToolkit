//
//  NotificationPreferenceListCallbacks.m
//  SecurifiToolkit
//
//  Created by Masood on 11/1/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//
#import "NotificationPreferenceListCallbacks.h"
#import "Securifitoolkit.h"
#import "NotificationPreferences.h"
#import "NotificationDeleteRegistrationResponse.h"
#import "NotificationAccessAndRefreshCommands.h"

@implementation NotificationPreferenceListCallbacks

+ (void)onDeviceNotificationPreferenceChangeResponseCallback:(NotificationPreferenceResponse*)res network:(Network *)network {
    
    GenericCommand *cmd = [network.networkState expirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification"];
    NotificationPreferences *req = cmd.command;
    NSLog(@"onDeviceNotificationPreferenceChangeResponseCallback req :%@", req);
    if (!req) {
        return;
    }
    
    NSString *almondMac = req.almondMAC;
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    NSArray *currentPrefs = [toolkit notificationPrefList:almondMac];
    
    NSArray *newPrefs;
    if ([req.action isEqualToString:kSFINotificationPreferenceChangeActionAdd]) {
        newPrefs = [SFINotificationDevice addNotificationDevices:req.notificationDeviceList to:currentPrefs];
    }
    else if ([req.action isEqualToString:kSFINotificationPreferenceChangeActionDelete]) {
        newPrefs = [SFINotificationDevice removeNotificationDevices:req.notificationDeviceList from:currentPrefs];
    }
    else {
        [network.networkState clearExpirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification"];
        return;
    }
    [toolkit.dataManager writeNotificationPreferenceList:newPrefs almondMac:almondMac];
    
    [network.networkState clearExpirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification"];
    
    [toolkit postNotification:kSFINotificationPreferencesListDidChange data:res];
}

+ (void)onNotificationRegistrationResponseCallback:(NotificationRegistrationResponse *)obj {
    NSString *notification;
    switch (obj.responseType) {
        case NotificationRegistrationResponseType_success:
            notification = kSFIDidRegisterForNotifications;
            break;
        case NotificationRegistrationResponseType_alreadyRegistered:
            notification = kSFIDidRegisterForNotifications;
            break;
        case NotificationRegistrationResponseType_failedToRegister:
        default:
            notification = kSFIDidFailToRegisterForNotifications;
            break;
    }
    
    [[SecurifiToolkit sharedInstance] postNotification:notification data:nil];
}

+ (void)onNotificationDeregistrationResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    
    NotificationDeleteRegistrationResponse *obj = (NotificationDeleteRegistrationResponse *) [data valueForKey:@"data"];
    NSString *notification = obj.isSuccessful ? kSFIDidDeregisterForNotifications : kSFIDidFailToDeregisterForNotifications;
    [[SecurifiToolkit sharedInstance] postNotification:notification data:nil];
}

+ (void)onNotificationPrefListChange:(NotificationPreferenceListResponse *)res {
    if (!res) {
        return;
    }
    
    NSString *currentMAC = res.almondMAC;
    if (currentMAC.length == 0) {
        return;
    }
    
    if ([res.notificationDeviceList count] != 0) {
        // Update offline storage
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        [toolkit.dataManager writeNotificationPreferenceList:res.notificationDeviceList almondMac:currentMAC];
        [toolkit postNotification:kSFINotificationPreferencesDidChange data:currentMAC];
    }
}

+ (void)onDynamicNotificationPrefListChange:(DynamicNotificationPreferenceList *)obj {
    if (obj == nil) {
        return;
    }
    
    NSString *currentMAC = obj.almondMAC;
    if (currentMAC.length == 0) {
        return;
    }
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    // Get the email id of current user
    NSString *loggedInUser = [toolkit loginEmail];
    
    // Get the notification list of that current user from offline storage
    NSMutableArray *notificationPrefUserList = obj.notificationUserList;
    
    NSArray *notificationList = obj.notificationUserList;
    for (SFINotificationUser *currentUser in notificationPrefUserList) {
        if ([currentUser.userID isEqualToString:loggedInUser]) {
            notificationList = currentUser.notificationDeviceList;
            break;
        }
    }
    
    // Update offline storage
    [toolkit.dataManager writeNotificationPreferenceList:notificationList almondMac:currentMAC];
    [toolkit postNotification:kSFINotificationPreferencesDidChange data:currentMAC];
}

+ (void)onNotificationListSyncResponse:(NotificationListResponse *)res network:(Network *)network {
    
    if (!res) {
        return;
    }
    
    NSString *requestId = res.requestId;
    
    DLog(@"asyncRefreshNotifications: recevied request id:'%@'", requestId);
    
    // Remove the guard preventing more refresh notifications
    if (requestId.length == 0) {
        // note: we are only tracking "refresh" requests to prevent more than one of them to be processed at a time.
        // these requests are not the same as "catch up" requests for older sync points that were queued for fetching
        // but not downloaded; see internalTryProcessNotificationSyncPoints.
        
        [network.networkState clearExpirableRequest:ExpirableCommandType_notificationListRequest namespace:@"notification"];
    }
    
    // Store the notifications and stop tracking the pageState that they were associated with
    //
    // As implemented, iteration will continue until a duplicate notification is detected. This procedure
    // ensures that if the system is missing some notifications, it will catch up eventually.
    // Notifications are delivered newest to oldest, making it likely all new ones are fetched in the first call.
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    DatabaseStore *store = toolkit.notificationsDb;
    
    NSUInteger newCount = res.newCount;
    NSLog(@"toolkit 801 new count: %d", newCount);
    NSArray *notificationsToStore = res.notifications;
    NSUInteger totalCount = notificationsToStore.count;
    
    // Set viewed state:
    // for new notifications...
    NSUInteger rangeEnd = newCount > totalCount ? totalCount : newCount;
    NSRange newNotificationRange = NSMakeRange(0, rangeEnd);
    for (SFINotification *notification in [notificationsToStore subarrayWithRange:newNotificationRange]) {
        notification.viewed = NO;
    }
    // for old notifications...
    NSUInteger rangeEnd_final = totalCount - rangeEnd;
    NSRange oldNotificationRange = NSMakeRange(rangeEnd, rangeEnd_final);
    for (SFINotification *notification in [notificationsToStore subarrayWithRange:oldNotificationRange]) {
        notification.viewed = YES;
    }
    
    NSInteger storedCount = [store storeNotifications:notificationsToStore syncPoint:requestId];
    NSLog(@"storedCount == totalCount %ld == %ld ",storedCount,totalCount);
    BOOL allStored = (storedCount == totalCount);
    
    if (allStored) {
        NSLog(@"asyncRefreshNotifications: stored:%li", (long) totalCount);
    }
    else {
        NSLog(@"asyncRefreshNotifications: stored partial notifications:%li of %li", (long) storedCount, (long) totalCount);
    }
    NSLog(@"storedCount isZero");
    if (storedCount == 0) {
        [NotificationAccessAndRefreshCommands setNotificationsBadgeCount:newCount];
        
        // check whether there is queued work to be done
        [self internalTryProcessNotificationSyncPoints];
        [toolkit postNotification:kSFINotificationDidStore data:nil];
        // if nothing stored, then no need to tell the world
        return;
    }
    NSLog(@"AllStore is zero");
    if (!allStored) {
        // stopped early
        // nothing more to do
        [NotificationAccessAndRefreshCommands setNotificationsBadgeCount:newCount];
        
        // Let the world know there are new notifications
        [toolkit postNotification:kSFINotificationDidStore data:nil];
        
        // check whether there is queued work to be done
        [self internalTryProcessNotificationSyncPoints];
        
        return;
    }
    
    // Let the world know there are new notifications
    [toolkit postNotification:kSFINotificationDidStore data:nil];
    
    // Keep syncing until page state is no longer provided
    if (res.isPageStateDefined) {
        // There are more pages to fetch
        NSString *nextPageState = res.pageState;
        // Guard against bug in Cloud sending back same page state, causing us to go into infinite loop
        // requesting the same page over and over.
        BOOL alreadyTracked = [store isTrackedSyncPoint:nextPageState];
        if (alreadyTracked) {
            // remove the state and halt further processing
            [store removeSyncPoint:nextPageState];
        }
        else {
            // Keep track of this page state until the response has been processed
            [store trackSyncPoint:nextPageState];
            
            // and try to download it now
            [NotificationAccessAndRefreshCommands internalAsyncFetchNotifications:nextPageState];
        }
    }
    else {
        [NotificationAccessAndRefreshCommands setNotificationsBadgeCount:newCount];
        
        // check whether there is queued work to be done
        [self internalTryProcessNotificationSyncPoints];
    }
}

// Check whether there are page states in the data store that need to be fetched.
// This could happen when the app is halted or connections break before a previous
// run completed fetching all pages.
+ (void)internalTryProcessNotificationSyncPoints {
    
    DatabaseStore *store = [SecurifiToolkit sharedInstance].notificationsDb;
    
    NSInteger count = store.countTrackedSyncPoints;
    
    if (count == 0) {
        return;
    }
    
    DLog(@"internalTryProcessNotificationSyncPoints: queued sync points: %li", (long) count);
    
    NSString *nextPageState = [store nextTrackedSyncPoint];
    if (nextPageState.length > 0) {
        DLog(@"internalTryProcessNotificationSyncPoints: fetching sync point: %@", nextPageState);
        [NotificationAccessAndRefreshCommands internalAsyncFetchNotifications:nextPageState];
    }
}

+ (void)onNotificationCountResponse:(NotificationCountResponse *)res {
    
    if (!res) {
        return;
    }
    
    if (res.error) {
        return;
    }
    
    // Store the notifications and stop tracking the pageState that they were associated with
    [NotificationAccessAndRefreshCommands setNotificationsBadgeCount:res.badgeCount];
    
    if (res.badgeCount > 0) {
        [NotificationAccessAndRefreshCommands tryRefreshNotifications];
    }
    
}

+ (void)onNotificationClearCountResponse:(NotificationClearCountResponse*)res {
    if (!res) {
        return;
    }
    if (res.error) {
        
    }
    else {
        DLog(@"onNotificationClearCountResponse: success");
    }
}

@end
