//
//  Client.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "Client.h"
#import "SecurifiToolkit.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "AlmondManagement.h"

@implementation Client

- (NSString *)iconName {
    if ([[self.deviceType lowercaseString] isEqualToString:@"tv"]) {
        return @"appletv_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"other"]) {
        return @"help_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"mac"]) {
        return @"pc_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"hub"]) {
        return @"hubrouter_icon";
    }

    if ([[self.deviceType lowercaseString] isEqualToString:@"router_switch"]) {
        return @"hubrouter_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"tablet"]) {
        return @"tablet_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"android_stick"]) {
        return @"android_stick_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"chromecast"]) {
        return @"chrome_cast_icon";
    }

    if ([[self.deviceType lowercaseString] isEqualToString:@"nest"]) {
        return @"nest_google_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"printer"]) {
        return @"printer_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"pc"]) {
        return @"pc_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"laptop"]) {
        return @"laptop_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"smartphone"]) {
        return @"smartphone_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"iphone"]) {
        return @"iphone_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"ipad"]) {
        return @"ipad_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"ipod"]) {
        return @"ipod_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"appletv"]) {
        return @"appletv_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"camera"]) {
        return @"camera_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"amazon_echo"]) {
        return @"amazon_echo";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"amazon_dash"]) {
        return @"amazon_dash";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"philips_hue"]) {
        return @"philips_hue_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"scout_home_system"]) {
        return @"scout_hub_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"skybell_wifi"]) {
        return @"skybell_icon";
    }//
    if ([[self.deviceType lowercaseString] isEqualToString:@"august_connect"]) {
        return @"august_connect_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"canary"]) {
        return @"canary_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"piper"]) {
        return @"piper_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"ring_doorbell"]) {
        return @"skybell_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"samsung_smartthings"]) {
        return @"smartthings_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"belkin_wemo"]) {
        return @"wemo_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"sonos"]) {
        return @"speaker_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"airplay_speakers"]) {
        return @"speaker_icon";
    }//
    if ([[self.deviceType lowercaseString] isEqualToString:@"wink"]) {
        return @"wink_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"canary"]) {
        return @"canary_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"ge_appliances"]) {
        return @"ge_appliances_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"honeywell_appliances"]) {
        return @"ge_appliances_icon";
    }//
    if ([[self.deviceType lowercaseString] isEqualToString:@"osram_lightify"]) {
        return @"osram_lightify";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"ibaby_monitor"]) {
        return @"videocam_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"motorola_connect"]) {
        return @"videocam_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"foscam"]) {
        return @"videocam_icon";
    }//
    if ([[self.deviceType lowercaseString] isEqualToString:@"hikvision"]) {
        return @"videocam_icon";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"dlink_cameras"]) {
        return @"videocam_icon";
    }
    
    if ([[self.deviceType lowercaseString] isEqualToString:@"withings"]) {
        return @"videocam_icon";
    }
    return @"help_icon";
}

- (NSString *)getNotificationTypeByName:(NSString *)name {
    if ([[name lowercaseString] isEqualToString:@"always"]) {
        return @"1";
    }
    if ([[name lowercaseString] isEqualToString:@"never"]) {
        return @"0";
    }
    if ([[name lowercaseString] isEqualToString:@"when i'm away"]) {
        return @"3";
    }
    return @"0";
}

- (NSString *)getNotificationNameByType:(NSString *)type {
    switch ([type integerValue]) {
        case 0:
            return @"Never";
        case 1:
            return @"Always";
        case 3:
            return @"When I'm away";

        default:
            break;
    }
    return @"";
}

+ (Client *)findClientByID:(NSString*)clientID{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for(Client *client in toolkit.clients){
        if([client.deviceID isEqualToString:clientID]){
            return client;
        }
    }
    return nil;
}

+ (BOOL)findClientByMAC:(NSString *)mac{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for(Client *client in toolkit.clients){
        if([mac isEqualToString:client.deviceMAC])
            return YES;
    }
    return NO;
}

+ (Client*)getClientByMAC:(NSString *)mac{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance] ;
    for(Client *client in toolkit.clients){
       
        if([mac isEqualToString:client.deviceMAC]){
            return client;
        }
        
    }
    return nil;
}

+(NSString *)getScheduleById:(NSString*)clientId{
    Client *client = [self findClientByID:clientId];
    return client.deviceSchedule;
}

+(BOOL)isSiteMapCompatableLocal{
    SecurifiToolkit *toolKit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    bool isLocal = [toolKit useLocalNetwork:almond.almondplusMAC];
    return isLocal;
}

+(BOOL)siteMapCompatbleFW{
    SecurifiToolkit *toolKit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL isSiteMapSupport = [[AlmondManagement currentAlmond] siteMapSupportFirmware:[AlmondManagement currentAlmond].firmware];
    return isSiteMapSupport;
}

