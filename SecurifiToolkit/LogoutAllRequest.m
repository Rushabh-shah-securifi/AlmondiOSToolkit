//
//  LogoutAllRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "LogoutAllRequest.h"
#import "XMLWriter.h"

@implementation LogoutAllRequest

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"LogoutAll"];

    [writer writeStartElement:@"EmailID"];
    [writer writeCharacters:self.UserID];
    [writer writeEndElement];

    [writer writeStartElement:@"Password"];
    [writer writeCharacters:self.Password];
    [writer writeEndElement];

    // close LogoutAll
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}

@end
