//
//  LogoutAllRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "LogoutAllRequest.h"
#import "SFIXmlWriter.h"

@implementation LogoutAllRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"LogoutAll"];

    [writer addElement:@"EmailID" text:self.UserID];
    [writer addElement:@"Password" text:self.Password];

    // close LogoutAll
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}

@end
