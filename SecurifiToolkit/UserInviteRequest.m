//
//  UserInviteRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "UserInviteRequest.h"
#import "XMLWriter.h"

@implementation UserInviteRequest
- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"UserInviteRequest"];

    [writer writeStartElement:@"AlmondMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];

    [writer writeStartElement:@"EmailID"];
    [writer writeCharacters:self.emailID];
    [writer writeEndElement];

    [self writeMobileInternalIndexElement:writer];

    // close UserInviteRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];

    return writer.toString;
}
@end
