//
//  SensorChangeRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/01/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "SensorChangeRequest.h"
#import "XMLWriter.h"

@implementation SensorChangeRequest

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"SensorChange"];

    [writer writeStartElement:@"AlmondplusMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];

    [writer writeStartElement:@"Device"];
    [writer writeAttribute:@"ID" value:self.deviceID];
    //
    if (self.changedName.length > 0) {
        [writer writeStartElement:@"NewName"];
        [writer writeCharacters:self.changedName];
        [writer writeEndElement];
    }
    //
    if (self.changedLocation.length > 0) {
        [writer writeStartElement:@"NewLocation"];
        [writer writeCharacters:self.changedLocation];
        [writer writeEndElement];
    }
    //
    // close Device
    [writer writeEndElement];

    [writer writeStartElement:@"MobileInternalIndex"];
    [writer writeCharacters:self.mobileInternalIndex];
    [writer writeEndElement];

    // close SensorChange
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}

@end
