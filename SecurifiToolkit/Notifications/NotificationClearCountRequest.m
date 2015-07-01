//
// Created by Matthew Sinclair-Day on 5/4/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NotificationClearCountRequest.h"
#import "SFIXmlWriter.h"


@implementation NotificationClearCountRequest

- (CommandType)commandType {
    return CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST;
}

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    [writer addElement:@"root" text:@""]; // must be <root></root> otherwise the cloud will reject; cannot be <root/>
    return writer.toString;
}

@end