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
    [center addObserver:self selector:@selector(parseRouterResponse:) name:NOTIFICATION_ROUTER_RESPONSE_NOTIFIER object:nil];
}

-(void)testRouterParser{
    NSDictionary *routerSumary = @{
                                   @"CommandType":@"RouterSummary",
                                   @"MobileInternalIndex":@"123456",
                                   @"AlmondMAC":@"251176214925585",
                                   @"AppID":@"123",
                                   @"Success":@"true",
                                   @"Data":@{
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
                                           @"URL":@"10.10.10.10",
                                           @"Login":@"root",
                                           @"TempPass":@"xyz",
                                           @"RouterUptime":@"5 days, 6:15hrs",
                                           @"FirmwareVersion":@"AP2-R054bi-L008-W011-ZW011-ZB003"
                                           }
};
    NSDictionary *getWirelessSettings = @{
                                          @"CommandType":@"GetWirelessSettings",
                                          @"AlmondMAC":@"251176214925585",
                                          @"AppID":@"123",
                                          @"Success":@"true",
                                          @"MobileInternalIndex":@"123",
                                          @"Data":@{
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
                                                  }

                                          };
    NSDictionary *setWirelessSettings = @{
                                              @"CommandType":@"SetWirelessSettings",
                                              @"AlmondMAC":@"251176214925585",
                                              @"AppID":@"123",
                                              @"Success":@"true",
                                              @"MobileInternalIndex":@"123",
                                              @"Data":@{
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
                                                                            }
                                                                          ]
                                                      }
                                          };
    
    [self parseRouterResponse:routerSumary];
    [self parseRouterResponse:getWirelessSettings];
//    [self parseRouterResponse:setWirelessSettings];
}


-(void)parseRouterResponse:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
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
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }

    BOOL isMatchingAlmondOrLocal = ([[payload valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
//    payload = sender;
    NSLog(@"router payload: %@", payload);
    if([[payload valueForKey:@"CommandType"] isEqualToString:@"RouterSummary"]){
        toolkit.routerSummary = [self parseRouterSummary:payload];
        
    }else if([[payload valueForKey:@"CommandType"] isEqualToString:@"GetWirelessSettings"]){
        toolkit.wireLessSettings = [self parseWirelessSettings:payload[@"WirelessSetting"]];
    }
    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"SetWirelessSettings"]){
        [self parseWirelessSettings:payload[@"WirelessSetting"]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil];
}

-(SFIRouterSummary*)parseRouterSummary:(NSDictionary*)payload{
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

-(NSArray*)parseWirelessSettingsSummary:(NSArray*)wirelessSettingsPayloadArray{
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

-(NSArray*)parseWirelessSettings:(NSArray*)wirelessSettingPayloadArray{
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
