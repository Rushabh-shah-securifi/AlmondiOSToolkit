//
//  Signup.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "Signup.h"
#import "SFIXmlWriter.h"

@implementation Signup

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"Signup"];

    [writer addElement:@"EmailID" text:self.UserID];
    [writer addElement:@"Password" text:self.Password];

    // close Signup
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}


@end
