//
// Created by Matthew Sinclair-Day on 3/25/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NotificationCountResponse.h"


@implementation NotificationCountResponse

+ (instancetype)parseJson:(NSData *)data {
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"Failed parsing notification response payload, error:%@, payload:%@", error, data);
        return nil;
    }
    if (![json respondsToSelector:@selector(objectForKey:)]) {
        NSLog(@"Failed parsing notification response payload, expected a dictionary, received: %@", json);
        return nil;
    }

    return [self parsePayload:json];
}

+ (instancetype)parsePayload:(NSDictionary *)payload {
    NotificationCountResponse *obj = [NotificationCountResponse new];

    NSNumber *error = payload[@"error"];
    if (error && error.integerValue != 0) {
        obj->_error = YES;
        obj->_badgeCount = 0;
    }
    else {
        obj->_error = NO;
        NSNumber *badge = payload[@"badge"];
        obj->_badgeCount = badge.integerValue;
    }

    return obj;
}


@end