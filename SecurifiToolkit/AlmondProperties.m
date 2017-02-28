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
    almondProp.uptime = payload[@"Uptime"];

    almondProp.routerMode = payload[@"RouterMode"];
    almondProp.checkInternetIP = payload[@"CheckInternetIP"];
    almondProp.checkInternetURL = payload[@"CheckInternetURL"];
    almondProp.weatherCentigrade = payload[@"weatherCentigrade"];
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
    almondProp.uptime1 = payload[@"Uptime1"];
    
    almondProp.temperatureUnit = @"\u00B0F";//to do replace constant with payload[@"TemperatureUnit"]
    almondProp.timeZone = payload[@"TimeZone"];
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
    
    almondProp.temperatureUnit = @"\u00B0F";
    almondProp.timeZone = @"IST-5:30";
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
    
    almondProp.temperatureUnit = @"";
    almondProp.timeZone = @"";
    return almondProp;
}

+ (void)parseNewDynamicProperty:(NSDictionary *)payload{
    NSLog(@"parseNewDynamicProperty 1");
    NSDictionary *almondPropery = payload[@"AlmondProperties"];
    for(NSString *action in almondPropery.allKeys){
        [self updateProperty:action value:almondPropery[action]];
    }
}

+ (void)parseDynamicProperty:(NSDictionary *)payload{
    NSString *action = payload[@"Action"];
    NSString *value = payload[action];
    NSLog(@"parseNewDynamicProperty 1");
    [self updateProperty:action value:value];
}

+ (void)updateProperty:(NSString*)action value:(NSString *)value{
    NSLog(@"update property");
    AlmondProperties *almondProp = [SecurifiToolkit sharedInstance].almondProperty;
    
    if([action isEqualToString:@"WebAdminEnable"]){
        almondProp.webAdminEnable = value;
    }
    else if([action isEqualToString:@"WebAdminPassword"]){
        almondProp.webAdminPassword = value;
    }
    else if([action isEqualToString:@"Uptime1"]){
        almondProp.uptime1 = value;
    }
    else if([action isEqualToString:@"ScreenLock"]){
        almondProp.screenLock = value;
    }
    else if([action isEqualToString:@"ScreenTimeout"]){
        almondProp.screenTimeout = value;
    }
    else if([action isEqualToString:@"ScreenPIN"]){
        almondProp.screenPIN = value;
    }
    else if([action isEqualToString:@"Uptime"]){
        almondProp.uptime = value;
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
    else if([action hasPrefix:@"Temperature"]){
        almondProp.temperatureUnit = value;
    }
    else if([action isEqualToString:@"TimeZone"]){
        almondProp.timeZone = value;
    }
}

+ (NSString *)getBase64EncryptedSting:(NSString *)mac uptime:(NSString *)uptime password:(NSString *)pass{
    NSData* immutdata = [pass dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mutableData = [immutdata mutableCopy];
    NSLog(@"datalength bf: %d", mutableData.length);
    for(int i = 0; i < 128 - immutdata.length; i++){
        unsigned char zeroByte = 0;
        [mutableData appendBytes:&zeroByte length:1];
    }
    NSLog(@"datalength af: %d", mutableData.length);
    NSData *encryptedData = [mutableData securifiEncryptPassword:mac uptime:uptime];
    return [encryptedData base64EncodedString];
}
@end
