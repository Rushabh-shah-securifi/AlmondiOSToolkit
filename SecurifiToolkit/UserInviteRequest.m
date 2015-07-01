//
//  UserInviteRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "UserInviteRequest.h"
#import "SFIXmlWriter.h"

@implementation UserInviteRequest
- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"UserInviteRequest"];

    [writer addElement:@"AlmondMAC" text:self.almondMAC];
    [writer addElement:@"EmailID" text:self.emailID];

    [self addMobileInternalIndexElement:writer];

    // close UserInviteRequest
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}
@end
