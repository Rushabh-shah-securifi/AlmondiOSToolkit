//
//  Scoreboard.m
//  SecurifiToolkit
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "Scoreboard.h"

@implementation Scoreboard

- (id)init {
    self = [super init];
    if (self) {
        _created = [NSDate date];
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Scoreboard *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.routerRebootCount = self.routerRebootCount;
        copy.loginCount = self.loginCount;
        copy.affiliationCount = self.affiliationCount;
        copy.signUpPageCount = self.signUpPageCount;
        copy.connectionCount = self.connectionCount;
        copy.connectionFailedCount = self.connectionFailedCount;
        copy.reachabilityChangedCount = self.reachabilityChangedCount;
        copy.dynamicUpdateCount = self.dynamicUpdateCount;
        copy.commandRequestCount = self.commandRequestCount;
        copy.commandResponseCount = self.commandResponseCount;
    }

    return copy;
}

- (NSString *)formattedValue:(NSUInteger)value {
    return [NSString stringWithFormat:@"%lu", (unsigned long) value];
}


@end
