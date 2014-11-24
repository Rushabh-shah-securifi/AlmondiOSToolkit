//
//  SFIWirelessSettings.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 13/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIWirelessSetting.h"
#import "SFIXmlWriter.h"

@implementation SFIWirelessSetting

// @"<root><AlmondWirelessSettings action=\"set\" count=\"%d\"><WirelessSetting index=\"%d\"><SSID>%@</SSID><Password>%@</Password><Channel>%d</Channel><EncryptionType>%@</EncryptionType><Security>%@</Security><WirelessMode>%d</WirelessMode></WirelessSetting></AlmondWirelessSettings></root>"

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];

    [writer startElement:@"AlmondWirelessSettings"];
    [writer addAttribute:@"action" value:@"set"];
    [writer addAttribute:@"count" value:@"1"];

    [writer startElement:@"WirelessSetting"];
    [writer addAttribute:@"index" value:[NSString stringWithFormat:@"%d", self.index]];
    [writer addAttribute:@"enabled" value:(self.enabled ? @"true" : @"false")];
    //
    [writer addElement:@"SSID" text:self.ssid];
    [writer addElement:@"Password" text:self.password];
    [writer addElement:@"Channel" text:[NSString stringWithFormat:@"%d", self.channel]];
    [writer addElement:@"EncryptionType" text:self.encryptionType];
    [writer addElement:@"Security" text:self.security];
    [writer addElement:@"WirelessMode" text:[NSString stringWithFormat:@"%d", self.wirelessModeCode]];
    //
    [writer endElement];
    //
    // close AlmondWirelessSettings
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}

- (id)copyWithZone:(NSZone *)zone {
    SFIWirelessSetting *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.index = self.index;
        copy.enabled = self.enabled;
        copy.ssid = self.ssid;
        copy.password = self.password;
        copy.channel = self.channel;
        copy.encryptionType = self.encryptionType;
        copy.security = self.security;
        copy.wirelessMode = self.wirelessMode;
        copy.wirelessModeCode = self.wirelessModeCode;
        copy.countryRegion = self.countryRegion;
    }

    return copy;
}


@end
