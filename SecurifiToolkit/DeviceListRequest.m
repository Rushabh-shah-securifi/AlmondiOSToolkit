//
//  DeviceListRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "DeviceListRequest.h"
#import "XMLWriter.h"

@implementation DeviceListRequest

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.almondMAC=%@", self.almondMAC];
    [description appendString:@">"];
    return description;
}

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"DeviceData"];

    [writer writeStartElement:@"AlmondplusMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];

    // close DeviceData
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}


@end
