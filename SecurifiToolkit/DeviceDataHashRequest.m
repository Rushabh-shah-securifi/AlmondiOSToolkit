//
//  DeviceDataHashRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "DeviceDataHashRequest.h"
#import "SFIXmlWriter.h"

@implementation DeviceDataHashRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"DeviceDataHash"];

    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];

    // close DeviceDataHash
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}

@end
