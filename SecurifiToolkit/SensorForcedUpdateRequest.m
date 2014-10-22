//
//  DeviceDataForcedUpdateRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 15/01/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "SensorForcedUpdateRequest.h"
#import "XMLWriter.h"
#import "BaseCommandRequest.h"


@implementation SensorForcedUpdateRequest


- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"DeviceDataForcedUpdate"];

    [writer writeStartElement:@"AlmondplusMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];

    [self writeMobileInternalIndexElement:writer];

    // close DeviceDataForcedUpdate
    [writer writeEndElement];
    // close root element
    [writer writeEndElement];

    return writer.toString;
}


@end
