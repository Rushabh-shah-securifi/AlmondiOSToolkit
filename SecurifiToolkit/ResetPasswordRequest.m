//
//  ResetPasswordRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 01/11/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "ResetPasswordRequest.h"
#import "SFIXmlWriter.h"

@implementation ResetPasswordRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"ResetPasswordRequest"];

    [writer addElement:@"EmailID" text:self.email];

    // close ValidateAccountRequest
    [writer endElement];
    // close root element
    [writer endElement];

    return writer.toString;
}


@end
