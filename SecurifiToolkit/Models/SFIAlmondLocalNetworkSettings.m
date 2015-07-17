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
        self.ssid2 = [coder decodeObjectForKey:@"self.ssid2"];
        self.ssid5 = [coder decodeObjectForKey:@"self.ssid5"];
        self.almondplusMAC = [coder decodeObjectForKey:@"self.almondplusMAC"];
        self.host = [coder decodeObjectForKey:@"self.host"];
        self.port = (NSUInteger) [coder decodeInt64ForKey:@"self.port"];
        self.login = [coder decodeObjectForKey:@"self.login"];
        self.password = [coder decodeObjectForKey:@"self.password"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.enabled forKey:@"self.enabled"];
    [coder encodeObject:self.ssid2 forKey:@"self.ssid2"];
    [coder encodeObject:self.ssid5 forKey:@"self.ssid5"];
    [coder encodeObject:self.almondplusMAC forKey:@"self.almondplusMAC"];
    [coder encodeObject:self.host forKey:@"self.host"];
    [coder encodeInt64:self.port forKey:@"self.port"];
    [coder encodeObject:self.login forKey:@"self.login"];
    [coder encodeObject:self.password forKey:@"self.password"];
}

- (id)copyWithZone:(NSZone *)zone {
    SFIAlmondLocalNetworkSettings *copy = (SFIAlmondLocalNetworkSettings *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.enabled = self.enabled;
        copy.ssid2 = self.ssid2;
        copy.ssid5 = self.ssid5;
        copy.almondplusMAC = self.almondplusMAC;
        copy.host = self.host;
        copy.port = self.port;
        copy.login = self.login;
        copy.password = self.password;
    }

    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }

    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    return [self isEqualToSettings:other];
}

- (BOOL)isEqualToSettings:(SFIAlmondLocalNetworkSettings *)settings {
    if (self == settings)
        return YES;
    if (settings == nil)
        return NO;
    if (self.enabled != settings.enabled)
        return NO;
    if (self.ssid2 != settings.ssid2 && ![self.ssid2 isEqualToString:settings.ssid2])
        return NO;
    if (self.ssid5 != settings.ssid5 && ![self.ssid5 isEqualToString:settings.ssid5])
        return NO;
    if (self.almondplusMAC != settings.almondplusMAC && ![self.almondplusMAC isEqualToString:settings.almondplusMAC])
        return NO;
    if (self.host != settings.host && ![self.host isEqualToString:settings.host])
        return NO;
    if (self.port != settings.port)
        return NO;
    if (self.login != settings.login && ![self.login isEqualToString:settings.login])
        return NO;
    if (self.password != settings.password && ![self.password isEqualToString:settings.password])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = (NSUInteger) self.enabled;
    hash = hash * 31u + [self.ssid2 hash];
    hash = hash * 31u + [self.ssid5 hash];
    hash = hash * 31u + [self.almondplusMAC hash];
    hash = hash * 31u + [self.host hash];
    hash = hash * 31u + self.port;
    hash = hash * 31u + [self.login hash];
    hash = hash * 31u + [self.password hash];
    return hash;
}


@end