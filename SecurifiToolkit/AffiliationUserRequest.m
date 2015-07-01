//
//  AffiliationUserResponse.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/29/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "AffiliationUserRequest.h"
#import "SFIXmlWriter.h"

@implementation AffiliationUserRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"AffiliationCodeRequest"];

    [writer addElement:@"Code" text:self.self.Code];

    // close AffiliationCodeRequest
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}


@end
