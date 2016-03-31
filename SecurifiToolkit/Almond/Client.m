//
//  Client.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "Client.h"
#import "SecurifiToolkit.h"

@implementation Client

- (NSString *)iconName {
    if ([[self.deviceType lowercaseString] isEqualToString:@"tv"]) {
        return @"icon_appleTV";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"other"]) {
        return @"icon_help";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"mac"]) {
        return @"icon_pc";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"hub"]) {
        return @"icon_hubrouter";
    }

    if ([[self.deviceType lowercaseString] isEqualToString:@"router_switch"]) {
        return @"icon_hubrouter";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"tablet"]) {
        return @"icon_iphone";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"android_stick"]) {
        return @"icon_android_stick";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"chromecast"]) {
        return @"icon_chrome_cast";
    }

    if ([[self.deviceType lowercaseString] isEqualToString:@"nest"]) {
        return @"icon_nest_google";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"printer"]) {
        return @"icon_printer";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"pc"]) {
        return @"icon_pc";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"laptop"]) {
        return @"icon_laptop";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"smartphone"]) {
        return @"icon_smartphone";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"iphone"]) {
        return @"icon_iphone";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"ipad"]) {
        return @"icon_iPad";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"ipod"]) {
        return @"icon_iPod";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"appletv"]) {
        return @"icon_appleTV";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"camera"]) {
        return @"icon_camera";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"amazon_echo"]) {
        return @"amazon-echo";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"amazon_dash"]) {
        return @"amazon-dash";
    }
    return @"icon_help";
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

+(NSArray*) getClientGenericIndexes{
    NSArray *genericIndexesArray = [NSArray arrayWithObjects:@(-11),@(-12),@-13,@-14,@-15,@-16,@-17,@-18,@-19,@-20,@-3, nil];
    return genericIndexesArray;
}

+(NSString*)getOrSetValueForClient:(Client*)client genericIndex:(int)genericIndex newValue:(NSString*)newValue ifGet:(BOOL)get{
    switch (genericIndex) {
        case -11:
        {
            if(get)
                return client.name;
            else
                client.name = newValue;
            break;
        }
        case -12:
        {
            if(get)
                return client.deviceType;
            else
                client.deviceType = newValue;
            break;
        }
        case -13:
        {
            if(get)
                return client.manufacturer;
            else
                client.manufacturer = newValue;
            break;
        }
        case -14:
        {
            if(get)
                return client.deviceMAC;
            else
                client.deviceMAC = newValue;
            break;
        }
        case -15:
        {
            if(get)
                return client.deviceLastActiveTime;
            else
                client.deviceLastActiveTime = newValue;
            break;
        }
        case -16:
        {
            if(get)
                return client.deviceConnection;
            else
                client.deviceConnection = newValue;
            break;
        }
        case -17:
        {
            if(get)
                return client.deviceUseAsPresence? @"true" : @"false";
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
            else
                client.deviceAllowedType = newValue.integerValue;
            break;
        }
        case -20:
        {
            if(get)
                return client.rssi;
            else
                client.rssi = newValue;
            break;
        }
        case -3:
        {
            if(get)
                return @"always"; //todo
            //        else
            //            client.deviceType = newValue;
            break;
        }
        default:{
            return nil;
        }
            break;
    }
    return nil;
}
@end
