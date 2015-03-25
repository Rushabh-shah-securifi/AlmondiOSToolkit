//
// Created by Matthew Sinclair-Day on 3/25/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NotificationCountRequest.h"
#import "SFIXmlWriter.h"

@implementation NotificationCountRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    [writer addElement:@"root" text:@""]; // must be <root></root> otherwise the cloud will reject; cannot be <root/>
    return writer.toString;
}

@end