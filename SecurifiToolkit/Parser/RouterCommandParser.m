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
#import "SFIConnectedDevice.h"
#import "SFIRouterSummary.h"
#import "SFIWirelessSummary.h"
#import "GenericCommandResponse.h"

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

//PY 121113
#define BLOCKED_MACS @"AlmondBlockedMACs"
#define BLOCKED_MAC @"BlockedMAC"

//PY 131113
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

//PY 271113 - Router Summary

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

@implementation RouterCommandParser

@synthesize currentNodeContent, parser, sensors;
@synthesize currentKnownValue, knownValues;
@synthesize genericCommandResponse;
@synthesize connectedDevices, connectedDevicesArray, currentConnectedDevice;
@synthesize blockedDevices, blockedDevicesArray, currentBlockedDevice;
@synthesize blockedContent, blockedContentArray, currentBlockedContent;
@synthesize currentWirelessSetting, wirelessSettings, wirelessSettingsArray;
@synthesize routerSummary, currentWirelessSummary, wirelessSummaryArray;

+ (SFIGenericRouterCommand *)parseRouterResponse:(GenericCommandResponse *)response {
    NSData *data = response.decodedData;

    if (data == nil || data.length < 8) {
        SFIGenericRouterCommand *res = [SFIGenericRouterCommand new];
        res.commandSuccess = NO;
        res.responseMessage = response.reason;
        return res;
    }

    NSMutableData *genericData = [[NSMutableData alloc] init];
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

- (SFIGenericRouterCommand *)loadDataFromString:(NSString *)xmlString {
    NSData *data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    return [self internalParseData:data];
}

- (SFIGenericRouterCommand *)internalParseData:(const NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;

    genericCommandResponse = [[SFIGenericRouterCommand alloc] init];
    [parser parse];

    return genericCommandResponse;
}

- (void)parser:(NSXMLParser *)xmlParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    currentNodeContent = [NSMutableString string];

    if ([elementName isEqualToString:REBOOT]) {
        genericCommandResponse.commandType = SFIGenericRouterCommandType_REBOOT;
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES]) {
        connectedDevices = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_CONNECTED_DEVICES;
        connectedDevices.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.connectedDevicesArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICE]) {
        self.currentConnectedDevice = [[SFIConnectedDevice alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_MACS]) {
        blockedDevices = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_BLOCKED_MACS;
        blockedDevices.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.blockedDevicesArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC]) {
        self.currentBlockedDevice = [[SFIBlockedDevice alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT]) {
        blockedContent = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_BLOCKED_CONTENT;
        blockedDevices.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.blockedContentArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_TEXT]) {
        self.currentBlockedContent = [[SFIBlockedContent alloc] init];
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS]) {
        wirelessSettings = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_WIRELESS_SETTINGS;
        wirelessSettings.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.wirelessSettingsArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:WIRELESS_SETTING]) {
        if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            self.currentWirelessSetting = [[SFIWirelessSetting alloc] init];
            self.currentWirelessSetting.index = [[attributeDict valueForKey:INDEX] intValue];;
            self.currentWirelessSetting.enabled = [[attributeDict valueForKey:ENABLED] isEqualToString:@"true"];;
        }
        else if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            self.currentWirelessSummary = [[SFIWirelessSummary alloc] init];
            self.currentWirelessSummary.wirelessIndex = [[attributeDict valueForKey:INDEX] intValue];;
            self.currentWirelessSummary.enabled = [[attributeDict valueForKey:ENABLED] isEqualToString:@"true"];;
        }
    }
    else if ([elementName isEqualToString:ROUTER_SUMMARY]) {
        routerSummary = [[SFIRouterSummary alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_WIRELESS_SUMMARY;
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS_SUMMARY]) {
        routerSummary.wirelessSettingsCount = [[attributeDict valueForKey:COUNT] intValue];
        self.wirelessSummaryArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES_SUMMARY]) {
        routerSummary.connectedDeviceCount = [[attributeDict valueForKey:COUNT] intValue];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC_SUMMARY]) {
        routerSummary.blockedMACCount = [[attributeDict valueForKey:COUNT] intValue];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT_SUMMARY]) {
        routerSummary.blockedContentCount = [[attributeDict valueForKey:COUNT] intValue];
    }
    else if ([elementName isEqualToString:ROUTER_SEND_LOGS_RESPONSE]) {
        genericCommandResponse.commandType = SFIGenericRouterCommandType_SEND_LOGS_RESPONSE;
        genericCommandResponse.commandSuccess = [[attributeDict valueForKey:ROUTER_SEND_LOGS_SUCCESS] isEqualToString:@"true"];
    }
    else if ([elementName isEqualToString:ROUTER_SOFTWARE_UPDATE]) {
        genericCommandResponse.commandType = SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE;
        genericCommandResponse.commandSuccess = [[attributeDict valueForKey:ROUTER_SOFTWARE_UPDATE_SUCCESS] isEqualToString:@"true"];
    }
}

- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:REBOOT]) {
        genericCommandResponse.commandSuccess = ([currentNodeContent intValue] == 1);
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES]) {
        [connectedDevices setDeviceList:self.connectedDevicesArray];
        genericCommandResponse.command = connectedDevices;
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICE]) {
        [self.connectedDevicesArray addObject:self.currentConnectedDevice];
    }
    else if ([elementName isEqualToString:NAME]) {
        self.currentConnectedDevice.name = currentNodeContent;
    }
    else if ([elementName isEqualToString:IP]) {
        self.currentConnectedDevice.deviceIP = currentNodeContent;
    }
    else if ([elementName isEqualToString:MAC]) {
        self.currentConnectedDevice.deviceMAC = currentNodeContent; //[currentNodeContent uppercaseString];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC]) {
        self.currentBlockedDevice.deviceMAC = currentNodeContent;
        [self.blockedDevicesArray addObject:self.currentBlockedDevice];
    }
    else if ([elementName isEqualToString:BLOCKED_MACS]) {
        [blockedDevices setDeviceList:self.blockedDevicesArray];
        genericCommandResponse.command = blockedDevices;
    }
    else if ([elementName isEqualToString:BLOCKED_TEXT]) {
        self.currentBlockedContent.blockedText = currentNodeContent;
        [self.blockedContentArray addObject:self.currentBlockedContent];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT]) {
        [blockedContent setDeviceList:self.blockedContentArray];
        genericCommandResponse.command = blockedContent;
    }
    else if ([elementName isEqualToString:SSID]) {
        if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            self.currentWirelessSetting.ssid = currentNodeContent;
        }
        else if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            self.currentWirelessSummary.ssid = currentNodeContent;
        }
    }
    else if ([elementName isEqualToString:WIRELESS_PASSWORD]) {
        self.currentWirelessSetting.password = currentNodeContent;
    }
    else if ([elementName isEqualToString:CHANNEL]) {
        self.currentWirelessSetting.channel = [currentNodeContent intValue];
    }
    else if ([elementName isEqualToString:ENCRYPTION_TYPE]) {
        self.currentWirelessSetting.encryptionType = currentNodeContent;
    }
    else if ([elementName isEqualToString:SECURITY]) {
        self.currentWirelessSetting.security = currentNodeContent;
    }
    else if ([elementName isEqualToString:WIRELESS_MODE]) {
        self.currentWirelessSetting.wirelessMode = currentNodeContent;
    }
    else if ([elementName isEqualToString:COUNTRY_REGION]) {
        self.currentWirelessSetting.countryRegion = currentNodeContent;
    }
    else if ([elementName isEqualToString:WIRELESS_SETTING]) {
        if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            [self.wirelessSettingsArray addObject:self.currentWirelessSetting];
        }//PY 271113 - Router Summary
        else if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            [self.wirelessSummaryArray addObject:self.currentWirelessSummary];
        }
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS]) {
        wirelessSettings.deviceList = self.wirelessSettingsArray;
        genericCommandResponse.command = wirelessSettings;
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS_SUMMARY]) {
        routerSummary.wirelessSummaries = self.wirelessSummaryArray;
    }
    else if ([elementName isEqualToString:ROUTER_UPTIME]) {
        routerSummary.routerUptime = currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_UPTIME_RAW]) {
        routerSummary.uptime = currentNodeContent;
    }
    else if ([elementName isEqualToString:FIRMWARE_VERSION]) {
        routerSummary.firmwareVersion = currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_URL]) {
        routerSummary.url = currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_LOGIN]) {
        routerSummary.login = currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_PASSWORD]) {
        routerSummary.password = currentNodeContent;
    }
    else if ([elementName isEqualToString:ROUTER_SUMMARY]) {
        genericCommandResponse.command = routerSummary;
    }
    else if ([elementName isEqualToString:ROUTER_SEND_LOGS_REASON]) {
        genericCommandResponse.responseMessage = currentNodeContent;
    }
    else if (genericCommandResponse.commandType == SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE) {
        if ([elementName isEqualToString:ROUTER_SOFTWARE_UPDATE_PERCENTAGE]) {
            NSMutableString *value = currentNodeContent;
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
    [currentNodeContent appendString:cleaned];
}

@end
