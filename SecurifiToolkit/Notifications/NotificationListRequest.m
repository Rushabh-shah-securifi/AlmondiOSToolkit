//
// Created by Matthew Sinclair-Day on 3/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NotificationListRequest.h"
#import "SFIXmlWriter.h"

@implementation NotificationListRequest


- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];

    [writer addElement:@"PageState" text:self.pageState];
    [writer addElement:@"RequestId" text:self.requestId];

    [writer endElement];

    return writer.toString;
}

@end