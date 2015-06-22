//
//  SensorChangeRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/01/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "SensorChangeRequest.h"
#import "SFIXmlWriter.h"

@implementation SensorChangeRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"SensorChange"];

    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];

    [writer startElement:@"Device"];
    [writer addAttribute:@"ID" intValue:self.deviceId];
    //
    NSString *name = [self.changedName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (name.length > 0) {
        [writer addElement:@"NewName" text:name];
    }
    //
    NSString *location = [self.changedLocation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (location.length > 0) {
        [writer addElement:@"NewLocation" text:location];
    }
    //
    // close Device
    [writer endElement];

    [self addMobileInternalIndexElement:writer];

    // close SensorChange
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}

/*

{
"mii":"<random key>",
"cmd":"editdevicename",
"devid":"6",
"name":"newswitchsss",
"location":"default"
}

 */

- (NSData *)toJson {
    NSString *mii = [NSString stringWithFormat:@"%d", self.correlationId];

    NSDictionary *payload = @{
            @"mii" : mii,
            @"cmd" : @"editdevicename",
            @"devid" : @(self.deviceId).stringValue,
            @"name" : self.changedName,
            @"location" : self.changedLocation
    };

    return [self serializeJson:payload];
}


@end
