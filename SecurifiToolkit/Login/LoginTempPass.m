//
//  LoginTempPass.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/16/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "LoginTempPass.h"
#import "SFIXmlWriter.h"

@implementation LoginTempPass

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"Login"];

    [writer addElement:@"UserID" text:self.UserID];
    [writer addElement:@"TempPass" text:self.TempPass];

    // close Login
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}

@end
