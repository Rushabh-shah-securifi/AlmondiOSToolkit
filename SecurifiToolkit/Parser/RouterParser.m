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
#import "AlmondManagement.h"
#import "NSData+Securifi.h"

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
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
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
        genericRouterCommand = [self createGenericRouterCommand:[self parseRouterSummary:payload]
                                                    commandType:SFIGenericRouterCommandType_WIRELESS_SUMMARY
                                                        payload:payload];
        
    }else if([commandType isEqualToString:@"GetWirelessSettings"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseWirelessSettings:payload[@"WirelessSetting"]
                                                                                 regionCode:payload[@"CountryRegion"]]
                                                    commandType:SFIGenericRouterCommandType_WIRELESS_SETTINGS payload:payload];
        
        if(payload[@"Password"]){
            [self addPasswordToSettings:genericRouterCommand.command payload:payload];
        }
    }
    else if([commandType isEqualToString:@"SetWirelessSettings"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseWirelessSettings:payload[@"WirelessSetting"] regionCode:@"CountryRegion"]
                                                    commandType:SFIGenericRouterCommandType_WIRELESS_SETTINGS payload:payload];
        
        if(payload[@"Uptime"]){
            [self addPasswordSetWireless:genericRouterCommand.command payload:payload];
        }
    }

    else if([commandType isEqualToString:@"FirmwareUpdate"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseWirelessSettings:payload[@"WirelessSetting"] regionCode:@"CountryRegion"]
                                                    commandType:SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE payload:payload];
    }
    else if([commandType isEqualToString:@"RebootRouter"]){
        genericRouterCommand = [self createGenericRouterCommand:nil commandType:SFIGenericRouterCommandType_REBOOT payload:payload];
    }
    else if([commandType isEqualToString:@"SendLogs"]){
        genericRouterCommand = [self createGenericRouterCommand:nil commandType:SFIGenericRouterCommandType_SEND_LOGS_RESPONSE payload:payload];
    }
    
    //I saw this response was comming in false case, had to handle it.
    else if([commandType isEqualToString:@"ChangeAlmondProperties"]){
        genericRouterCommand = [self createGenericRouterCommand:nil commandType:SFIGenericRouterCommandType_ALMOND_PROPERTY payload:payload];
    }
    /*
     {"CommandType":"ChangeAlmondProperties","Success":"false","OfflineSlaves":"Downstairs","Reason":"Slave in offline","MobileInternalIndex":"2909"}
     */
    NSDictionary *data = nil;
    if (payload) {
        data = @{
                 @"data" : genericRouterCommand
                 };
    }
    NSLog(@"posting router summery");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil userInfo:data];
}

//2g, guest2g, 5g, guest5g for getwireless
+(void)addPasswordToSettings:(NSArray *)settings payload:(NSDictionary *)payload{
    NSString *pLen = payload[@"PLen"]; //"8,0,8,0"
    NSString *decryptedPass = [self getDecryptedPass:payload[@"Password"] uptime:payload[@"Uptime"]];
    
    NSArray *pLenSplits = [pLen componentsSeparatedByString:@","];
    if(pLenSplits.count <= 3)//crash fix
        return;
    
    NSRange range = NSMakeRange(0, [pLenSplits[0] integerValue]);
    NSString *pass2G = [decryptedPass substringWithRange:range];
    
    range = NSMakeRange(pass2G.length, [pLenSplits[1] integerValue]);
    NSString *pass2GGuest = [decryptedPass substringWithRange:range];
    
    range = NSMakeRange(pass2G.length + pass2GGuest.length, [pLenSplits[2] integerValue]);
    NSString *pass5G = [decryptedPass substringWithRange:range];
    
    range = NSMakeRange(pass2G.length + pass2GGuest.length + pass5G.length, [pLenSplits[3] integerValue]);
    NSString *pass5GGuest = [decryptedPass substringWithRange:range];
    
    
    for(SFIWirelessSetting *setting in settings){
        if([setting.type isEqualToString:@"2G"]){
            setting.password = pass2G;
        }
        else if([setting.type isEqualToString:@"Guest2G"]){
            setting.password = pass2GGuest;
        }
        else if([setting.type isEqualToString:@"5G"]){
            setting.password = pass5G;
        }
        else if([setting.type isEqualToString:@"Guest5G"]){
            setting.password = pass5GGuest;
        }
        
        if([self isUnSecure:setting.security]){
            setting.password = nil;
        }
    }
}

