//
//  AlmondProperties.m
//  SecurifiToolkit
//
//  Created by Masood on 12/19/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondProperties.h"

@implementation AlmondProperties
+ (AlmondProperties *)parseAlomndProperty:(NSDictionary *)payload{
    AlmondProperties *almondProp = [AlmondProperties new];
    almondProp.language = payload[@"Language"];
    almondProp.screenTimeout = payload[@"ScreenTimeout"];
    almondProp.screenLock = payload[@"ScreenLock"];
    almondProp.screenPIN = payload[@"ScreenPIN"];
    almondProp.routerMode = payload[@"RouterMode"];

    almondProp.checkInternetIP = payload[@"CheckInternetIP"];
    almondProp.checkInternetURL = payload[@"CheckInternetURL"];
    almondProp.weatherCentigrade = payload[@"weatherCentigrade"];
    almondProp.uptime = payload[@"Uptime"];
    almondProp.URL = payload[@"URL"];

    almondProp.wanIP = payload[@"WanIP"];
    almondProp.almondLocation = payload[@"AlmondLocation"];
    almondProp.autoUpdate = payload[@"AutoUpdate"];
    almondProp.keepSameSSID = payload[@"KeepSameSSID"];
    almondProp.guestEnable = payload[@"GuestEnable"];

    almondProp.almondName = payload[@"AlmondName"];
    almondProp.almondMode = payload[@"AlmondMode"];
    almondProp.upnp = payload[@"Upnp"];
    almondProp.webAdminEnable = payload[@"WebAdminEnable"];
    almondProp.webAdminPassword = payload[@"WebAdminPassword"];
    return almondProp;
}
@end
