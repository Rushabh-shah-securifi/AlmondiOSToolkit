//
//  AlmondNameChange.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "AlmondNameChange.h"
#import "XMLWriter.h"
@implementation AlmondNameChange

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"AlmondNameChange"];
    
    [writer writeStartElement:@"AlmondplusMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];
    
    [writer writeStartElement:@"NewName"];
    [writer writeCharacters:self.changedAlmondName];
    [writer writeEndElement];
    
    [writer writeStartElement:@"MobileInternalIndex"];
    [writer writeCharacters:self.mobileInternalIndex];
    [writer writeEndElement];
    
    // close AlmondNameChange
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}
@end
