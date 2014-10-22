//
//  UnlinkAlmondRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "UnlinkAlmondRequest.h"
#import "XMLWriter.h"

@implementation UnlinkAlmondRequest
- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"UnlinkAlmondRequest"];
    
    [writer writeStartElement:@"AlmondMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];
    
    [writer writeStartElement:@"EmailID"];
    [writer writeCharacters:self.emailID];
    [writer writeEndElement];
    
    [writer writeStartElement:@"Password"];
    [writer writeCharacters:self.password];
    [writer writeEndElement];

    [self writeMobileInternalIndexElement:writer];
    
    // close UnlinkAlmondRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}
@end

