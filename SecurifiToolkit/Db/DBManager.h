//
//  DBManager.h
//  JSONParsingAndSqliteDataBase
//
//  Created by Masood on 17/02/16.
//  Copyright © 2016 Masood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

+(DBManager*)getSharedInstance;
- (instancetype)initDB;
-(BOOL)createDB;
-(void)updateData:(NSString*)ID indexData:(NSString*)indexData;
-(void)insertData:(NSDictionary*)deviceIndexDict;
-(NSString*)findByID:(NSString*)ID;
-(void)deleteTable;
@end
