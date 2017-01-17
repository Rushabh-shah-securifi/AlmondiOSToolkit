//
// Created by Matthew Sinclair-Day on 3/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NotificationListResponse.h"
#import "SFINotification.h"
#import "MDJSON.h"


@implementation NotificationListResponse

+ (instancetype)parseNotificationsJson:(NSData *)data {
    return [self internalParseJson:data payloadPropertyName:@"notifications" parseNotification:YES];
}

+ (instancetype)parseDeviceLogsJson:(NSData *)data {
    return [self internalParseJson:data payloadPropertyName:@"logs" parseNotification:NO];
}

+ (NotificationListResponse *)internalParseJson:(NSData *)data payloadPropertyName:(NSString *)payloadPropertyName parseNotification:(BOOL)notificationPayload {
    id json = data.objectFromJSONData; //[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (![json respondsToSelector:@selector(objectForKey:)]) {
        NSLog(@"Failed parsing notification response payload, expected a dictionary, received: %@", json);
        return nil;
    }

    return [self parsePayload:json payloadPropertyName:payloadPropertyName parseNotification:notificationPayload];
}

+ (instancetype)parsePayload:(NSDictionary *)payload payloadPropertyName:(NSString *)payloadPropertyName parseNotification:(BOOL)notificationPayload {
    NSMutableArray *parsed = [NSMutableArray array];

    NSArray *ls = payload[payloadPropertyName];
    for (NSDictionary *dictionary in ls) {
        if (notificationPayload) {
            NSDictionary *msg_data = dictionary[@"msg"];

            SFINotification *n = [SFINotification parseNotificationPayload:msg_data];
            n.externalId = dictionary[@"primarykey"];

            [parsed addObject:n];
        }
        else {
            SFINotification *n = [SFINotification parseDeviceLogPayload:dictionary];

            [parsed addObject:n];
        }
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
