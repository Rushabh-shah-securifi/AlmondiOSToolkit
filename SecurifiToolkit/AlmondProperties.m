//
//  AlmondProperties.m
//  SecurifiToolkit
//
//  Created by Masood on 12/19/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondProperties.h"
#import "SecurifiToolkit.h"
#import "NSData+Securifi.h"

@implementation AlmondProperties

+ (void)parseAlomndProperty:(NSDictionary *)payload{
    NSLog(@"parseAlomndProperty");
    AlmondProperties *almondProp = [SecurifiToolkit sharedInstance].almondProperty;
    
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
}

+ (AlmondProperties *)getTestAlmondProperties{
    AlmondProperties *almondProp = [[AlmondProperties alloc]init];
    
    almondProp.language = @"en";
    almondProp.screenTimeout = @"100";
    almondProp.screenLock = @"true";
    almondProp.screenPIN = @"encrypted pin";
    almondProp.routerMode = @"master";
    
    almondProp.checkInternetIP = @"10.10.10.10";
    almondProp.checkInternetURL = @"www.abc.com";
    almondProp.weatherCentigrade = @"1";
    almondProp.uptime = @"1234";
    almondProp.URL = @"www.url.com";
    
    almondProp.wanIP = @"10.10.22.22";
    almondProp.almondLocation = @"home";
    almondProp.autoUpdate = @"";
    almondProp.keepSameSSID = @"";
    almondProp.guestEnable = @"";
    
    almondProp.almondName = @"hero";
    almondProp.almondMode = @"home";
    almondProp.upnp = @"false";
    almondProp.webAdminEnable = @"true";
    almondProp.webAdminPassword = @"encrypted password";
    return almondProp;
}

+ (AlmondProperties *)getEmptyAlmondProperties{
    AlmondProperties *almondProp = [[AlmondProperties alloc]init];
    
    almondProp.language = @"";
    almondProp.screenTimeout = @"";
    almondProp.screenLock = @"";
    almondProp.screenPIN = @"";
    almondProp.routerMode = @"";
    
    almondProp.checkInternetIP = @"";
    almondProp.checkInternetURL = @"";
    almondProp.weatherCentigrade = @"";
    almondProp.uptime = @"";
    almondProp.URL = @"";
    
    almondProp.wanIP = @"";
    almondProp.almondLocation = @"";
    almondProp.autoUpdate = @"";
    almondProp.keepSameSSID = @"";
    almondProp.guestEnable = @"";
    
    almondProp.almondName = @"";
    almondProp.almondMode = @"";
    almondProp.upnp = @"";
    almondProp.webAdminEnable = @"";
    almondProp.webAdminPassword = @"";
    return almondProp;
}

+ (void)parseDynamicProperty:(NSDictionary *)payload{
    AlmondProperties *almondProp = [SecurifiToolkit sharedInstance].almondProperty;
    NSString *action = payload[@"Action"];
    NSString *value = payload[action];
    
    if([action isEqualToString:@"WebAdminEnable"]){
        almondProp.webAdminEnable = value;
    }
    else if([action isEqualToString:@"WebAdminPassword"]){
        almondProp.webAdminPassword = value;
        almondProp.uptime = payload[@"Uptime"];
    }
    else if([action isEqualToString:@"ScreenLock"]){
        almondProp.screenLock = value;
    }
    else if([action isEqualToString:@"ScreenTimeout"]){
        almondProp.screenTimeout = value;
    }
    else if([action isEqualToString:@"ScreenPIN"]){
        almondProp.screenPIN = value;
        almondProp.uptime = payload[@"Uptime"];
    }
    else if([action isEqualToString:@"CheckInternetIP"]){
        almondProp.checkInternetIP = value;
    }
    else if([action isEqualToString:@"CheckInternetURL"]){
        almondProp.checkInternetURL = value;
    }
    else if([action isEqualToString:@"Language"]){
        almondProp.language = value;
    }
    else if([action isEqualToString:@"Upnp"]){
        almondProp.upnp = value;
    }
    else if([action isEqualToString:@"KeepSameSSID"]){
        almondProp.keepSameSSID = value;
    }
    else if([action isEqualToString:@"AutoUpdate"]){
        almondProp.autoUpdate = value;
    }
}

+ (NSString *)getBase64EncryptedSting:(NSString *)mac uptime:(NSString *)uptime password:(NSString *)pass{
    NSData* data = [pass dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [data securifiEncryptPassword:mac uptime:uptime];
    return [encryptedData base64EncodedString];
}
@end
