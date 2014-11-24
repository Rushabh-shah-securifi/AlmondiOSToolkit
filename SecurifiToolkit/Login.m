//
//  Login.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/16/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "Login.h"
#import "SFIXmlWriter.h"

@implementation Login

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"Login"];

    [writer addElement:@"EmailID" text:self.UserID];
    [writer addElement:@"Password" text:self.Password];

    // close Login
    [writer endElement];
    // close root element
    [writer endElement];

    return writer.toString;
}

@end
