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
+(void)initializeDataBase;
+(void)insertHistoryRecord:(NSDictionary *)hDict;
+ (NSDictionary *)getAllBrowsingHistory;
+(void)insertRecordFromFile:(NSString *)fileName;
+ (NSDictionary *)getSearchString:(NSString *)searchPatten andSearchSting:(NSString *)search;
+ (NSDictionary *)getManualString:(NSString *)searchPatten andSearchSting:(NSString *)search;
@end
