//
// Created by Matthew Sinclair-Day on 1/23/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import "SFINotification.h"
#import "SFIDeviceKnownValues.h"


@implementation SFINotification

/*
mac             => mac
users           => users
time            => time
data            => data
DevID           => deviceid
devicename      => devicename
devicetype      => devicetype
Index           => index
IndexName       => indexname
Value           => indexvalue
 */

+ (instancetype)parseJson:(NSData *)data {
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"Failed parsing notification payload, error:%@, payload:%@", error, data);
        return nil;
    }
    if (![json respondsToSelector:@selector(objectForKey:)]) {
        NSLog(@"Failed parsing notification payload, expected a dictionary, recevied: %@", json);
        return nil;
    }

    return [self parsePayload:json];
}

+ (instancetype)parsePayload:(NSDictionary *)payload {
    SFINotification *obj = [SFINotification new];
    obj.almondMAC = payload[@"mac"];

    NSString *str;

    obj.externalId = payload[@"id"];

    str = payload[@"time"];
    obj.time = str.longLongValue;

    str = payload[@"deviceid"];
    obj.deviceId = (sfi_id) str.longLongValue;

    obj.deviceName = payload[@"devicename"];

    str = payload[@"devicetype"];
    obj.deviceType = (SFIDeviceType) str.intValue;

    str = payload[@"index"];
    obj.valueIndex = (sfi_id) str.longLongValue;

    obj.valueType = [SFIDeviceKnownValues nameToPropertyType:payload[@"indexname"]];
    obj.value = payload[@"indexvalue"];

    // protect against errant or missing values in payload
    id counter = payload[@"counter"];
    if (counter) {
        @try {
            NSNumber *num = counter;
            obj.debugCounter = num.longValue;
        }
        @catch (NSException *e) {
            NSLog(@"Exception while parsing debug counter, value:'%@', e:%@", counter, e.description);
        }
    }

    return obj;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.notificationId = [coder decodeIntForKey:@"self.notificationId"];
        self.externalId = [coder decodeObjectForKey:@"self.externalId"];
        self.almondMAC = [coder decodeObjectForKey:@"self.almondMAC"];
        self.time = [coder decodeDoubleForKey:@"self.time"];
        self.deviceName = [coder decodeObjectForKey:@"self.deviceName"];
        self.deviceId = (sfi_id) [coder decodeInt64ForKey:@"self.deviceId"];
        self.deviceType = (SFIDeviceType) [coder decodeIntForKey:@"self.deviceType"];
        self.valueIndex = (sfi_id) [coder decodeInt64ForKey:@"self.valueIndex"];
        self.valueType = (SFIDevicePropertyType) [coder decodeIntForKey:@"self.valueType"];
        self.value = [coder decodeObjectForKey:@"self.value"];
        self.viewed = [coder decodeBoolForKey:@"self.viewed"];
        self.debugCounter = [coder decodeIntForKey:@"self.debugCounter"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.notificationId forKey:@"self.notificationId"];
    [coder encodeObject:self.externalId forKey:@"self.externalId"];
    [coder encodeObject:self.almondMAC forKey:@"self.almondMAC"];
    [coder encodeDouble:self.time forKey:@"self.time"];
    [coder encodeObject:self.deviceName forKey:@"self.deviceName"];
    [coder encodeInt64:self.deviceId forKey:@"self.deviceId"];
    [coder encodeInt:self.deviceType forKey:@"self.deviceType"];
    [coder encodeInt64:self.valueIndex forKey:@"self.valueIndex"];
    [coder encodeInt:self.valueType forKey:@"self.valueType"];
    [coder encodeObject:self.value forKey:@"self.value"];
    [coder encodeBool:self.viewed forKey:@"self.viewed"];
    [coder encodeInt:self.debugCounter forKey:@"self.debugCounter"];
}

- (id)copyWithZone:(NSZone *)zone {
    SFINotification *copy = (SFINotification *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.notificationId = self.notificationId;
        copy.externalId = self.externalId;
        copy.almondMAC = self.almondMAC;
        copy.time = self.time;
        copy.deviceName = self.deviceName;
        copy.deviceId = self.deviceId;
        copy.deviceType = self.deviceType;
        copy.valueIndex = self.valueIndex;
        copy.valueType = self.valueType;
        copy.value = self.value;
        copy.viewed = self.viewed;
        copy.debugCounter = self.debugCounter;
    }

    return copy;
}


- (void)setDebugDeviceName {
    long counter = self.debugCounter;
    if (counter == 0) {
        return;
    }
    self.deviceName = [NSString stringWithFormat:@"%@-%li", self.deviceName, counter];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.notificationId=%li", self.notificationId];
    [description appendFormat:@", self.externalId=%@", self.externalId];
    [description appendFormat:@", self.almondMAC=%@", self.almondMAC];
    [description appendFormat:@", self.time=%f", self.time];
    [description appendFormat:@", self.deviceName=%@", self.deviceName];
    [description appendFormat:@", self.deviceId=%u", self.deviceId];
    [description appendFormat:@", self.deviceType=%d", self.deviceType];
    [description appendFormat:@", self.valueIndex=%u", self.valueIndex];
    [description appendFormat:@", self.valueType=%d", self.valueType];
    [description appendFormat:@", self.value=%@", self.value];
    [description appendFormat:@", self.viewed=%d", self.viewed];
    [description appendFormat:@", self.debugCounter=%li", self.debugCounter];
    [description appendString:@">"];
    return description;
}


@end