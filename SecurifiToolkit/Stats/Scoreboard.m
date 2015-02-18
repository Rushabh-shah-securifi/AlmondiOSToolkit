//
//  Scoreboard.m
//  SecurifiToolkit
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "Scoreboard.h"

@interface Scoreboard ()
@property(nonatomic, readonly) NSMutableArray *events;
@property(nonatomic, readonly) NSObject *events_locker;
@end

@implementation Scoreboard

- (id)init {
    self = [super init];
    if (self) {
        _created = [NSDate date];
        _events = [NSMutableArray array];
        _events_locker = [NSObject new];
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Scoreboard *copy = (Scoreboard *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy->_created = _created;
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

        @synchronized (self.events_locker) {
            [copy->_events addObjectsFromArray:self.events];
        }
    }

    return copy;
}


- (NSString *)formattedValue:(NSUInteger)value {
    return [NSString stringWithFormat:@"%lu", (unsigned long) value];
}

- (void)markEvent:(id<ScoreboardEvent>)event {
    @synchronized (self.events_locker) {
        [self.events addObject:event];
    }
}

- (NSUInteger)allEventsCount {
    @synchronized (self.events_locker) {
        return [self.events count];
    }
}

- (NSArray *)allEvents {
    @synchronized (self.events_locker) {
        return [NSArray arrayWithArray:self.events];
    }
}

@end
