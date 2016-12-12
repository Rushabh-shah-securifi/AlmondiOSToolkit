


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
#import "KeyChainWrapper.h"

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
        if(![[data valueForKey:@"data"] isKindOfClass:[NSData class]]){
            NSLog(@"returning... %@",[data valueForKey:@"data"]);
            return;
        }
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
     //NSLog(@"onWiFiClientsListResAndDynamicCallbacks %@",mainDict);
    BOOL isMatchingAlmondOrLocal = ([mainDict[ALMONDMAC] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
    
//    NSLog(@"onWiFiClientsListResAndDynamicCallbacks: %@",mainDict);
    NSString * commandType = mainDict[COMMAND_TYPE];
    
    if ([commandType isEqualToString:CLIENTLIST] || [commandType isEqualToString:@"DynamicClientList"]) {
        if([mainDict[CLIENTS] isKindOfClass:[NSArray class]])
            return;
        NSDictionary *clientsPayload = mainDict[CLIENTS];
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
            [self getClientsNotificationPreferences];
    }
    
    else if([commandType isEqualToString:DYNAMIC_CLIENT_ADDED]){
        NSDictionary * dict = mainDict[CLIENTS];
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
               ([commandType isEqualToString:DYNAMIC_CLIENT_UPDATED]||
                [commandType isEqualToString:DYNAMIC_CLIENT_JOINED]||
                [commandType isEqualToString:DYNAMIC_CLIENT_LEFT])
            ){
        NSDictionary *clientPayload = mainDict[CLIENTS];
        NSString *ID = [[clientPayload allKeys] objectAtIndex:0]; // Assumes payload always has one device.
        NSDictionary *updatedClientPayload = [clientPayload objectForKey:ID];
        
        Client *client = [Client findClientByID:ID];
        if(client)
            [self setDeviceProperties:client forDict:updatedClientPayload];
        NSLog(@"dynamic client updated mainDict = %@",mainDict);
        
    }
    else if([commandType isEqualToString:DYNAMIC_CLIENT_REMOVED]) {
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
    else if([commandType isEqualToString:DYNAMIC_CLIENT_REMOVEALL]){
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

- (void)getClientsNotificationPreferences{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSString *userID = [KeyChainWrapper retrieveEntryForUser:SEC_EMAIL forService:SEC_SERVICE_NAME];
    NSMutableDictionary *commandInfo = [NSMutableDictionary new];
    
    [commandInfo setValue:@"GetClientPreferences" forKey:@"CommandType"];
    [commandInfo setValue:toolkit.currentAlmond.almondplusMAC forKey:@"AlmondMAC"];
    [commandInfo setValue:userID forKey:@"UserID"];
    
    
    GenericCommand *cloudCommand = [GenericCommand jsonStringPayloadCommand:commandInfo commandType:CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST];
    
    [toolkit asyncSendToNetwork:cloudCommand];
}

-(void)setDeviceProperties:(Client*)device forDict:(NSDictionary*)dict{
    device.name = dict[CLIENT_NAME];
    device.manufacturer = dict[MANUFACTURER];
    device.rssi = dict[RSSI];
    device.deviceMAC = dict[MAC];
    device.deviceIP = dict[LAST_KNOWN_IP];
    device.deviceConnection = dict[CONNECTION];
    device.deviceLastActiveTime = dict[LAST_ACTIVE_EPOCH];
    device.deviceType = dict[CLIENT_TYPE];
    device.deviceUseAsPresence = [dict[USE_AS_PRESENCE] boolValue];
    device.isActive = [dict[ACTIVE] boolValue];
    device.timeout = [dict[WAIT] integerValue];
    device.deviceAllowedType = [dict[BLOCK] intValue];
    device.deviceSchedule = dict[SCHEDULE]==nil? @"": dict[SCHEDULE];
    device.canBeBlocked = [dict[CAN_BLOCK] boolValue];
    device.category = dict[CATEGORY];
//    NSLog(@"dict[SM_ENABLE] = %@ device.name %@",dict[SM_ENABLE],device.name);
    device.webHistoryEnable = [dict[SM_ENABLE] boolValue];
    device.bW_Enable = [dict[BW_ENABLE] boolValue];
    device.is_IoTDeviceType = [self isIoTdevice:dict[CLIENT_TYPE]];
    device.iot_serviceEnable = YES;
}
-(BOOL)isIoTdevice:(NSString *)clientType{
    NSArray *iotTypes = @[@"withings",@"dlink_cameras",@"hikvision",@"foscam",@"motorola_connect",@"ibaby_monitor",@"osram_lightify",@"honeywell_appliances",@"ge_appliances",@"wink",@"airplay_speakers",@"sonos",@"belkin_wemo",@"samsung_smartthings",@"ring_doorbell",@"piper",@"canary",@"august_connect",@"nest_cam ",@"skybell_wifi",@"scout_home_system",@"philips_hue",@"nest_protect",@"nest_thermostat",@"amazon_dash",@"amazon_echo"];
        if([iotTypes containsObject: clientType] )
            return YES;
        else return  NO;
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
    BOOL isSuccess = [mainDict[@"Success"] boolValue];
    if (isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self configureNotificationModesForClients:mainDict[@"ClientPreferences"]];
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
        if ([dict[@"ClientID"] intValue]==[client.deviceID intValue]) {
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
    NSString *aMac = mainDict[@"AlmondMAC"];
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
