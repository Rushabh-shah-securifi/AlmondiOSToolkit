//
//  NotificationDeleteRegistrationRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 07/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "NotificationDeleteRegistrationRequest.h"
#import "SFIXmlWriter.h"

@implementation NotificationDeleteRegistrationRequest
- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"NotificationDeleteRegistrationRequest"];

    [writer element:@"RegID" text:self.regID];
    [writer element:@"Platform" text:self.platform];

    [self writeMobileInternalIndexElement:writer];

    // close NotificationDeleteRegistrationRequest
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}
@end
