//
// Created by Matthew Sinclair-Day on 5/4/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NotificationClearCountResponse.h"


@implementation NotificationClearCountResponse

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
    NotificationClearCountResponse *obj = [NotificationClearCountResponse new];

    NSNumber *code = payload[@"ok"];
    if (code) {
        BOOL ok = (code.intValue == 1);
        obj->_error = !ok;
    }
    else {
        obj->_error = YES;
        code = payload[@"error"];
        if (code) {
            NSLog(@"Clear Count Response: error, code=%@", code);
        }
    }

    return obj;
}

@end