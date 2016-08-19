//
//  BrowsingHistoryUtil.h
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 25/07/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrowsingHistoryUtil : NSObject
+ (BOOL)isTodaySearch:(NSString *)timeEpoc;
+ (BOOL)searchByWeeKDay:(NSString *)timeEpoc andSearchString:(NSString *)search;
+ (BOOL)monthDateSearch:(NSString *)timeEpoc andSearch:(NSString *)search;
+ (BOOL)isLastWeek:(NSString *)timeEpoc;
+ (BOOL)isLastHour:(NSString*)timeEpoc;
+(BOOL)isContainMonth:(NSString*)search;
+(BOOL)checkValidation:(NSString*)search date:(NSString *)date monthname:(NSString *)monthName;
+(NSString *)getFormateOfDate:(NSString*)search;
+(int)getWeeKdayNumber:(NSString*)search;
@end
