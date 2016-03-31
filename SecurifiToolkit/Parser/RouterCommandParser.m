//
//  RouterCommandParser.m
//  TestApp
//
//  Created by Priya Yerunkar on 16/08/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "RouterCommandParser.h"
#import "SFIWirelessSetting.h"
#import "SFIDevicesList.h"
#import "SFIBlockedDevice.h"
#import "SFIGenericRouterCommand.h"
#import "Client.h"
#import "SFIRouterSummary.h"
#import "SFIWirelessSummary.h"
#import "GenericCommandResponse.h"
#import "SFIBlockedContent.h"

#define ROUTER_SEND_LOGS_RESPONSE   @"SendLogsResponse"
#define ROUTER_SEND_LOGS_SUCCESS    @"success"
#define ROUTER_SEND_LOGS_REASON     @"Reason"

// software update
#define ROUTER_SOFTWARE_UPDATE @"FirmwareUpdateResponse"
#define ROUTER_SOFTWARE_UPDATE_SUCCESS @"success"
#define ROUTER_SOFTWARE_UPDATE_PERCENTAGE @"Percentage"

#define REBOOT @"Reboot"
#define COUNT @"count"
#define CONNECTED_DEVICES @"AlmondConnectedDevices"
#define CONNECTED_DEVICE @"ConnectedDevice"
#define NAME @"Name"
#define IP @"IP"
#define MAC @"MAC"
#define NO_ALMOND @"NO ALMOND"

#define BLOCKED_MACS @"AlmondBlockedMACs"
#define BLOCKED_MAC @"BlockedMAC"

#define BLOCKED_CONTENT @"AlmondBlockedContent"
#define BLOCKED_TEXT @"BlockedText"

#define WIRELESS_SETTINGS @"AlmondWirelessSettings"
#define WIRELESS_SETTING @"WirelessSetting"
#define SSID @"SSID"
#define WIRELESS_PASSWORD @"Password"
#define CHANNEL @"Channel"
#define ENCRYPTION_TYPE @"EncryptionType"
#define SECURITY @"Security"
#define WIRELESS_MODE @"WirelessMode"
#define COUNTRY_REGION @"CountryRegion"
#define INDEX @"index"
#define ACTION @"action"

#define ROUTER_SUMMARY @"AlmondRouterSummary"
#define ENABLED @"enabled"
#define ROUTER_UPTIME @"RouterUptime"
#define ROUTER_UPTIME_RAW @"Uptime"
#define WIRELESS_SETTINGS_SUMMARY @"AlmondWirelessSettingsSummary"
#define CONNECTED_DEVICES_SUMMARY @"AlmondConnectedDevicesSummary"
#define BLOCKED_MAC_SUMMARY @"AlmondBlockedMACSummary"
#define BLOCKED_CONTENT_SUMMARY @"AlmondBlockedContentSummary"
#define FIRMWARE_VERSION @"FirmwareVersion"
#define ROUTER_URL @"Url"
#define ROUTER_LOGIN @"Login"
#define ROUTER_PASSWORD @"TempPass"

@interface RouterCommandParser () <NSXMLParserDelegate>
@property(nonatomic, retain) SFIGenericRouterCommand *genericCommandResponse;
@property(nonatomic, retain) NSMutableString *currentNodeContent;

@property(nonatomic, retain) SFIDevicesList *connectedDevices;
@property(nonatomic, retain) NSMutableArray *connectedDevicesArray;

@property(nonatomic, retain) Client *currentConnectedDevice;

@property(nonatomic, retain) SFIDevicesList *blockedDevices;
@property(nonatomic, retain) NSMutableArray *blockedDevicesArray;
@property(nonatomic, retain) SFIBlockedDevice *currentBlockedDevice;

@property(nonatomic, retain) SFIDevicesList *blockedContent;
@property(nonatomic, retain) NSMutableArray *blockedContentArray;
@property(nonatomic, retain) SFIBlockedContent *currentBlockedContent;

@property(nonatomic, retain) SFIDevicesList *wirelessSettings;
@property(nonatomic, retain) NSMutableArray *wirelessSettingsArray;
@property(nonatomic, retain) SFIWirelessSetting *currentWirelessSetting;

@property(nonatomic, retain) SFIRouterSummary *routerSummary;
@property(nonatomic, retain) NSMutableArray *wirelessSummaryArray;
@property(nonatomic, retain) SFIWirelessSummary *currentWirelessSummary;
@end

@implementation RouterCommandParser

