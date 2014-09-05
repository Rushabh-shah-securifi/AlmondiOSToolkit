//
//  Login.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/16/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "Login.h"
#import "XMLWriter.h"

@implementation Login

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"Login"];

    [writer writeStartElement:@"EmailID"];
    [writer writeCharacters:self.UserID];
    [writer writeEndElement];

    [writer writeStartElement:@"Password"];
    [writer writeCharacters:self.Password];
    [writer writeEndElement];

    // close Login
    [writer writeEndElement];
    // close root element
    [writer writeEndElement];

    return writer.toString;
}

@end
