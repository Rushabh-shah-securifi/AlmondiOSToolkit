//
//  RouterParser.m
//  SecurifiToolkit
//
//  Created by Masood on 26/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "RouterParser.h"
#import "SecurifiToolkit.h"
#import "AlmondJsonCommandKeyConstants.h"

@implementation RouterParser

- (instancetype)init {
    self = [super init];
    if(self){
        [self initNotification];
    }
    return self;
}

-(void)initNotification{
    NSLog(@"init device notification");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:[self class] selector:@selector(parseRouterCommandResponse:) name:NOTIFICATION_ROUTER_RESPONSE_NOTIFIER object:nil];
}



+(void)parseRouterCommandResponse:(NSNotification *)sender{
    NSNotification *notifier = sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        if(![[dataInfo valueForKey:@"data"] isKindOfClass:[NSData class]])
            return;
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    
    }
    NSLog(@"router payload: %@", payload);

    //disabled check for almond mac as it has no almond mac key, anyways we need no check, the response is based on request and not dynamic.
//    BOOL isMatchingAlmondOrLocal = ([[payload valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
//    if(!isMatchingAlmondOrLocal) //for cloud
//        return;
    
    SFIGenericRouterCommand *genericRouterCommand;
    NSString *commandType = payload[@"CommandType"];
    if([commandType isEqualToString:@"RouterSummary"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseRouterSummary:payload] commandType:SFIGenericRouterCommandType_WIRELESS_SUMMARY success:[payload[@"Success"] boolValue] Mac:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:0 reason:payload[@"Reason"]];
        
    }else if([commandType isEqualToString:@"GetWirelessSettings"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseWirelessSettings:payload[@"WirelessSetting"]] commandType:SFIGenericRouterCommandType_WIRELESS_SETTINGS success:[payload[@"Success"] boolValue] Mac:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:0 reason:payload[@"Reason"]];
    }
    else if([commandType isEqualToString:@"SetWirelessSettings"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseWirelessSettings:payload[@"WirelessSetting"]] commandType:SFIGenericRouterCommandType_WIRELESS_SETTINGS success:[payload[@"Success"] boolValue] Mac:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:0 reason:payload[@"Reason"]];
    }

    else if([commandType isEqualToString:@"FirmwareUpdate"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseWirelessSettings:payload[@"WirelessSetting"]] commandType:SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE success:(payload[@"Success"] == nil)? true: [payload[@"Success"] boolValue] Mac:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:[payload[@"Percentage"] intValue] reason:payload[@"Reason"]];
    }
    else if([commandType isEqualToString:@"RebootRouter"]){
        genericRouterCommand = [self createGenericRouterCommand:nil commandType:SFIGenericRouterCommandType_REBOOT success:[payload[@"Success"] boolValue] Mac:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue ] completionPercentage:0 reason:payload[@"Reason"]];
    }
    else if([commandType isEqualToString:@"SendLogs"]){
        genericRouterCommand = [self createGenericRouterCommand:nil commandType:SFIGenericRouterCommandType_SEND_LOGS_RESPONSE success:[payload[@"Success"] boolValue] Mac:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:0 reason:payload[@"Reason"]];
    }
    
    NSDictionary *data = nil;
    if (payload) {
        data = @{
                 @"data" : genericRouterCommand
                 };
    }
    NSLog(@"posting router summery");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil userInfo:data];
}

+(SFIGenericRouterCommand*)createGenericRouterCommand:(id)command commandType:(SFIGenericRouterCommandType)type success:(BOOL)success Mac:(NSString*)Mac mii:(int)mii completionPercentage:(unsigned int)completionPercentage reason:(NSString*)reason{
    SFIGenericRouterCommand *genericRouterCommand = [SFIGenericRouterCommand new];
    genericRouterCommand.command = command;
    genericRouterCommand.commandType = type;
    genericRouterCommand.commandSuccess = success;
    genericRouterCommand.almondMAC = Mac;
    genericRouterCommand.mii = mii;
    genericRouterCommand.completionPercentage = completionPercentage;
    genericRouterCommand.responseMessage = reason;
    NSLog(@"generic command response msg: %@", genericRouterCommand.responseMessage);
    return  genericRouterCommand;
}


+(SFIRouterSummary*)parseRouterSummary:(NSDictionary*)payload{
    SFIRouterSummary *routerSummary = [[SFIRouterSummary alloc]init];
    routerSummary.uptime = payload[@"Uptime"];
    routerSummary.url = payload[@"URL"]? payload[@"URL"]: payload[@"Url"]; //temp fix, till changes are done in firmware.
    routerSummary.login = payload[@"Login"];
    routerSummary.password = payload[@"TempPass"];
    routerSummary.routerUptime = payload[@"RouterUptime"];
    routerSummary.firmwareVersion = payload[@"FirmwareVersion"];
    routerSummary.wirelessSummaries = [self parseWirelessSettingsSummary:payload[@"WirelessSetting"]];
    routerSummary.almondsList = [self getAlmondsList:payload];
    if(payload[@"RouterMode"]!=NULL){
    routerSummary.routerMode = payload[@"RouterMode"];
    [SecurifiToolkit sharedInstance].routerMode = payload[@"RouterMode"];
    NSLog(@"router mode = %@",[SecurifiToolkit sharedInstance].routerMode);
        
    }
    return routerSummary;
}

+(NSArray*)getAlmondsList:(NSDictionary*)payload{
    NSMutableArray *almondsList = [payload[SLAVES] mutableCopy];
    NSDictionary *masterAlmond = @{@"Name":[SecurifiToolkit sharedInstance].currentAlmond.almondplusName};
    [almondsList insertObject:masterAlmond atIndex:0];
    return almondsList;
}


+(NSArray*)parseWirelessSettingsSummary:(NSArray*)wirelessSettingsPayloadArray{
    NSMutableArray *wirelessSettingsObjsArray = [NSMutableArray new];
    for(NSDictionary *setting in wirelessSettingsPayloadArray){;
        SFIWirelessSummary *wirelessSummary = [[SFIWirelessSummary alloc]init];
        wirelessSummary.type = setting[@"Type"];
        wirelessSummary.enabled = [setting[@"Enabled"] boolValue];
        wirelessSummary.ssid = setting[@"SSID"];
        [wirelessSettingsObjsArray addObject:wirelessSummary];
    }
    return wirelessSettingsObjsArray;
}

+(NSArray*)parseWirelessSettings:(NSArray*)wirelessSettingPayloadArray{
    NSMutableArray *wirelessSettingsArray = [NSMutableArray new];
    for(NSDictionary *payload in wirelessSettingPayloadArray){
        SFIWirelessSetting *wirelessSettings = [[SFIWirelessSetting alloc]init];
        wirelessSettings.type = payload[@"Type"];
        wirelessSettings.enabled = [payload[@"Enabled"] boolValue];
        wirelessSettings.ssid = payload[@"SSID"];
        wirelessSettings.channel = [payload[@"Channel"] intValue];
        wirelessSettings.security = payload[@"Security"];
        wirelessSettings.encryptionType = payload[@"EncryptionType"];
        wirelessSettings.wirelessMode = payload[@"WirelessMode"];
        wirelessSettings.countryRegion = payload[@"CountryRegion"];
        [wirelessSettingsArray addObject:wirelessSettings];
    }
    
    return wirelessSettingsArray;
}


@end
