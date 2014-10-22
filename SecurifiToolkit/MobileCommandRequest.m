//
//  MobileCommandRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "MobileCommandRequest.h"
#import "XMLWriter.h"

@implementation MobileCommandRequest


- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"MobileCommand"];

    [writer writeStartElement:@"AlmondplusMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];

    [writer writeStartElement:@"Device"];
    [writer writeAttribute:@"ID" value:self.deviceID];
    //
    [writer writeStartElement:@"NewValue"];
    [writer writeAttribute:@"Index" value:self.indexID];
    [writer writeCharacters:self.changedValue];
    [writer writeEndElement];
    //
    // close Device
    [writer writeEndElement];

    [self writeMobileInternalIndexElement:writer];

    // close MobileCommand
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}


@end