+(NSArray*) getClientGenericIndexes{
        NSArray *genericIndexesArray = [NSArray arrayWithObjects:@-11,@-12,@-13,@-14,@-15,@-16,@-17,@-18,@-21,@-22,@-19,@-20,@-3,@-25,nil];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
     BOOL local = [toolkit useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    if([self siteMapCompatbleFW] && [SecurifiToolkit sharedInstance].configuration.siteMapEnable && [SecurifiToolkit sharedInstance].configuration.isPaymentDone && !local){
         return [NSArray arrayWithObjects:@-11,@-12,@-13,@-14,@-15,@-16,@-17,@-18,@-21,@-22,@-23,@-26,@-19,@-20,@-3,@-25,nil];
    }
    //for commenting browsing history code
//    NSArray *genericIndexesArray = [NSArray arrayWithObjects:@-11,@-12,@-13,@-14,@-15,@-16,@-17,@-18,@-21,@-22,@-19,@-20,@-3,nil];
    return genericIndexesArray;
}

+(NSString*)getOrSetValueForClient:(Client*)client genericIndex:(int)genericIndex newValue:(NSString*)newValue ifGet:(BOOL)get{
    switch (genericIndex) {
        case -11:{
            client.name=get? client.name:newValue;
            return client.name;
        }
        case -12:
        {
            client.deviceType=get? client.deviceType:newValue;
            return client.deviceType;
        }
        case -13:
        {
            client.manufacturer=get? client.manufacturer:newValue;
            return client.manufacturer;
        }
        case -14:
        {
            client.deviceMAC=get? client.deviceMAC:newValue;
            return client.deviceMAC;
        }
        case -15:
        {
            client.deviceIP=get? client.deviceIP:newValue;
            return client.deviceIP;
        }
        case -16:
        {
            client.deviceConnection=get? client.deviceConnection:newValue;
            return client.deviceConnection;
        }
        case -17:
        {
            if(get)
                return client.deviceUseAsPresence?@"true":@"false";
            else
                client.deviceUseAsPresence = newValue.boolValue;
            break;
        }
        case -18:
        {
            if(get)
                return @(client.timeout).stringValue;
            else
                client.timeout = newValue.integerValue;
            break;
        }
        case -19:{
            if(get)
                return @(client.deviceAllowedType).stringValue;
            else{
                [self updateAllowOnNetworkAndSchedule:client blockedString:newValue];
            }
            
            break;
        }
        case -20:
        {
            client.rssi=get? client.rssi:newValue;
            return [NSString stringWithFormat:@"%@ dBm", client.rssi];
        }
        case -21:{
            if(get)
                return client.canBeBlocked? @"true": @"false";
            else{
                client.canBeBlocked = newValue.boolValue;
            }
        }
        case -22:{
            client.category = get? client.category: newValue;
            return  client.category;
        }
        case -23:{
            if(get)
            return client.webHistoryEnable? @"true": @"false";
            else{
                client.webHistoryEnable = newValue.boolValue;
            }
            break;
        }
        case -24:{
            if(get)
                return client.isBlock? @"true": @"false";
            else{
                client.isBlock = newValue.boolValue;
            }
            break;
        }
        case -26:{
            if(get)
                return client.iot_serviceEnable? @"true": @"false";
            else{
                client.iot_serviceEnable = newValue.boolValue;
            }
            break;
        }
        case -27:{
            if(get)
                return client.iot_dnsEnable? @"true": @"false";
            else{
                client.iot_dnsEnable = newValue.boolValue;
            }
            break;
        }


        case -25:{
            if(get)
            return client.bW_Enable? @"true": @"false";
            else{
                client.bW_Enable = newValue.boolValue;
            }
            break;
        }
        case -3:
        {
            if(get)
                return @(client.notificationMode).stringValue; //todo
            else
                client.notificationMode = [newValue intValue];
            break;
        }
        default:{
            return nil;
        }
            break;
    }
    return nil;
}


+(void)updateAllowOnNetworkAndSchedule:(Client*)client blockedString:(NSString*)blockedString{
    if([blockedString isEqualToString:@"000000,000000,000000,000000,000000,00000,00000"]){
        client.deviceAllowedType = DeviceAllowed_Always;
    }else if([blockedString isEqualToString:@"ffffff,ffffff,ffffff,ffffff,ffffff,ffffff,ffffff"]){
        client.deviceAllowedType = DeviceAllowed_Blocked;
        
    }else{
        client.deviceSchedule = blockedString;
        client.deviceAllowedType = DeviceAllowed_OnSchedule;
    }
    
}

+ (int)activeClientCount{
    int count = 0;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for (Client  *client in toolkit.clients) {
        if(client.isActive)
            count++;
    }
    return count;
}

+(int)inactiveClientCount{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    return toolkit.clients.count - [self activeClientCount];
}

+(NSString*)getAllowedOnNetworkTypeForType:(DeviceAllowedType)type{
    switch (type) {
        case DeviceAllowed_Always:
            return ALLOWED_TYPE_ALWAYS;
        case DeviceAllowed_Blocked:
            return ALLOWED_TYPE_BLOCKED;
        case DeviceAllowed_OnSchedule:
            return ALLOWED_TYPE_ONSCHEDULE;
        default:
            return UNKNOWN;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    Client *copy = [[[self class] allocWithZone:zone] init];
    if (copy != nil) {
        copy.name = self.name;
        copy.deviceIP = self.deviceIP;
        copy.manufacturer = self.manufacturer;
        copy.rssi = self.rssi;
        copy.deviceMAC = self.deviceMAC;
        copy.deviceConnection = self.deviceConnection;
        copy.deviceID = self.deviceID;
        copy.deviceType = self.deviceType;
        copy.timeout = self.timeout;
        copy.deviceLastActiveTime = self.deviceLastActiveTime;
        copy.deviceUseAsPresence = self.deviceUseAsPresence;
        copy.isActive = self.isActive;
        copy.deviceAllowedType = self.deviceAllowedType;
        copy.deviceSchedule = self.deviceSchedule;
        copy.canBeBlocked = self.canBeBlocked;
        copy.category = self.category;
        copy.webHistoryEnable = self.webHistoryEnable;
        copy.bW_Enable = self.bW_Enable;
        copy.iot_serviceEnable = self.iot_serviceEnable;
        copy.iot_dnsEnable = self.iot_dnsEnable;
    }
    return copy;
}

@end
