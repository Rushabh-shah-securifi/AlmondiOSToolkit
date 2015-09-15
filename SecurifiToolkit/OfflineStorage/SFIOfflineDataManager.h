//
//  SFIOfflineDataManager.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFIAlmondPlus;
@class SFIAlmondLocalNetworkSettings;

@interface SFIOfflineDataManager : NSObject

- (void)writeAlmondList:(NSArray *)almondList;

- (NSArray *)readAlmondList;

- (SFIAlmondPlus *)changeAlmondName:(NSString*)name almondMac:(NSString *)almondMac;

- (void)writeHashList:(NSString *)almondHashValue almondMac:(NSString *)almondMac;

- (NSString *)readHashList:(NSString *)almondMac;

- (void)writeDeviceList:(NSArray *)deviceList almondMac:(NSString *)almondMac;

- (NSArray *)readDeviceList:(NSString *)almondMac;

- (void)writeDeviceValueList:(NSArray *)deviceValueList almondMac:(NSString *)almondMac;

- (NSArray *)readDeviceValueList:(NSString *)almondMac;

- (void)removeAllDevices:(NSString *)almondMac;

- (void)writeNotificationPreferenceList:(NSArray *)notificationList almondMac:(NSString *)almondMac;

- (NSArray *)readNotificationPreferenceList:(NSString *)almondMac;

- (void)writeAlmondLocalNetworkSettings:(SFIAlmondLocalNetworkSettings *)settings;

- (SFIAlmondLocalNetworkSettings *)readAlmondLocalNetworkSettings:(NSString *)almondMac;

// keyed by mac address
- (NSDictionary *)readAllAlmondLocalNetworkSettings;

- (void)deleteLocalNetworkSettingsForAlmond:(NSString *)strAlmondMac;

- (void)purgeAll;

// removes the specified Almond and returns the new Almond List
- (NSArray *)deleteAlmond:(SFIAlmondPlus *)almond;

@end
