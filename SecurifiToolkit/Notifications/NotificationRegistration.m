//
//  NotificationRegistration.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 06/11/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "NotificationRegistration.h"
#import "SFIXmlWriter.h"

@implementation NotificationRegistration
- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"NotificationAddRegistration"];

    [writer addElement:@"RegID" text:self.regID];
    [writer addElement:@"Platform" text:self.platform];

    [self addMobileInternalIndexElement:writer];

    // close NotificationAddRegistration
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}
@end
