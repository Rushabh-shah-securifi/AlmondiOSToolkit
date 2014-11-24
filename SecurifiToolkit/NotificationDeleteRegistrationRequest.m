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

    [writer addElement:@"RegID" text:self.regID];
    [writer addElement:@"Platform" text:self.platform];

    [self addMobileInternalIndexElement:writer];

    // close NotificationDeleteRegistrationRequest
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}
@end