+ (SFIGenericRouterCommand *)parseRouterResponse:(GenericCommandResponse *)response {
    NSData *data = response.decodedData;

    if (data == nil || data.length < 8) {
        SFIGenericRouterCommand *res = [SFIGenericRouterCommand new];
        res.commandSuccess = NO;
        res.responseMessage = response.reason;
        return res;
    }

    NSMutableData *genericData = [NSMutableData new];
    [genericData appendData:data];

    unsigned int expectedDataLength;
    unsigned int commandData;

    [genericData getBytes:&expectedDataLength range:NSMakeRange(0, 4)];
    [genericData getBytes:&commandData range:NSMakeRange(4, 4)];

    //Remove 8 bytes from received command
    [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

    RouterCommandParser *sfiParser = [RouterCommandParser new];
    return [sfiParser internalParseData:genericData];
}

- (SFIGenericRouterCommand *)internalParseData:(NSData *)data {
    self.genericCommandResponse = [SFIGenericRouterCommand new];

    NSXMLParser *parser= [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;

    [parser parse];
    return self.genericCommandResponse;
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)xmlParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.currentNodeContent = [NSMutableString string];

    if ([elementName isEqualToString:REBOOT]) {
        self.genericCommandResponse.commandType = SFIGenericRouterCommandType_REBOOT;
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES]) {
        self.connectedDevices = [SFIDevicesList new];
        self.genericCommandResponse.commandType = SFIGenericRouterCommandType_CONNECTED_DEVICES;
        self.connectedDevices.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.connectedDevicesArray = [NSMutableArray new];
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICE]) {
        self.currentConnectedDevice = [Client new];
    }
    else if ([elementName isEqualToString:BLOCKED_MACS]) {
        self.blockedDevices = [SFIDevicesList new];
        self.genericCommandResponse.commandType = SFIGenericRouterCommandType_BLOCKED_MACS;
        self.blockedDevices.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.blockedDevicesArray = [NSMutableArray new];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC]) {
        self.currentBlockedDevice = [SFIBlockedDevice new];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT]) {
        self.blockedContent = [SFIDevicesList new];
        self.genericCommandResponse.commandType = SFIGenericRouterCommandType_BLOCKED_CONTENT;
        self.blockedDevices.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.blockedContentArray = [NSMutableArray new];
    }
    else if ([elementName isEqualToString:BLOCKED_TEXT]) {
        self.currentBlockedContent = [SFIBlockedContent new];
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS]) {
        self.wirelessSettings = [SFIDevicesList new];
        self.genericCommandResponse.commandType = SFIGenericRouterCommandType_WIRELESS_SETTINGS;
        self.wirelessSettings.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.wirelessSettingsArray = [NSMutableArray new];
    }
    else if ([elementName isEqualToString:WIRELESS_SETTING]) {
        if (self.genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            self.currentWirelessSetting = [SFIWirelessSetting new];
            self.currentWirelessSetting.index = [[attributeDict valueForKey:INDEX] intValue];;
            self.currentWirelessSetting.enabled = [[attributeDict valueForKey:ENABLED] isEqualToString:@"true"];;
        }
        else if (self.genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            self.currentWirelessSummary = [SFIWirelessSummary new];
            self.currentWirelessSummary.wirelessIndex = [[attributeDict valueForKey:INDEX] intValue];;
            self.currentWirelessSummary.enabled = [[attributeDict valueForKey:ENABLED] isEqualToString:@"true"];;
        }
    }
    else if ([elementName isEqualToString:ROUTER_SUMMARY]) {
        self.routerSummary = [SFIRouterSummary new];
        self.genericCommandResponse.commandType = SFIGenericRouterCommandType_WIRELESS_SUMMARY;
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS_SUMMARY]) {
        self.routerSummary.wirelessSettingsCount = [[attributeDict valueForKey:COUNT] intValue];
        self.wirelessSummaryArray = [NSMutableArray new];
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES_SUMMARY]) {
        self.routerSummary.connectedDeviceCount = [[attributeDict valueForKey:COUNT] intValue];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC_SUMMARY]) {
        self.routerSummary.blockedMACCount = [[attributeDict valueForKey:COUNT] intValue];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT_SUMMARY]) {
        self.routerSummary.blockedContentCount = [[attributeDict valueForKey:COUNT] intValue];
    }
    else if ([elementName isEqualToString:ROUTER_SEND_LOGS_RESPONSE]) {
        self.genericCommandResponse.commandType = SFIGenericRouterCommandType_SEND_LOGS_RESPONSE;
        self.genericCommandResponse.commandSuccess = [[attributeDict valueForKey:ROUTER_SEND_LOGS_SUCCESS] isEqualToString:@"true"];
    }
    else if ([elementName isEqualToString:ROUTER_SOFTWARE_UPDATE]) {
        self.genericCommandResponse.commandType = SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE;
        self.genericCommandResponse.commandSuccess = [[attributeDict valueForKey:ROUTER_SOFTWARE_UPDATE_SUCCESS] isEqualToString:@"true"];
    }
}

- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:REBOOT]) {
        self.genericCommandResponse.commandSuccess = ([self.currentNodeContent intValue] == 1);
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES]) {
        self.connectedDevices.deviceList = self.connectedDevicesArray;
        self.genericCommandResponse.command = self.connectedDevices;
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICE]) {
        [self.connectedDevicesArray addObject:self.currentConnectedDevice];
    }
    else if ([elementName isEqualToString:NAME]) {
        self.currentConnectedDevice.name = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:IP]) {
        self.currentConnectedDevice.deviceIP = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:MAC]) {
        self.currentConnectedDevice.deviceMAC = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:BLOCKED_MAC]) {
        self.currentBlockedDevice.deviceMAC = self.currentNodeContent;
        [self.blockedDevicesArray addObject:self.currentBlockedDevice];
    }
    else if ([elementName isEqualToString:BLOCKED_MACS]) {
        self.blockedDevices.deviceList = self.blockedDevicesArray;
        self.genericCommandResponse.command = self.blockedDevices;
    }
    else if ([elementName isEqualToString:BLOCKED_TEXT]) {
        self.currentBlockedContent.blockedText = self.currentNodeContent;
        [self.blockedContentArray addObject:self.currentBlockedContent];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT]) {
        self.blockedContent.deviceList = self.blockedContentArray;
        self.genericCommandResponse.command = self.blockedContent;
    }
    else if ([elementName isEqualToString:SSID]) {
        if (self.genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            self.currentWirelessSetting.ssid = self.currentNodeContent;
        }
        else if (self.genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            self.currentWirelessSummary.ssid = self.currentNodeContent;
        }
    }
    else if ([elementName isEqualToString:WIRELESS_PASSWORD]) {
        self.currentWirelessSetting.password = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:CHANNEL]) {
        self.currentWirelessSetting.channel = [self.currentNodeContent intValue];
    }
    else if ([elementName isEqualToString:ENCRYPTION_TYPE]) {
        self.currentWirelessSetting.encryptionType = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:SECURITY]) {
        self.currentWirelessSetting.security = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:WIRELESS_MODE]) {
        self.currentWirelessSetting.wirelessMode = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:COUNTRY_REGION]) {
        self.currentWirelessSetting.countryRegion = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:WIRELESS_SETTING]) {
        if (self.genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            [self.wirelessSettingsArray addObject:self.currentWirelessSetting];
        }
        else if (self.genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            [self.wirelessSummaryArray addObject:self.currentWirelessSummary];
        }
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS]) {
        self.wirelessSettings.deviceList = self.wirelessSettingsArray;
        self.genericCommandResponse.command = self.wirelessSettings;
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS_SUMMARY]) {
        self.routerSummary.wirelessSummaries = self.wirelessSummaryArray;
    }
    else if ([elementName isEqualToString:ROUTER_UPTIME]) {
        self.routerSummary.routerUptime = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_UPTIME_RAW]) {
        self.routerSummary.uptime = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:FIRMWARE_VERSION]) {
        self.routerSummary.firmwareVersion = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_URL]) {
        self.routerSummary.url = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_LOGIN]) {
        self.routerSummary.login = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_PASSWORD]) {
        self.routerSummary.password = self.currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_SUMMARY]) {
        self.genericCommandResponse.command = self.routerSummary;
    }
    else if ([elementName isEqualToString:ROUTER_SEND_LOGS_REASON]) {
        self.genericCommandResponse.responseMessage = self.currentNodeContent;
    }
    else if (self.genericCommandResponse.commandType == SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE) {
        if ([elementName isEqualToString:ROUTER_SOFTWARE_UPDATE_PERCENTAGE]) {
            NSMutableString *value = self.currentNodeContent;
            @try {
                int num = value.intValue;
                self.genericCommandResponse.completionPercentage = (unsigned int) num;
            }
            @catch (NSException *ex) {
                NSLog(@"Failed to parse the completion percentage: %@, ex:%@", value, ex.description);
            }
        }
    }
}

- (void)parser:(NSXMLParser *)xmlParser foundCharacters:(NSString *)string {
    NSString *cleaned = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.currentNodeContent appendString:cleaned];
}

@end
