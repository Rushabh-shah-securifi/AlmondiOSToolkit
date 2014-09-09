//
//  DeviceValueRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "DeviceValueRequest.h"
#import "XMLWriter.h"

@implementation DeviceValueRequest

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
    [writer writeStartElement:@"DeviceValue"];

    [writer writeStartElement:@"AlmondplusMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];

    // close DeviceValue
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}


@end
