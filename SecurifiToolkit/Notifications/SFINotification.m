//
// Created by Matthew Sinclair-Day on 1/23/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import "SFINotification.h"


@implementation SFINotification

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.time = [coder decodeDoubleForKey:@"self.time"];
        self.deviceId = (sfi_id) [coder decodeInt64ForKey:@"self.deviceId"];
        self.deviceName = [coder decodeObjectForKey:@"self.deviceName"];
        self.deviceType = (SFIDeviceType) [coder decodeIntForKey:@"self.deviceType"];
        self.valueIndex = (sfi_id) [coder decodeInt64ForKey:@"self.valueIndex"];
        self.valueType = (SFIDevicePropertyType) [coder decodeIntForKey:@"self.valueType"];
        self.value = [coder decodeObjectForKey:@"self.value"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.time forKey:@"self.time"];
    [coder encodeInt64:self.deviceId forKey:@"self.deviceId"];
    [coder encodeObject:self.deviceName forKey:@"self.deviceName"];
    [coder encodeInt:self.deviceType forKey:@"self.deviceType"];
    [coder encodeInt64:self.valueIndex forKey:@"self.valueIndex"];
    [coder encodeInt:self.valueType forKey:@"self.valueType"];
    [coder encodeObject:self.value forKey:@"self.value"];
}

- (id)copyWithZone:(NSZone *)zone {
    SFINotification *copy = (SFINotification *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.time = self.time;
        copy.deviceId = self.deviceId;
        copy.deviceName = self.deviceName;
        copy.deviceType = self.deviceType;
        copy.valueIndex = self.valueIndex;
        copy.valueType = self.valueType;
        copy.value = self.value;
    }

    return copy;
}


@end