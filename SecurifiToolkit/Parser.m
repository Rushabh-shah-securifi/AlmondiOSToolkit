
//
//  Parser.m
//  SecurifiToolkit
//
//  Created by Masood on 17/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "Parser.h"
#import "MDJSON.h"
#import "SFIConnectedDevice.h"
#import "SecurifiToolkit.h"



@implementation Parser
- (instancetype)init {
    self = [super init];
    [self initNotification];
        return self;
}
-(void)initNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onWiFiClientsListResCallback:) name:NOTIFICATION_WIFI_CLIENTS_LIST_RESPONSE object:nil];

    [center addObserver:self
               selector:@selector(onDynamicClientAdded:)
                   name:NOTIFICATION_DYNAMIC_CLIENT_ADD_REQUEST_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onDynamicClientUpdate:)
                   name:NOTIFICATION_DYNAMIC_CLIENT_UPDATE_REQUEST_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDynamicClientUpdate:)
                   name:NOTIFICATION_DYNAMIC_CLIENT_JOIN_REQUEST_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onDynamicClientUpdate:)
                   name:NOTIFICATION_DYNAMIC_CLIENT_LEFT_REQUEST_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDynamicClientRemove:)
                   name:NOTIFICATION_DYNAMIC_CLIENT_REMOVE_REQUEST_NOTIFIER
                 object:nil];
}

-(void)onWiFiClientsListResCallback:(id)sender {
    NSLog(@"onWiFiClientsListResCallback ");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
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
    }// required for switching local<=>cloud
    NSLog(@" mainDict %@",mainDict);
    
   // NSDictionary *mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    NSMutableArray *wifiClientsArray = [[NSMutableArray alloc]init];
    
    if ([[mainDict valueForKey:@"Clients"] isKindOfClass:[NSArray class]]) {
        NSArray *dDictArray = [mainDict valueForKey:@"Clients"];
        wifiClientsArray = [NSMutableArray new];
        for (NSDictionary *dict in dDictArray) {
            SFIConnectedDevice *device = [SFIConnectedDevice new];
            device.deviceID = [dict valueForKey:@"ID"];
            device.name = [dict valueForKey:@"Name"];
            device.deviceMAC = [dict valueForKey:@"MAC"];
            device.deviceIP = [dict valueForKey:@"LastKnownIP"];
            device.deviceConnection = [dict valueForKey:@"Connection"];
            device.name = [dict valueForKey:@"Name"];
            device.deviceLastActiveTime = [dict valueForKey:@"LastActiveEpoch"];
            device.deviceType = [dict valueForKey:@"Type"];
            device.deviceUseAsPresence = [[dict valueForKey:@"UseAsPresence"] boolValue];
            device.isActive = [[dict valueForKey:@"Active"] boolValue];
            device.timeout = [[dict valueForKey:@"Wait"] integerValue];
            if (device.isActive) {
//                activeClientsCount++;
            }else{
//                inActiveClientsCount++;
            }
            [wifiClientsArray addObject:device];
        }
        
    }
    toolkit.wifiClientParser = wifiClientsArray;
    return;
}

- (void)onDynamicClientAdded:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    NSLog(@" ondynamicClientAdded");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    BOOL local = [toolkit useLocalNetwork:plus.almondplusMAC];
    NSDictionary *mainDict;
    if(local){
        mainDict = [data valueForKey:@"data"];
    }else{
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
    
    if ([[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientAdded"] && ([[mainDict valueForKey:@"AlmondMAC"] isEqualToString:plus.almondplusMAC] || local)) {
        NSDictionary * dict = [mainDict valueForKey:@"Clients"];
        SFIConnectedDevice * device = [SFIConnectedDevice new];
        device.deviceID = [dict valueForKey:@"ID"];
        device.name = [dict valueForKey:@"Name"];
        device.deviceMAC = [dict valueForKey:@"MAC"];
        device.deviceIP = [dict valueForKey:@"LastKnownIP"];
        device.deviceConnection = [dict valueForKey:@"Connection"];
        device.name = [dict valueForKey:@"Name"];
        device.deviceLastActiveTime = [dict valueForKey:@"LastActiveEpoch"];
        device.deviceType = [dict valueForKey:@"Type"];
        device.deviceUseAsPresence = [[dict valueForKey:@"UseAsPresence"] boolValue];
        device.isActive = [[dict valueForKey:@"Active"] boolValue];
        device.timeout = [[dict valueForKey:@"Wait"] integerValue];
        
        [toolkit.wifiClientParser addObject:device];
        //post notification
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_WIFICLIENT_TABLEVIEW object:nil userInfo:nil];//as we are not doing any thing with data
}
- (void)onDynamicClientUpdate:(id)sender {
    NSLog(@"onDynamicClientUpdate");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    BOOL local = [toolkit useLocalNetwork:plus.almondplusMAC];
    NSDictionary *mainDict;
    if(local){
        mainDict = [data valueForKey:@"data"];
    }else{
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"data: %@", data);
    if (
        ([[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientUpdated"]
         || [[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientJoined"]
         || [[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientLeft"])
        && ([[mainDict valueForKey:@"AlmondMAC"] isEqualToString:plus.almondplusMAC] || local)
        ) {
        NSLog(@"main dict: %@", mainDict);
        NSDictionary *dict = [mainDict valueForKey:@"Clients"];
        int index = 0;
        for (SFIConnectedDevice * device in toolkit.wifiClientParser) {
            if ([device.deviceID isEqualToString:[dict valueForKey:@"ID"]]) {
                device.deviceID = [dict valueForKey:@"ID"];
                device.name = [dict valueForKey:@"Name"];
                device.deviceMAC = [dict valueForKey:@"MAC"];
                device.deviceIP = [dict valueForKey:@"LastKnownIP"];
                device.deviceConnection = [dict valueForKey:@"Connection"];
                device.name = [dict valueForKey:@"Name"];
                device.deviceLastActiveTime = [dict valueForKey:@"LastActiveEpoch"];
                device.deviceType = [dict valueForKey:@"Type"];
                device.deviceUseAsPresence = [[dict valueForKey:@"UseAsPresence"] boolValue];
                device.isActive = [[dict valueForKey:@"Active"] boolValue];
                device.timeout = [[dict valueForKey:@"Wait"] integerValue];
               
                break;
            }
            index++;
            
        }
        //post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_WIFICLIENT_TABLEVIEW object:nil userInfo:nil];//as we are not doing any thing with data
    }

}

- (void)onDynamicClientRemove:(id)sender {
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    BOOL local = [toolkit useLocalNetwork:plus.almondplusMAC];
    NSDictionary *mainDict;
    if(local){
        mainDict = [data valueForKey:@"data"];
    }else{
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
    
    NSLog(@"maindict :%@",mainDict);
    if ([[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicClientRemoved"] && ([[mainDict valueForKey:@"AlmondMAC"] isEqualToString:plus.almondplusMAC] || local)) {
        NSDictionary * removedClientDict = [mainDict valueForKey:@"Clients"];
        int index = 0;
        for (SFIConnectedDevice * device in toolkit.wifiClientParser) {
            if ([device.deviceID isEqualToString:[removedClientDict valueForKey:@"ID"]]) {
                                [toolkit.wifiClientParser removeObject:device];
                
                break;
            }
            index++;
        }
    }
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_WIFICLIENT_TABLEVIEW object:nil userInfo:nil];//as we are not doing any thing with data
}

@end
