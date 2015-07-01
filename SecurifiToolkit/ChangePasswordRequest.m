//
//  ChangePasswordRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "ChangePasswordRequest.h"
#import "SFIXmlWriter.h"

@implementation ChangePasswordRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"ChangePasswordRequest"];

    [writer addElement:@"EmailID" text:self.emailID];
    [writer addElement:@"CurrentPass" text:self.currentPassword];
    [writer addElement:@"NewPass" text:self.changedPassword];

    // close ChangePasswordRequest
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}
@end
