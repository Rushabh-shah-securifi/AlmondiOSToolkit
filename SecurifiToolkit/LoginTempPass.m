//
//  LoginTempPass.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/16/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "LoginTempPass.h"
#import "XMLWriter.h"

@implementation LoginTempPass

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"Login"];

    [writer writeStartElement:@"UserID"];
    [writer writeCharacters:self.UserID];
    [writer writeEndElement];

    [writer writeStartElement:@"TempPass"];
    [writer writeCharacters:self.TempPass];
    [writer writeEndElement];

    // close Login
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}

@end
