//
// Created by Matthew Sinclair-Day on 1/30/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
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

+ (NSDate*)getDateFromEpoch:(NSString*)epoch{
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:[epoch integerValue]];
    NSString *formattedString = [epochNSDate formattedStringUsingFormat:@"yyyy-MM-dd HH:mm:ss zzz"];//required to return converted date in the form of date.
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    return [dateFormatter dateFromString:formattedString];
}

- (NSString*)getDayString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayString = [dateFormatter stringFromDate:self];
    dayString = [dayString substringWithRange:NSMakeRange(0, 3)];
    return dayString;
}

-(NSString *)getMonthString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM"];
    NSString *monString = [dateFormatter stringFromDate:self];
    return monString;
}

-(NSString *)getDayMonthFormat{//Mon 6 June
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:self];
    NSInteger day = [components day];
    
    return [NSString stringWithFormat:@"%@ %d %@",[self getDayString], day, [self getMonthString]];
}

+ (NSDate *)convertStirngToDate:(NSString*)dateString{
//    NSString *dateString = @"2015/04/11";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    return  dateFromString;
}

- (NSString *)stringFromDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    NSString *stringDate = [dateFormatter stringFromDate:self];
    return stringDate;
}

@end