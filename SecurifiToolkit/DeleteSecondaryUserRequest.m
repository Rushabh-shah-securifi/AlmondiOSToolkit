//
//  DeleteSecondaryUserRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "DeleteSecondaryUserRequest.h"
#import "XMLWriter.h"

@implementation DeleteSecondaryUserRequest
- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"DeleteSecondaryUserRequest"];
    
    [writer writeStartElement:@"AlmondMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];
    
    [writer writeStartElement:@"EmailID"];
    [writer writeCharacters:self.emailID];
    [writer writeEndElement];

    [self writeMobileInternalIndexElement:writer];
    
    // close DeleteSecondaryUserRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}
@end
