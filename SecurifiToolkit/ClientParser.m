


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
    
    [center addObserver:self
               selector:@selector(onWiFiClientsListResAndDynamicCallbacks:)
                   name:NOTIFICATION_WIFI_CLIENT_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onGetClientsPreferences:)
                   name:NOTIFICATION_WIFI_CLIENT_GET_PREFERENCE_REQUEST_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDynamicClientPreferenceUpdate:) //dynamic 93 - need to put in device parser/ client parser
                   name:NOTIFICATION_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE_NOTIFIER
                 object:nil];
    
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
        if(![[data valueForKey:@"data"] isKindOfClass:[NSData class]])
            return;
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
    
    BOOL isMatchingAlmondOrLocal = ([[mainDict valueForKey:ALMONDMAC] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
    
    NSLog(@"onWiFiClientsListResAndDynamicCallbacks: %@",mainDict);
    
    if ([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:CLIENTLIST] || [[mainDict valueForKey:COMMAND_TYPE] isEqualToString:@"DynamicClientList"]) {
        if([[mainDict valueForKey:CLIENTS] isKindOfClass:[NSArray class]])
            return;
        NSDictionary *clientsPayload = [mainDict valueForKey:CLIENTS];
        NSArray *clientKeys = clientsPayload.allKeys;
        NSMutableArray *wifiClientsArray = [NSMutableArray new];
        
        for (NSString *key in clientKeys) {
            Client *device = [Client new];
            [self setDeviceProperties:device forDict:clientsPayload[key]];
            device.deviceID = key;
            [wifiClientsArray addObject:device];
        }
        toolkit.clients = wifiClientsArray;
        if(!local)
            [toolkit getClientsNotificationPreferences];
    }
    
    else if([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_ADDED]){
        NSDictionary * dict = [mainDict valueForKey:CLIENTS];
        NSString *ID = [[dict allKeys] objectAtIndex:0]; // Assumes payload always has one device.
        Client *client = [Client findClientByID:ID];
        if(client){
            [self setDeviceProperties:client forDict:dict[ID]];
        }else{
            client = [Client new];
            [self setDeviceProperties:client forDict:dict[ID]];
            client.deviceID = ID;
            [toolkit.clients addObject:client];
        }
    }
    else if (
               ([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_UPDATED]||
                [[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_JOINED]||
                [[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_LEFT])
            ){
        NSDictionary *clientPayload = [mainDict valueForKey:CLIENTS];
        NSString *ID = [[clientPayload allKeys] objectAtIndex:0]; // Assumes payload always has one device.
        NSDictionary *updatedClientPayload = [clientPayload objectForKey:ID];
        
        Client *client = [Client findClientByID:ID];
        if(client)
            [self setDeviceProperties:client forDict:updatedClientPayload];
    }
    else if([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_REMOVED]) {
        NSDictionary *clientPayload = mainDict[CLIENTS];
        
        NSString *clientID = [[clientPayload allKeys] objectAtIndex:0]; // Assumes payload always has one device.
        Client *toBeRemovedClient = nil;
        for(Client *device in toolkit.clients){
            if([device.deviceID isEqualToString:clientID]){//clientPayload[@"ID"]
                toBeRemovedClient = device;
                break;
            }
        }
        NSLog(@"toolkit client list count %ld",toolkit.clients.count);
        if(toBeRemovedClient)
            [toolkit.clients removeObject:toBeRemovedClient];
         NSLog(@"toolkit client list count %ld",toolkit.clients.count);
    }
    else if([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:DYNAMIC_CLIENT_REMOVEALL]){
        [toolkit.clients removeAllObjects];
    }
    toolkit.clients = [self getSortedDevices];
    
    
    NSDictionary *resData = nil;
    if (mainDict) {
        resData = @{
                 @"data" : mainDict
                 };
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER object:nil userInfo:resData];
}

-(void)setDeviceProperties:(Client*)device forDict:(NSDictionary*)dict{
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

- (void)onGetClientsPreferences:(id)sender {
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    
    if ([[mainDict valueForKey:@"Success"] isEqualToString:@"true"]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self configureNotificationModesForClients:[mainDict valueForKey:@"ClientPreferences"]];
        });
    }
}

-(void)configureNotificationModesForClients:(NSArray*)clientsPreferences{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for(Client *client in toolkit.clients){
        [self setClientPreference:client clientsPreferences:clientsPreferences];
    }
}

-(void)setClientPreference:(Client*)client clientsPreferences:(NSArray*)clientsPreferences{
    for (NSDictionary * dict in clientsPreferences) {
        if ([[dict valueForKey:@"ClientID"] intValue]==[client.deviceID intValue]) {
            client.notificationMode =  [dict[@"NotificationType"] intValue];
            NSLog(@"clientname: %@, client notification mode: %d",client.name, client.notificationMode);
            return;
        }
    }
    client.notificationMode = SFINotificationMode_off;
}

- (void)onDynamicClientPreferenceUpdate:(id)sender {//client individual dynamic 93
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    NSLog(@"client preferecne: %@", mainDict);
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    NSString *aMac = [mainDict valueForKey:@"AlmondMAC"];
    int clientID = [mainDict[@"ClientID"] intValue];
    if(![aMac isEqualToString:plus.almondplusMAC])
        return;
    
    NSString *commandType = mainDict[@"CommandType"];
    
    if ([commandType isEqualToString:@"UpdatePreference"]) {
        Client *client = [Client findClientByID:@(clientID).stringValue];
        client.notificationMode = [mainDict[@"NotificationType"] intValue];
        NSLog(@"client: %@, noti mode: %d", client, client.notificationMode);
    }
    
    NSDictionary *resData = nil;
    if (mainDict) {
        resData = @{
                    @"data" : mainDict
                    };
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER object:nil userInfo:resData];
}


@end
