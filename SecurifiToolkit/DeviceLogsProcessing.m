//
//  DeviceLogsProcessing.m
//  SecurifiToolkit
//
//  Created by Masood on 10/31/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//
#import "DeviceLogsProcessing.h"
#import "Securifitoolkit.h"
#import "Network.h"
#import "NetworkState.h"

@implementation DeviceLogsProcessing

+ (id <SFINotificationStore>)newDeviceLogStore:(NSString *)almondMac deviceId:(sfi_id)deviceId forWifiClients:(BOOL)isForWifiClients {
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    DatabaseStore *db = toolkit.deviceLogsDb;
    [db purgeAll];
    
    id <SFIDeviceLogStore> store = [db newDeviceLogStore:almondMac deviceId:deviceId delegate:self];
    [store ensureFetchNotifications:isForWifiClients]; // will callback to self (registered as delegate) to load notifications
    
    [toolkit.network.networkState clearExpirableRequest:ExpirableCommandType_deviceLogRequest namespace:almondMac];
    
    return store;
}

+ (void)tryRefreshDeviceLog:(NSString *)almondMac deviceId:(sfi_id)deviceId forWiFiClient:(BOOL)isForWifiClients {
    /*
     Mobile +++++++++>>>>  Cloud 804
     [For the first time send for first logs]
     <root>
     {mac:201243434454, device_id:19, requestId:”dajdasj”’}
     </root>
     [subsequent command]
     <root>
     {mac:201243434454, device_id:19, requestId:”dajdasj”, pageState:”12aaa12eee2eeffb1024”}
     </root>
     */
    
    // track timeouts/guard against multiple requests being sent for device logs
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        GenericCommand *storedCmd = [aNetwork.networkState expirableRequest:ExpirableCommandType_deviceLogRequest namespace:almondMac];
        if (!storedCmd) {
            [aNetwork.networkState markExpirableRequest:ExpirableCommandType_deviceLogRequest namespace:almondMac genericCommand:aCmd];
            return YES;
        }
        // give the request 5 seconds to complete
        return storedCmd.isExpired;
    };
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    DatabaseStore *store = toolkit.deviceLogsDb;
    NSString *pageState = [store nextTrackedSyncPoint];
    
    NSDictionary *payload;
    if (isForWifiClients) {
        payload = pageState ? @{
                                @"mac" : almondMac,
                                @"client_id" : @(deviceId),
                                @"requestId" : pageState,
                                @"pageState" : pageState,
                                @"type" : @"wifi_client",
                                } : @{
                                      @"mac" : almondMac,
                                      @"client_id" : @(deviceId),
                                      @"requestId" : almondMac,
                                      @"type" : @"wifi_client",
                                      };
    }else{
        payload = pageState ? @{
                                @"mac" : almondMac,
                                @"device_id" : @(deviceId),
                                @"requestId" : pageState,
                                @"pageState" : pageState,
                                } : @{
                                      @"mac" : almondMac,
                                      @"device_id" : @(deviceId),
                                      @"requestId" : almondMac,
                                      };
    }
    GenericCommand *cmd = [GenericCommand jsonPayloadCommand:payload commandType:CommandType_DEVICELOG_REQUEST];
    if (cmd) {
        cmd.networkPrecondition = precondition;
        [toolkit asyncSendToNetwork:cmd];
    }
}

+ (void)deviceLogStoreTryFetchRecords:(id <SFIDeviceLogStore>)deviceLogStore forWiFiClient:(BOOL)isForWifiClients {
    [self tryRefreshDeviceLog:deviceLogStore.almondMac deviceId:deviceLogStore.deviceID forWiFiClient:isForWifiClients];
}

+ (void)onDeviceLogSyncResponse:(NotificationListResponse *)res {
    if (!res) {
        return;
    }
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    NSString *requestId = res.requestId;
    
    // Store the notifications and stop tracking the pageState that they were associated with
    DatabaseStore *store = toolkit.deviceLogsDb;
    
    NSArray *notificationsToStore = res.notifications;
    for (SFINotification *n in notificationsToStore) {
        n.viewed = YES;
    }
    
    [store storeNotifications:notificationsToStore syncPoint:requestId];
    
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
            
            DLog(@"Already tracking sync point; halting further processing: %@", nextPageState);
        }
        else {
            // Keep track of this page state until the response has been processed
            [store trackSyncPoint:nextPageState];
        }
    }
}
@end
