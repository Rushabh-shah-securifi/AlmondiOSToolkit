//
//  RouterParser.m
//  SecurifiToolkit
//
//  Created by Masood on 26/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "RouterParser.h"
#import "SecurifiToolkit.h"

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

+(void)testRouterParser{
    [self sendrouterSummary];
    [self getWirelessSetting];
    [self setWirelessSetting];
}
+(NSString *)getAlmondMac{
    return [SecurifiToolkit sharedInstance].currentAlmond.almondplusMAC;
}
+(void)sendrouterSummary{
    NSDictionary *routerSumary = @{
                                   @"CommandType":@"RouterSummary",
                                   @"MobileInternalIndex":@"123456",
                                   @"AlmondMAC":[self getAlmondMac],
                                   @"AppID":@"123",
                                   @"Success":@"true",
                                   @"WirelessSetting":@[
                                           @{
                                               @"Type":@"2G",
                                               @"Enabled":@"true",
                                               @"SSID":@"Main2.4GHz"
                                               },
                                           @{
                                               @"Type":@"Guest2G",
                                               @"Enabled":@"false",
                                               @"SSID":@"Guest2.4GHz"
                                               }
                                           ],
                                   @"Uptime":@"12633321",
                                   @"URL":@"10.1.1.254",
                                   @"Login":@"admin",
                                   @"TempPass":@"xyz",
                                   @"RouterUptime":@"5 days, 6:15hrs",
                                   @"FirmwareVersion":@"AL2-R091"
                                   
                                   };
    [self parseRouterCommandResponse:[self getcommand:routerSumary]];
}

+(void)getWirelessSetting{
    NSDictionary *getWirelessSettings = @{
                                          @"CommandType":@"GetWirelessSettings",
                                          @"AlmondMAC":[self getAlmondMac],
                                          @"AppID":@"123",
                                          @"Success":@"true",
                                          @"MobileInternalIndex":@"123",

                                          @"WirelessSetting":@[
                                                  @{
                                                      @"Type":@"2G",
                                                      @"Enabled":@"true",
                                                      @"SSID":@"AlmondNetwork",
                                                      @"Channel":@"1",
                                                      @"EncryptionType":@"AES",
                                                      @"Security":@"WPA2PSK",
                                                      @"WirelessMode":@"802.11bgn",
                                                      @"CountryRegion":@"0"
                                                      },
                                                  @{
                                                      @"Type":@"Guest2G",
                                                      @"Enabled":@"true",
                                                      @"SSID":@"Guest",
                                                      @"Channel":@"1",
                                                      @"EncryptionType":@"AES",
                                                      @"Security":@"WPA2PSK",
                                                      @"WirelessMode":@"802.11bgn",
                                                      @"CountryRegion":@"0"
                                                      }
                                                  ]
                                          
                                          
                                          };
    [self parseRouterCommandResponse:[self getcommand:getWirelessSettings]];
}

+(void)setWirelessSetting{
    NSDictionary *setWirelessSettings = @{
                                          @"CommandType":@"SetWirelessSettings",
                                          @"AlmondMAC":[self getAlmondMac],
                                          @"AppID":@"123",
                                          @"Success":@"true",
                                          @"MobileInternalIndex":@"123",

                                          @"WirelessSetting":@[
                                                  @{
                                                      @"Type":@"2G",
                                                      @"Enabled":@"true",
                                                      @"SSID":@"AlmondNetwork",
                                                      @"Channel":@"1",
                                                      @"EncryptionType":@"AES",
                                                      @"Security":@"WPA2PSK",
                                                      @"WirelessMode":@"802.11bgn",
                                                      @"CountryRegion":@"0"
                                                      },
                                                  @{
                                                      @"Type":@"Guest2G",
                                                      @"Enabled":@"true",
                                                      @"SSID":@"Guest",
                                                      @"Channel":@"1",
                                                      @"EncryptionType":@"AES",
                                                      @"Security":@"WPA2PSK",
                                                      @"WirelessMode":@"802.11bgn",
                                                      @"CountryRegion":@"0"
                                                      }
                                                  ]
                                          
                                          };
    [self parseRouterCommandResponse:[self getcommand:setWirelessSettings]];
}

+(void)updateFirmwareResponse{
    //{"CommandType":"FirmwareUpdate","AppID":"1001","Success":"false","ReasonCode":"1"}
    //{"CommandType":"FirmwareUpdate","AppID":"1001","Percentage":"10"}
    NSLog(@"updateFirmwareResponse");
    NSDictionary *firmwareRes1 = @{
                                
                                @"CommandType": @"FirmwareUpdate",
                                @"Success":@"true",
                                @"AppID":@"123",
                                @"ReasonCode":@"1",
                                @"AlmondMAC": [self getAlmondMac]
                                };
    NSDictionary *firmwareRes2 = @{
                                   
                                   @"CommandType": @"FirmwareUpdate",
                                   @"AppID":@"123",
                                   @"Percentage":@"10",
                                   @"AlmondMAC": [self getAlmondMac]
                                   };
    [self parseRouterCommandResponse:[self getcommand:firmwareRes2]];
}

