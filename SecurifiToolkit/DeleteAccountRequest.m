//
//  DeleteAccountRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 18/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "DeleteAccountRequest.h"
#import "XMLWriter.h"

@implementation DeleteAccountRequest
- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"DeleteAccountRequest"];
    
    [writer writeStartElement:@"EmailID"];
    [writer writeCharacters:self.emailID];
    [writer writeEndElement];
    
    [writer writeStartElement:@"Password"];
    [writer writeCharacters:self.password];
    [writer writeEndElement];
    
    // close DeleteAccountRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}
@end
