//
//  DataBaseManager.h
//  JSONParsingAndSqliteDataBase
//
//  Created by Masood on 17/02/16.
//  Copyright © 2016 Masood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBaseManager : NSObject

//+(DBManager*)getSharedInstance;
+(void)initializeDataBase;

+ (NSMutableDictionary*)getDevicesForIds:(NSArray*)deviceIds;
+ (NSMutableDictionary*)getDeviceIndexesForIds:(NSArray*)indexIds;
+ (NSMutableDictionary*)getHistory:(NSArray *)dateArr;
+ (void)InsertRecords:(NSDictionary *)dict;
+ (NSDictionary *)getHistoryData;
+ (void)deleteHistoryTable;
+ (void)updateDB:(NSString *)date with:(NSDictionary *)dict;

@end
