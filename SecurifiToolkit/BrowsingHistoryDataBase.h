//
//  BrowsingHistoryDataBase.h
//  JSONParsingAndSqliteDataBase
//
//  Created by Masood on 17/02/16.
//  Copyright © 2016 Masood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrowsingHistoryDataBase : NSObject

//+(DBManager*)getSharedInstance;
+ (void)initializeDataBase;
+ (NSString *)insertHistoryRecord:(NSDictionary *)hDict;
+ (NSDictionary *)getAllBrowsingHistorywithLimit:(int )limit;
+ (void)insertRecordFromFile:(NSString *)fileName;
+ (NSDictionary *)getSearchString:(NSString *)search;

+ (NSDictionary *)getManualString:(NSString *)searchPatten andSearchSting:(NSString *)search;
+ (int)GetHistoryDatabaseCount;
+ (NSString *)getStartTag;
+ (NSString *)getEndTag;
+ (void)deleteDB;
+ (void)deleteOldEntries;
+ (NSDictionary *)todaySearch;
+ (NSDictionary* )LastHourSearch;
+ (NSDictionary* )ThisWeekSearch;
+(NSDictionary* )DaySearch:(NSString *)search;
+(NSDictionary* )weekDaySearch:(NSString *)search;
+ (NSString *)getTodayDate;
+(NSDictionary *)searchBYCategoty:(NSString*)search;
+(NSString *)getPageState;


@end
