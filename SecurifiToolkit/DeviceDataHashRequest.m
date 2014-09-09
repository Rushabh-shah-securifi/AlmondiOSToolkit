//
//  DeviceDataHashRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "DeviceDataHashRequest.h"
#import "XMLWriter.h"

@implementation DeviceDataHashRequest

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"DeviceDataHash"];

    [writer writeStartElement:@"AlmondplusMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];

    // close DeviceDataHash
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}

@end
