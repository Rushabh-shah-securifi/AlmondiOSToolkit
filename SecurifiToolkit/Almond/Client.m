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

+ (BOOL)getClientByMAC:(NSString *)mac{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
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

+(NSArray*) getClientGenericIndexes{
        NSArray *genericIndexesArray = [NSArray arrayWithObjects:@-11,@-12,@-13,@-14,@-15,@-16,@-17,@-18,@-21,@-23,@-22,@-19,@-20,@-3,@-25,nil];
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
        }
        case -25:{
            if(get)
            return client.bW_Enable? @"true": @"false";
            else{
                client.bW_Enable = newValue.boolValue;
            }
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
        client.deviceAllowedType = DeviceAllowed_OnSchedule;
    }
    client.deviceSchedule = blockedString;
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
    }
    return copy;
}

@end
