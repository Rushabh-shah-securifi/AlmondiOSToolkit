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
- (instancetype)initDB;
- (void)deleteTable;

-(NSArray*)getDevicesForIds:(NSArray*)deviceIds;
-(NSArray*)getDeviceIndexesForIds:(NSArray*)indexIds;
@end
