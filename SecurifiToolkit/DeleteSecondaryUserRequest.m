//
//  DeleteSecondaryUserRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "DeleteSecondaryUserRequest.h"
#import "SFIXmlWriter.h"

@implementation DeleteSecondaryUserRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"DeleteSecondaryUserRequest"];

    [writer element:@"AlmondMAC" text:self.almondMAC];
    [writer element:@"EmailID" text:self.emailID];

    [self writeMobileInternalIndexElement:writer];

    // close DeleteSecondaryUserRequest
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}
@end
