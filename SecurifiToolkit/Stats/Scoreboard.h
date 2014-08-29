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

@property NSUInteger connectionCount;
@property NSUInteger connectionFailedCount;
@property NSUInteger reachabilityChangedCount;

@property NSUInteger dynamicUpdateCount;
@property NSUInteger requestCount;
@property NSUInteger responseCount;

- (id)copyWithZone:(NSZone *)zone;

- (NSString*)formattedValue:(NSUInteger)value;

@end
