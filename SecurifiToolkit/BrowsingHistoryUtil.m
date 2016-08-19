//
//  BrowsingHistoryUtil.m
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 25/07/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "BrowsingHistoryUtil.h"
#import "NSDate+Convenience.h"

@implementation BrowsingHistoryUtil
+(BOOL)isTodaySearch:(NSString *)timeEpoc{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate getDateFromEpoch:timeEpoc]];
    NSDate *otherDate = [cal dateFromComponents:components];
    if([today isEqualToDate:otherDate])
        return YES;
    else
        return NO;
}

+(BOOL)searchByWeeKDay:(NSString *)timeEpoc andSearchString:(NSString *)search{
    NSDate *date = [NSDate getDateFromEpoch:timeEpoc];
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    NSLog(@"date week day %@ ",date);
    NSString *weekDay = [self stringFromWeekday:[components1 weekday]];
    NSLog(@"searchWeek Day = %@ ,%@",search ,weekDay);
    
    if([weekDay rangeOfString:search].location != NSNotFound){
       
        return YES;
    }
    else
        return NO;
}


+ (NSString *)stringFromWeekday:(NSInteger)weekday
{
    static NSString *strings[] = {
        @"Sunday",
        @"Monday",
        @"Tuesday",
        @"Wednesday",
        @"Thursday",
        @"Friday",
        @"Saturday",
    };
    
    return strings[weekday - 1];
}
+(int)getWeeKdayNumber:(NSString*)search{
    NSArray *weekDay = @[@"sunday", @"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday"];
    int count = -1;
    for (NSString *day  in weekDay) {
        count++;
        if([[day uppercaseString] rangeOfString:[search uppercaseString]].location != NSNotFound){
            return count;
        }
    }
    
}
+ (BOOL)monthDateSearch:(NSString *)timeEpoc andSearch:(NSString *)search{
    NSDate *date = [NSDate getDateFromEpoch:timeEpoc];
    NSString *day = [date getDay];
    NSString *month = [date getMonthString];
    NSLog(@"month and date %@,%@",month,day);
    if([self checkValidation:search date:day monthname:month])
        return YES;
    else
        return NO;
}

+(BOOL)checkValidation:(NSString*)search date:(NSString *)date monthname:(NSString *)monthName{
    NSArray * searchArr = [search componentsSeparatedByString:@" "];
    NSString *day;
    NSString *month;
    for(NSString *str in searchArr){
        if( [self isContainMonth:str])
        month = str;
        
        if([self isNumeric:str])
        day = str;
        
    }
    NSLog(@" month and date %@,%@",day,month);
    if ([day isEqualToString:date] && [[month uppercaseString] isEqualToString:[monthName uppercaseString]]) {
        return YES;
    }
    return NO;
}
+(NSString *)getFormateOfDate:(NSString*)search{
     NSArray * searchArr = [search componentsSeparatedByString:@" "];
    NSString *day;
    int month;
    for(NSString *str in searchArr){
        if([self isContainMonth:str]){
        month = [self getMonthNo:str];
            NSLog(@" month == %d ",month);
        }
        if([self isNumeric:str])
            day = str;
        
    }
    NSLog(@" month and date %@,%d",day,month);
    return [NSString stringWithFormat:@"%@-%d",day,month];
}
+ (BOOL)isNumeric:(NSString *)code{
    
    NSScanner *ns = [NSScanner scannerWithString:code];
    int the_value;
    if ( [ns scanInt:&the_value] )
    {
        NSLog(@"INSIDE IF %d",the_value);
        if(the_value>0 && the_value<32)
        return YES;
    }
    else {
        return  NO;
    }
}
+(BOOL)isContainMonth:(NSString*)search{
    NSArray *monthArr = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    int count = 0;
    NSLog(@"search str = %@",search);
    for (NSString *month  in monthArr) {
        count++;
        if([[search uppercaseString] rangeOfString:[month uppercaseString]].location != NSNotFound)
        {
        NSLog(@"count monthNo = %d",count);
        return YES;
        }
    }
    return  NO;
    
}
+(int)getMonthNo:(NSString*)search{
    NSArray *monthArr = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    int count = 0;
    NSLog(@"search str = %@",search);
    for (NSString *month  in monthArr) {
        count++;
        if([[search uppercaseString] rangeOfString:[month uppercaseString]].location != NSNotFound)
        {
            NSLog(@"count monthNo = %d",count);
            return count;
        }
    }
}

+(BOOL)isLastHour:(NSString*)timeEpoc{
    NSDate *currentTime = [NSDate date];
    NSMutableArray *arrObj = [[NSMutableArray alloc]init];
    NSTimeInterval nowEpochSeconds = [currentTime timeIntervalSince1970];
    NSDate *date = [NSDate getDateFromEpoch:timeEpoc];
    NSTimeInterval uriEpoch = [date timeIntervalSince1970];
    int timeDiff= nowEpochSeconds - uriEpoch;
    if(timeDiff <= 3600)
        return YES;
    else
        return  NO;

}
+(BOOL)isLastWeek:(NSString *)timeEpoc{
    NSDate *currentTime = [NSDate date];
    NSMutableArray *arrObj = [[NSMutableArray alloc]init];
    NSTimeInterval nowEpochSeconds = [currentTime timeIntervalSince1970];
    NSDate *date = [NSDate getDateFromEpoch:timeEpoc];
    NSTimeInterval uriEpoch = [date timeIntervalSince1970];
    int timeDiff= nowEpochSeconds - uriEpoch;
    if(timeDiff <= 3600 * 24 * 7)
    return YES;
    else
    return  NO;

}
+(BOOL)isWeekDay:(NSString *)timeEpoc andSearch:(NSString *)search{
    NSDate *date = [NSDate getDateFromEpoch:timeEpoc];
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    
    NSString *weekDay = [self stringFromWeekday:[components1 weekday]];
    NSLog(@"searchWeek Day = %@ ,%@",search ,weekDay);
    if([weekDay rangeOfString:search].location != NSNotFound)
        return YES;
    else
        return NO;
}
@end
