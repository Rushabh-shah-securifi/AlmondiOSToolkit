


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
#import "AlmondJsonCommandKeyConstants.h"

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
    
    if ([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:CLIENTLIST] && ([[mainDict valueForKey:ALMONDMAC] isEqualToString:almond.almondplusMAC] || local)) {
        [toolkit.clients removeAllObjects];
        
        NSDictionary *clientsPayload = [mainDict valueForKey:CLIENTS];
        NSArray *clientKeys = clientsPayload.allKeys;
        NSMutableArray *wifiClientsArray = [NSMutableArray new];
        
        for (NSString *key in clientKeys) {
            Client *device = [Client new];
            [self setDeviceProperties:device forDict:clientsPayload[key]];
            [wifiClientsArray addObject:device];
        }
        toolkit.clients = wifiClientsArray;
        NSLog(@"toolkit.clients: %@", toolkit.clients);
    }
    
    else if([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_ADDED] && ([[mainDict valueForKey:ALMONDMAC] isEqualToString:almond.almondplusMAC] || local)){
        NSDictionary * dict = [mainDict valueForKey:CLIENTS];
        Client * device = [Client new];
        [self setDeviceProperties:device forDict:dict];
        [toolkit.clients addObject:device];
    }
    else if (
               ([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_UPDATED]||
                [[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_JOINED]||
                [[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_LEFT])&&
               ([[mainDict valueForKey:ALMONDMAC] isEqualToString:almond.almondplusMAC] || local)
               ) {
        NSDictionary *clientPayload = [mainDict valueForKey:CLIENTS];
        
        
        NSString *ID = [[clientPayload allKeys] objectAtIndex:0]; // Assumes payload always has one device.
        NSDictionary *updatedClientPayload = [clientPayload objectForKey:ID];
            
        for (Client *device in toolkit.clients) {
            if ([device.deviceID isEqualToString:[updatedClientPayload valueForKey:C_ID]]) {
                [self setDeviceProperties:device forDict:updatedClientPayload];
                 NSLog(@"client updated: %@", device.category);
                break;
            }
        }
    }
    else if([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_REMOVED] && ([[mainDict valueForKey:ALMONDMAC] isEqualToString:almond.almondplusMAC] || local)) {
        NSDictionary * removedClientDict = [mainDict valueForKey:CLIENTS];
        Client *toBeRemovedClient;
        for (Client * device in toolkit.clients) {
            if ([device.deviceID isEqualToString:[removedClientDict valueForKey:C_ID]]) {
                toBeRemovedClient = device;
                break;
            }
        }
        [toolkit.clients removeObject:toBeRemovedClient];
    }
    toolkit.clients = [self getSortedDevices];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER object:nil userInfo:nil];
}

-(void)setDeviceProperties:(Client*)device forDict:(NSDictionary*)dict{
    device.deviceID = [dict valueForKey:C_ID];
    device.name = [dict valueForKey:CLIENT_NAME];
    device.manufacturer = [dict valueForKey:MANUFACTURER];
    device.rssi = [dict valueForKey:RSSI];
    device.deviceMAC = [dict valueForKey:MAC];
    device.deviceIP = [dict valueForKey:LAST_KNOWN_IP];
    device.deviceConnection = [dict valueForKey:CONNECTION];
    device.deviceLastActiveTime = [dict valueForKey:LAST_ACTIVE_EPOCH];
    device.deviceType = [dict valueForKey:CLIENT_TYPE];
    device.deviceUseAsPresence = [[dict valueForKey:USE_AS_PRESENCE] boolValue];
    device.isActive = [[dict valueForKey:ACTIVE] boolValue];
    device.timeout = [[dict valueForKey:WAIT] integerValue];
    device.deviceAllowedType = [[dict valueForKey:BLOCK] intValue];
    device.deviceSchedule = [dict valueForKey:SCHEDULE]==nil? @"": [dict valueForKey:SCHEDULE];
    device.canBeBlocked = [[dict valueForKey:CAN_BLOCK] boolValue];
    device.category = [dict valueForKey:CATEGORY];
}

-(NSMutableArray*)getSortedDevices{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isActive" ascending:NO];
    NSSortDescriptor *secondDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, secondDescriptor, nil];
    return [[toolkit.clients sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

@end
