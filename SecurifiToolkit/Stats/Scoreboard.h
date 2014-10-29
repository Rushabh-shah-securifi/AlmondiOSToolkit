//
//  Scoreboard.h
//  SecurifiToolkit
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScoreboardEvent<NSObject>
- (NSString*)label;
@end

@interface Scoreboard : NSObject <NSCopying>

@property (nonatomic, readonly) NSDate *created;

@property NSUInteger routerRebootCount;
@property NSUInteger loginCount;
@property NSUInteger affiliationCount;
@property NSUInteger signUpPageCount;

// Number of connection establishments made
@property NSUInteger connectionCount;

// Number of connection failures; does not count normal shutdowns
@property NSUInteger connectionFailedCount;

// Number of events from the Reachability manager
@property NSUInteger reachabilityChangedCount;

// Number of dynamic updates across all connections
@property NSUInteger dynamicUpdateCount;

// Number of commands sent to the cloud
@property NSUInteger commandRequestCount;

// Number of responses received for commands sent to the cloud
@property NSUInteger commandResponseCount;

- (NSString*)formattedValue:(NSUInteger)value;

- (void)markEvent:(id<ScoreboardEvent>)event;

- (NSUInteger)allEventsCount;

- (NSArray*)allEvents;

- (id)copyWithZone:(NSZone *)zone;

@end

