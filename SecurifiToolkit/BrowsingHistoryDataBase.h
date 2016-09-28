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
+ (NSDictionary *)insertHistoryRecord:(NSDictionary *)hDict;

+ (NSDictionary *)getAllBrowsingHistorywithLimit:(int)limit almonsMac:(NSString *)amac clientMac:(NSString *)cmac;

+ (void)insertRecordFromFile:(NSString *)fileName;

+ (NSDictionary *)getSearchString:(NSString *)search almonsMac:(NSString *)amac clientMac:(NSString *)cmac;

+ (NSDictionary *)getManualString:(NSString *)searchPatten andSearchSting:(NSString *)search;

+(int)GetHistoryDatabaseCount:(NSString *)amac clientMac:(NSString *)cmac;

+(NSString *)getStartTag:(NSString *)amac clientMac:(NSString *)cmac;

+(NSString *)getEndTag:(NSString *)amac clientMac:(NSString *)cmac;

+(void)deleteDB:(NSString *)amac clientMac:(NSString *)cmac;

+(void)deleteOldEntries:(NSString *)amac clientMac:(NSString *)cmac date:(NSString *)date;

+(NSDictionary* )todaySearch:(NSString *)amac clientMac:(NSString *)cmac;

+(NSDictionary* )LastHourSearch:(NSString *)amac clientMac:(NSString *)cmac;

+(NSDictionary* )ThisWeekSearch:(NSString *)amac clientMac:(NSString *)cmac;

+(NSDictionary* )DaySearch:(NSString *)search almonsMac:(NSString *)amac clientMac:(NSString *)cmac;

+(NSDictionary* )weekDaySearch:(NSString *)search almonsMac:(NSString *)amac clientMac:(NSString *)cmac;

+ (NSString *)getTodayDate;

+(NSDictionary *)searchBYCategoty:(NSString*)search almonsMac:(NSString *)amac clientMac:(NSString *)cmac;

+(NSString *)getPageState:(NSString *)amac clientMac:(NSString *)cmac;

+(NSString *)getLastDate:(NSString *)amac clientMac:(NSString *)cmac;

@end
