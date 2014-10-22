//
//  DeleteMeAsSecondaryUserRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 24/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "DeleteMeAsSecondaryUserRequest.h"
#import "XMLWriter.h"

@implementation DeleteMeAsSecondaryUserRequest

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"DeleteMeAsSecondaryUserRequest"];
    
    [writer writeStartElement:@"AlmondMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];

    [self writeMobileInternalIndexElement:writer];
    
    // close DeleteMeAsSecondaryUserRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}
@end
