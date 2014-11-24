//
//  DeleteAccountRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 18/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "DeleteAccountRequest.h"
#import "SFIXmlWriter.h"

@implementation DeleteAccountRequest
- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"DeleteAccountRequest"];

    [writer element:@"EmailID" text:self.emailID];
    [writer element:@"Password" text:self.password];

    // close DeleteAccountRequest
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}
@end
