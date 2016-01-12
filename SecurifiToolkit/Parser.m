
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



@end
