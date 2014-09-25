//
//  ChangePasswordRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "ChangePasswordRequest.h"
#import "XMLWriter.h"

@implementation ChangePasswordRequest
- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"ChangePasswordRequest"];
    
    [writer writeStartElement:@"EmailID"];
    [writer writeCharacters:self.emailID];
    [writer writeEndElement];
    
    [writer writeStartElement:@"CurrentPass"];
    [writer writeCharacters:self.currentPassword];
    [writer writeEndElement];
    
    [writer writeStartElement:@"NewPass"];
    [writer writeCharacters:self.changedPassword];
    [writer writeEndElement];
    
    // close ChangePasswordRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}
@end
