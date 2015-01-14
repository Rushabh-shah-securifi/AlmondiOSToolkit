//
//  NotificationPreferenceListRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 14/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "NotificationPreferenceListRequest.h"
#import "SFIXmlWriter.h"

@implementation NotificationPreferenceListRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"NotificationPreferenceListRequest"];

    [writer addElement:@"AlmondplusMAC" text:self.almondplusMAC];

    [self addMobileInternalIndexElement:writer];

    // close NotificationPreferenceListRequest
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}

@end