+(BOOL)isUnSecure:(NSString *)security{
    return [security isEqualToString:@"Unsecure"];
}

+ (void)addPasswordSetWireless:(NSArray *)settings payload:(NSDictionary *)payload{
    SFIWirelessSetting *newSettingObj = settings.firstObject;
    newSettingObj.password = [self getDecryptedPass:newSettingObj.password uptime:payload[@"Uptime"]];
}

+ (NSString *)getDecryptedPass:(NSString *)encryptedPass uptime:(NSString *)uptime{
    if(encryptedPass.length == 0)
        return @"";
    NSData *payload = [[NSData alloc] initWithBase64EncodedString:encryptedPass options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [payload securifiDecryptPasswordForAlmond:[AlmondManagement currentAlmond].almondplusMAC almondUptime:uptime];
}

+(SFIGenericRouterCommand*)createGenericRouterCommand:(id)command commandType:(SFIGenericRouterCommandType)type payload:(NSDictionary *)payload{
    SFIGenericRouterCommand *genericRouterCommand = [SFIGenericRouterCommand new];
    genericRouterCommand.command = command;
    genericRouterCommand.commandType = type;
    genericRouterCommand.commandSuccess = payload[@"Success"]? [payload[@"Success"] boolValue]:YES;
    genericRouterCommand.mii = [payload[@"MobileInternalIndex"] intValue];
    genericRouterCommand.responseMessage = payload[@"Reason"];
    
    genericRouterCommand.almondMAC = payload[@"AlmondMAC"];
    genericRouterCommand.completionPercentage = payload[@"Percentage"]? [payload[@"Percentage"] intValue]: 0;
    genericRouterCommand.uptime = payload[@"Uptime"]?: 0;
    genericRouterCommand.offlineSlaves = payload[@"OfflineSlaves"]?:@"";
    
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
    routerSummary.location = payload[@"AlmondLocation"];
    routerSummary.wirelessSummaries = [self parseWirelessSettingsSummary:payload[@"WirelessSetting"]];
    routerSummary.almondsList = [self getAlmondsList:payload];
    routerSummary.maxHopCount = [self getMaxHopCount:payload[SLAVES]];
    if(payload[@"RouterMode"]!=NULL){
        routerSummary.routerMode = payload[@"RouterMode"];
        [SecurifiToolkit sharedInstance].routerMode = payload[@"RouterMode"];
        NSLog(@"router mode = %@",[SecurifiToolkit sharedInstance].routerMode);
    }
    return routerSummary;
}

+ (NSInteger *)getMaxHopCount:(NSArray *)slaves{
    NSInteger maxCount = 0;
    for(NSDictionary *slave in slaves){
        if([slave[HOP_COUNT] integerValue] > maxCount)
            maxCount = [slave[HOP_COUNT] integerValue];
    }
    return maxCount;
}

+(NSArray*)getAlmondsList:(NSDictionary*)payload{
    NSMutableArray *almondsList = [payload[SLAVES] mutableCopy];
    
    //added name to be compatible with old firmware
    NSString *almLocationOrName = payload[@"AlmondLocation"]? : [AlmondManagement currentAlmond].almondplusName;
    NSDictionary *masterAlmond = @{@"Location": almLocationOrName?:@""};
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

+(NSArray*)parseWirelessSettings:(NSArray*)wirelessSettingPayloadArray regionCode:(NSString *)regionCode{
    NSMutableArray *wirelessSettingsArray = [NSMutableArray new];
    for(NSDictionary *payload in wirelessSettingPayloadArray){
        SFIWirelessSetting *wirelessSettings = [[SFIWirelessSetting alloc]init];
        wirelessSettings.type = payload[@"Type"];
        wirelessSettings.enabled = [payload[@"Enabled"] boolValue];
        wirelessSettings.ssid = payload[@"SSID"];
        wirelessSettings.password = payload[@"Password"];
        wirelessSettings.channel = [payload[@"Channel"] intValue];
        wirelessSettings.security = payload[@"Security"];
        wirelessSettings.encryptionType = payload[@"EncryptionType"];
        wirelessSettings.wirelessMode = payload[@"WirelessMode"];
        wirelessSettings.countryRegion = regionCode?:@"";
        [wirelessSettingsArray addObject:wirelessSettings];
    }
    
    return wirelessSettingsArray;
}


@end
