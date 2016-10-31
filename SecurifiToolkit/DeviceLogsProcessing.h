//
//  DeviceLogsProcessing.h
//  SecurifiToolkit
//
//  Created by Masood on 10/31/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "NotificationListResponse.h"
#import "SFINotificationStore.h"

@interface DeviceLogsProcessing : NSObject <SFIDeviceLogStoreDelegate>

+ (id <SFINotificationStore>)newDeviceLogStore:(NSString *)almondMac deviceId:(sfi_id)deviceId forWifiClients:(BOOL)isForWifiClients;

+ (void)deviceLogStoreTryFetchRecords:(id <SFIDeviceLogStore>)deviceLogStore forWiFiClient:(BOOL)isForWifiClients;

+ (void)onDeviceLogSyncResponse:(NotificationListResponse *)res;
@end
