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

    [writer element:@"AlmondplusMAC" text:self.almondMAC];

    [writer startElement:@"Device"];
    [writer addAttribute:@"ID" value:self.deviceID];
    //
    NSString *name = [self.changedName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (name.length > 0) {
        [writer element:@"NewName" text:name];
    }
    //
    NSString *location = [self.changedLocation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (location.length > 0) {
        [writer element:@"NewLocation" text:location];
    }
    //
    // close Device
    [writer endElement];

    [self writeMobileInternalIndexElement:writer];

    // close SensorChange
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}

@end
