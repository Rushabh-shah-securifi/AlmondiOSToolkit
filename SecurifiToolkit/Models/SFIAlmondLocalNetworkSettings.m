//
// Created by Matthew Sinclair-Day on 6/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIAlmondLocalNetworkSettings.h"


@implementation SFIAlmondLocalNetworkSettings

- (instancetype)init {
    self = [super init];
    if (self) {
        self.port = 7681; // default web socket port
    }

    return self;
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.enabled = [coder decodeBoolForKey:@"self.enabled"];
        self.almondplusMAC = [coder decodeObjectForKey:@"self.almondplusMAC"];
        self.host = [coder decodeObjectForKey:@"self.host"];
        self.port = (NSUInteger) [coder decodeInt64ForKey:@"self.port"];
        self.password = [coder decodeObjectForKey:@"self.password"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.enabled forKey:@"self.enabled"];
    [coder encodeObject:self.almondplusMAC forKey:@"self.almondplusMAC"];
    [coder encodeObject:self.host forKey:@"self.host"];
    [coder encodeInt64:self.port forKey:@"self.port"];
    [coder encodeObject:self.password forKey:@"self.password"];
}

- (id)copyWithZone:(NSZone *)zone {
    SFIAlmondLocalNetworkSettings *copy = (SFIAlmondLocalNetworkSettings *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.enabled = self.enabled;
        copy.almondplusMAC = self.almondplusMAC;
        copy.host = self.host;
        copy.port = self.port;
        copy.password = self.password;
    }

    return copy;
}


@end