//
// Created by Matthew Sinclair-Day on 1/30/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Convenience)
+ (NSDate *)today;

- (BOOL)isToday;

- (NSDate *)dateByAddingDays:(NSInteger)days;

- (NSDate *)dateAtMidnight;

- (NSDate *)dateWithoutTime;

- (NSString *)formattedDateString;

- (NSString *)formattedDateTimeString;

- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat;

- (NSString *)getDayMonthFormat;

+ (NSDate*)getDateFromEpoch:(NSString*)epoch;

+ (NSDate *)convertStirngToDate:(NSString*)dateString;

- (NSString *)stringFromDate;
@end