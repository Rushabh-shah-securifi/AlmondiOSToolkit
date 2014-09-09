//
//  AffiliationUserResponse.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/29/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "AffiliationUserRequest.h"
#import "XMLWriter.h"

@implementation AffiliationUserRequest

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"AffiliationCodeRequest"];

    [writer writeStartElement:@"Code"];
    [writer writeCharacters:self.Code];
    [writer writeEndElement];

    // close AffiliationCodeRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}


@end
