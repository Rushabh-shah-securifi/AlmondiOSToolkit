//
//  ValidateAccountRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 01/11/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "ValidateAccountRequest.h"
#import "XMLWriter.h"

@implementation ValidateAccountRequest

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"ValidateAccountRequest"];

    [writer writeStartElement:@"EmailID"];
    if (self.email) {
        [writer writeCharacters:self.email];
    }
    [writer writeEndElement];

    // close ValidateAccountRequest
    [writer writeEndElement];
    // close root element
    [writer writeEndElement];

    return writer.toString;
}


@end
