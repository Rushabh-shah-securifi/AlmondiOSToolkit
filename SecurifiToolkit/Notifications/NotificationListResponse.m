//
// Created by Matthew Sinclair-Day on 3/23/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import "NotificationListResponse.h"
#import "SFINotification.h"


@implementation NotificationListResponse

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
    NSMutableArray *parsed = [NSMutableArray array];

    NSArray *ls = payload[@"notifications"];
    for (NSDictionary *dictionary in ls) {
        NSDictionary *msg_data = dictionary[@"msg"];
        SFINotification *n = [SFINotification parsePayload:msg_data];
        n.externalId = dictionary[@"primarykey"];

        [parsed addObject:n];
    }

    NotificationListResponse *obj = [NotificationListResponse new];
    obj->_pageState = payload[@"pageState"];
    obj->_requestId = payload[@"requestId"];

    NSString *num = payload[@"badgeCount"];
    if (num) {
        obj->_newCount = (NSUInteger) num.integerValue;
    }

    obj->_notifications = parsed;

    return obj;
}

- (BOOL)isPageStateDefined {
    NSString *state = self.pageState;
    if (state.length == 0) {
        return NO;
    }
    return ![state isEqualToString:@"undefined"];
}

@end