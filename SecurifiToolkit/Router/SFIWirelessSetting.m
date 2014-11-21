//
//  SFIWirelessSettings.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 13/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIWirelessSetting.h"
#import "XMLWriter.h"

@implementation SFIWirelessSetting

// @"<root><AlmondWirelessSettings action=\"set\" count=\"%d\"><WirelessSetting index=\"%d\"><SSID>%@</SSID><Password>%@</Password><Channel>%d</Channel><EncryptionType>%@</EncryptionType><Security>%@</Security><WirelessMode>%d</WirelessMode></WirelessSetting></AlmondWirelessSettings></root>"

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];

    [writer writeStartElement:@"AlmondWirelessSettings"];
    [writer writeAttribute:@"action" value:@"set"];
    [writer writeAttribute:@"count" value:@"1"];

    [writer writeStartElement:@"WirelessSetting"];
    [writer writeAttribute:@"index" value:[NSString stringWithFormat:@"%d", self.index]];
    [writer writeAttribute:@"enabled" value:(self.enabled ? @"true" : @"false")];
    //
    [writer writeStartElement:@"SSID"];
    [writer writeCharacters:[self stringOrEmpty:self.ssid]];
    [writer writeEndElement];
    //
    [writer writeStartElement:@"Password"];
    [writer writeCharacters:[self stringOrEmpty:self.password]];
    [writer writeEndElement];
    //
    [writer writeStartElement:@"Channel"];
    [writer writeCharacters:[NSString stringWithFormat:@"%d", self.channel]];
    [writer writeEndElement];
    //
    [writer writeStartElement:@"EncryptionType"];
    [writer writeCharacters:[self stringOrEmpty:self.encryptionType]];
    [writer writeEndElement];
    //
    [writer writeStartElement:@"Security"];
    [writer writeCharacters:[self stringOrEmpty:self.security]];
    [writer writeEndElement];
    //
    [writer writeStartElement:@"WirelessMode"];
    [writer writeCharacters:[NSString stringWithFormat:@"%d", self.wirelessModeCode]];
    [writer writeEndElement];
    //
    [writer writeEndElement];
    //
    // close AlmondWirelessSettings
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}

- (NSString *)stringOrEmpty:(NSString*)str {
    return str.length == 0 ? @"" : str;
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
