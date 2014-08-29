//
//  Scoreboard.h
//  SecurifiToolkit
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
We need to capture Timing of Sensor On/Off, how many times Router Reboot is
hit, Track sensor, login , affiliation and Router, Sign up page hits.
 */


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

- (id)copyWithZone:(NSZone *)zone;

- (NSString*)formattedValue:(NSUInteger)value;

@end
