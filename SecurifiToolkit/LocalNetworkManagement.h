//
//  LocalNetworkManagement.h
//  SecurifiToolkit
//
//  Created by Masood on 10/24/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#ifndef LocalNetworkManagement_h
#define LocalNetworkManagement_h
@class SFIAlmondLocalNetworkSettings;
@class SFIRouterSummary;

@interface LocalNetworkManagement : NSObject
+ (SFIAlmondLocalNetworkSettings *)localNetworkSettingsForAlmond:(NSString *)almondMac;
+ (void)removeLocalNetworkSettingsForAlmond:(NSString *)almondMac;
+ (void)storeLocalNetworkSettings:(SFIAlmondLocalNetworkSettings *)settings;
+ (void)tryUpdateLocalNetworkSettingsForAlmond:(NSString *)almondMac withRouterSummary:(const SFIRouterSummary *)summary;
+ (SFIAlmondLocalNetworkSettings*) getCurrentLocalAlmondSettings;
@end

#endif /* LocalNetworkManagement_h */
