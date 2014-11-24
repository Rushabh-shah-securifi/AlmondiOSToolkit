//
//  ValidateAccountRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 01/11/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "ValidateAccountRequest.h"
#import "SFIXmlWriter.h"

@implementation ValidateAccountRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"ValidateAccountRequest"];

    [writer element:@"EmailID" text:self.email];

    // close ValidateAccountRequest
    [writer endElement];
    // close root element
    [writer endElement];

    return writer.toString;
}


@end
