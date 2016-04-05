


//
//  Parser.m
//  SecurifiToolkit
//
//  Created by Masood on 17/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "ClientParser.h"
#import "MDJSON.h"
#import "Client.h"
#import "SecurifiToolkit.h"

@implementation ClientParser
- (instancetype)init {
    self = [super init];
    [self initNotification];
    return self;
}

-(void)initNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onWiFiClientsListResAndDynamicCallbacks:) name:NOTIFICATION_WIFI_CLIENT_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER object:nil];
}

-(void)onWiFiClientsListResAndDynamicCallbacks:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil || [data valueForKey:@"data"]==nil ) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *mainDict;
    if(local){
        mainDict = [data valueForKey:@"data"];
    }else{
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"onWiFiClientsListResAndDynamicCallbacks: %@",mainDict);
    
    if ([[mainDict valueForKey:@"CommandType"] isEqualToString:@"ClientList"] && ([[mainDict valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local)) {
        NSArray *dDictArray = [mainDict valueForKey:@"Clients"];
        NSMutableArray *wifiClientsArray = [NSMutableArray new];
        for (NSDictionary *dict in dDictArray) {
            Client *device = [Client new];
            [self setDeviceProperties:device forDict:dict];
            [wifiClientsArray addObject:device];
        }
        toolkit.clients = wifiClientsArray;
    }
    
    else if([[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientAdded"] && ([[mainDict valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local)){
        NSDictionary * dict = [mainDict valueForKey:@"Clients"];
        Client * device = [Client new];
        [self setDeviceProperties:device forDict:dict];
        [toolkit.clients addObject:device];
    }
    else if (
               ([[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientUpdated"]||
                [[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientJoined"]||
                [[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientLeft"])&&
               ([[mainDict valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local)
               ) {
        NSDictionary *dict = [mainDict valueForKey:@"Clients"];
        for (Client * device in toolkit.clients) {
            if ([device.deviceID isEqualToString:[dict valueForKey:@"ID"]]) {
                [self setDeviceProperties:device forDict:dict];
                break;
            }
        }
    }
    else if([[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientRemoved"] && ([[mainDict valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local)) {
        NSDictionary * removedClientDict = [mainDict valueForKey:@"Clients"];
        Client *toBeRemovedClient;
        for (Client * device in toolkit.clients) {
            if ([device.deviceID isEqualToString:[removedClientDict valueForKey:@"ID"]]) {
                toBeRemovedClient = device;
                break;
            }
        }
        [toolkit.clients removeObject:toBeRemovedClient];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DYNAMIC_CLIENTLIST_ADD_UPDATE_REMOVE_NOTIFIER object:nil userInfo:nil];
}

-(void)setDeviceProperties:(Client*)device forDict:(NSDictionary*)dict{
    device.deviceID = [dict valueForKey:@"ID"];
    device.name = [dict valueForKey:@"Name"];
    device.manufacturer = [dict valueForKey:@"Manufacturer"];
    device.rssi = [dict valueForKey:@"RSSI"];
    device.deviceMAC = [dict valueForKey:@"MAC"];
    device.deviceIP = [dict valueForKey:@"LastKnownIP"];
    device.deviceConnection = [dict valueForKey:@"Connection"];
    device.deviceLastActiveTime = [dict valueForKey:@"LastActiveEpoch"];
    device.deviceType = [dict valueForKey:@"Type"];
    device.deviceUseAsPresence = [[dict valueForKey:@"UseAsPresence"] boolValue];
    device.isActive = [[dict valueForKey:@"Active"] boolValue];
    device.timeout = [[dict valueForKey:@"Wait"] integerValue];
    device.deviceAllowedType = [[dict valueForKey:@"Block"] intValue];
    device.deviceSchedule = [dict valueForKey:@"Schedule"]==nil?@"":[dict valueForKey:@"Schedule"];
}


@end
