//
// Created by Matthew Sinclair-Day on 1/30/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import "NSDate+Convenience.h"

@implementation NSDate (Convenience)

+ (NSDate *)today {
    return [[NSDate date] dateAtMidnight];
}

- (BOOL)isToday {
    NSDate *date = [self dateWithoutTime];
    NSDate *today = [NSDate today];
    return [date compare:today] == NSOrderedSame;
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:days];

    NSDate *date = [gregorian dateByAddingComponents:comps toDate:self options:0];
    return date;
}

- (NSDate *)dateByAddingHours:(NSInteger)hours {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:hours];

    NSDate *date = [gregorian dateByAddingComponents:comps toDate:self options:0];
    return date;
}

- (NSDate *)dateAtMidnight {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    return [gregorian dateFromComponents:dateComponents];
}

- (NSDate *)dateWithoutTime {
    NSString *formattedString = [self formattedDateString];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    NSDate *ret = [formatter dateFromString:formattedString];
    return ret;
}

- (int)differenceInDaysTo:(NSDate *)toDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                fromDate:self
                                                  toDate:toDate
                                                 options:0];
    NSInteger days = [components day];
    return (int) days;
}

- (NSString *)formattedDateString {
    return [self formattedStringUsingFormat:@"MMM dd, yyyy"];
}

- (NSString *)formattedDateTimeString {
    return [self formattedStringUsingFormat:@"MMM dd, yyyy hh:mm:ss"];
}

- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}

@end