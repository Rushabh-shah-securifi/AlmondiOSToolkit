//
//  AlmondProperties.h
//  SecurifiToolkit
//
//  Created by Masood on 12/19/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlmondProperties : NSObject
@property (nonatomic) NSString *language;
@property (nonatomic) NSString *screenTimeout;
@property (nonatomic) NSString *screenLock;
@property (nonatomic) NSString *screenPIN;
@property (nonatomic) NSString *routerMode;

@property (nonatomic) NSString *checkInternetIP;
@property (nonatomic) NSString *checkInternetURL;
@property (nonatomic) NSString *weatherCentigrade;
@property (nonatomic) NSString *uptime;
@property (nonatomic) NSString *URL;

@property (nonatomic) NSString *wanIP;
@property (nonatomic) NSString *almondLocation;
@property (nonatomic) NSString *autoUpdate;
@property (nonatomic) NSString *keepSameSSID;
@property (nonatomic) NSString *guestEnable;

@property (nonatomic) NSString *almondName;
@property (nonatomic) NSString *almondMode;
@property (nonatomic) NSString *upnp;
@property (nonatomic) NSString *webAdminEnable;
@property (nonatomic) NSString *webAdminPassword;

+ (AlmondProperties *)parseAlomndProperty:(NSDictionary *)payload;
@end
