//
//  Signup.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "Signup.h"
#import "SFIXmlWriter.h"

@implementation Signup

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"Signup"];

    [writer element:@"EmailID" text:self.UserID];
    [writer element:@"Password" text:self.Password];

    // close Signup
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}


@end
