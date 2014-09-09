//
//  Signup.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "Signup.h"
#import "XMLWriter.h"

@implementation Signup

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"Signup"];

    [writer writeStartElement:@"EmailID"];
    [writer writeCharacters:self.UserID];
    [writer writeEndElement];

    [writer writeStartElement:@"Password"];
    [writer writeCharacters:self.Password];
    [writer writeEndElement];

    // close Signup
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}


@end