+(void)setRebootResponce{
    NSDictionary *rebootRes = @{
                                
                                @"CommandType": @"RebootRouter",
                                @"Success":@"true",
                                @"AlmondMAC": [self getAlmondMac],
                                @"AppID":@"123",
                                @"MobileInternalIndex":@"123"
                                };
    [self parseRouterCommandResponse:[self getcommand:rebootRes]];
}

+(void)setLogsResponce{
    NSDictionary *logDict = @{
                              
                                  @"CommandType": @"SendLogs",
                                  @"Success":@"true",
                                  @"ReasonCode":@"0",
                                  @"AlmondMAC": [self getAlmondMac],
                                  @"AppID":@"123",
                                  @"MobileInternalIndex":@"123"
                              };
    [self parseRouterCommandResponse:[self getcommand:logDict]];
}

+(NSNotification*)getcommand:(NSDictionary*)payload{
    NSDictionary *data = [self getDataDictionary:payload];
    NSNotification *notifier = [[NSNotification alloc]initWithName:@"command" object:nil userInfo:data];
    return notifier;
}


+(NSDictionary*)getDataDictionary:(NSDictionary*)payload{
    NSDictionary *data = nil;
    if (payload) {
        data = @{
                 @"data" : payload
                 };
    }
    return data;
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
//        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
        payload = [dataInfo valueForKey:@"data"];
    }

    BOOL isMatchingAlmondOrLocal = ([[payload valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
    NSLog(@"router payload: %@", payload);
    SFIGenericRouterCommand *genericRouterCommand;
    if([[payload valueForKey:@"CommandType"] isEqualToString:@"RouterSummary"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseRouterSummary:payload] commandType:SFIGenericRouterCommandType_WIRELESS_SUMMARY success:[payload[@"Success"] boolValue] MAC:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:0];
        
    }else if([[payload valueForKey:@"CommandType"] isEqualToString:@"GetWirelessSettings"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseWirelessSettings:payload[@"WirelessSetting"]] commandType:SFIGenericRouterCommandType_WIRELESS_SETTINGS success:[payload[@"Success"] boolValue] MAC:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:0];
    }
    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"SetWirelessSettings"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseWirelessSettings:payload[@"WirelessSetting"]] commandType:SFIGenericRouterCommandType_WIRELESS_SETTINGS success:[payload[@"Success"] boolValue] MAC:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:0];
    }

    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"FirmwareUpdate"]){
        genericRouterCommand = [self createGenericRouterCommand:[self parseWirelessSettings:payload[@"WirelessSetting"]] commandType:SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE success:[payload[@"Success"] boolValue] MAC:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:[payload[@"Percentage"] intValue]];
    }
    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"RebootRouter"]){
        genericRouterCommand = [self createGenericRouterCommand:nil commandType:SFIGenericRouterCommandType_REBOOT success:[payload[@"Success"] boolValue] MAC:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:0];
    }
    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"SendLogs"]){
        genericRouterCommand = [self createGenericRouterCommand:nil commandType:SFIGenericRouterCommandType_SEND_LOGS_RESPONSE success:[payload[@"Success"] boolValue] MAC:payload[@"AlmondMAC"] mii:[payload[@"MobileInternalIndex"] intValue] completionPercentage:0];
    }
    
    NSDictionary *data = nil;
    if (payload) {
        data = @{
                 @"data" : genericRouterCommand
                 };
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil userInfo:data];
}

+(SFIGenericRouterCommand*)createGenericRouterCommand:(id)command commandType:(SFIGenericRouterCommandType)type success:(BOOL)success MAC:(NSString*)MAC mii:(int)mii completionPercentage:(unsigned int)completionPercentage{
    SFIGenericRouterCommand *genericRouterCommand = [SFIGenericRouterCommand new];
    genericRouterCommand.command = command;
    genericRouterCommand.commandType = type;
    genericRouterCommand.commandSuccess = success;
    genericRouterCommand.almondMAC = MAC;
    genericRouterCommand.mii = mii;
    genericRouterCommand.completionPercentage = completionPercentage;
    return  genericRouterCommand;
}


+(SFIRouterSummary*)parseRouterSummary:(NSDictionary*)payload{
    SFIRouterSummary *routerSummary = [[SFIRouterSummary alloc]init];
    routerSummary.uptime = payload[@"Uptime"];
    routerSummary.url = payload[@"URL"];
    routerSummary.login = payload[@"Login"];
    routerSummary.password = payload[@"TempPass"];
    routerSummary.routerUptime = payload[@"RouterUptime"];
    routerSummary.firmwareVersion = payload[@"FirmwareVersion"];
    routerSummary.wirelessSummaries = [self parseWirelessSettingsSummary:payload[@"WirelessSetting"]];
    return routerSummary;
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
