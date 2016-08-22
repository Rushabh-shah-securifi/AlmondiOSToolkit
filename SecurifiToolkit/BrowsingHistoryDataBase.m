//
//  DataBaseManager.m
//  JSONParsingAndSqliteDataBase
//
//  Created by Masood on 17/02/16.
//  Copyright © 2016 Masood. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BrowsingHistoryDataBase.h"
#import "BrowsingHistoryUtil.h"
#import "NSDate+Convenience.h"

#import <sqlite3.h>


#define DATABASE_FILE @"BrowsingHistory.db"
#define HISTORYTABLE @"HistoryTB"

@interface BrowsingHistoryDataBase()

@end

@implementation BrowsingHistoryDataBase
static NSString *databasePath;
static BrowsingHistoryDataBase *dbSharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3 *DB = nil;

#pragma mark initializeMethods
+(void)initializeDataBase{
    [self createDataBasePath:DATABASE_FILE];
    [self setHistoryTable];
}

+(void)createDataBasePath:(NSString*)dbPath{
    ////NSLog(@"createDataBasePath");
    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: dbPath]];
   
}


+(void)setHistoryTable{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        [self createTable:@"CREATE TABLE IF NOT EXISTS HistoryTB (DATE TEXT,UNIQUEKEY TEXT,AMAC TEXT,CMAC TEXT, URIS TEXT,COUNT TEXT,TIME INTEGER,ENDIDENTIFIER TEXT)"];
    }
}


+(BOOL)createTable:(NSString*)query{
    BOOL isSuccess = YES;
    NSLog(@"create table %@",query);
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = [query UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
            isSuccess = NO;
            NSLog(@"Failed to create table  %s",errMsg);
        }
        NSLog(@"created successfully");
        sqlite3_close(database);
        return  isSuccess;
    }
    else {
        isSuccess = NO;
        NSLog(@"Failed to open/create database");
    }
    return isSuccess;
}


+(NSDictionary*)parseJson:(NSString*)fileName{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                         options:kNilOptions
                                                           error:&error];
    
    if (error != nil) {
        //NSLog(@"Error: was not able to load json file: %@.",fileName);
    }
    return data;
}
#pragma mark getBrowsingHistoryMethods
+ (NSDictionary *)getAllBrowsingHistory{
    [BrowsingHistoryUtil getFormateOfDate:@"10 august 2016"];
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84"];
        sqlite3_stmt *compiledStatement;
        
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement];
        //NSLog(@"search ddict %@",dict);
        return dict;
    }
    
}

+ (NSDictionary *)prepareMethod:(sqlite3_stmt *)compiledStatement andsqlStatement:(NSString *)sqlStatement{
    NSLog(@"prepare method Querie: = %s",[sqlStatement UTF8String]);
    NSMutableDictionary *clientBrowsingHistory = [[NSMutableDictionary alloc]init];
    if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK){
        if (sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            NSString *uriString3 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 3)];
            
            NSString *uriString2 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 2)];
            [clientBrowsingHistory setValue:uriString2 forKey:@"clientMac"];
            [clientBrowsingHistory setValue:uriString3 forKey:@"almondMac"];
            
            
        }
        else
             NSLog(@"step fail 1");
        NSMutableDictionary *dayDict = [NSMutableDictionary new];
        //NSLog(@"success msg %s",sqlite3_errmsg(database));
        while (sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            NSString *uriString0 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 0)];
            
            NSString *uriString1 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 1)];
            
            
            NSString *uriString4 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 4)];
            //NSLog(@"uriString4 %@",uriString4);
            NSString *uriString5 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 5)];
            //NSLog(@"uriString5 %@",uriString5);
//            NSString *uriString6 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 6)];
             int field1 =  sqlite3_column_int(compiledStatement, 6);
            NSString *uriString6 = [NSString stringWithFormat:@"%d",field1];
//            NSDictionary *uriInfo = @{@"hostName":uriString4,
//                                      @"Epoc":uriString6,
//                                      @"count":uriString5
//                                      };
            NSMutableDictionary *uriInfo = [NSMutableDictionary new];
            [uriInfo setObject:uriString4 forKey:@"hostName"];
            [uriInfo setObject:uriString6 forKey:@"Epoc"];
            [uriInfo setObject:uriString5 forKey:@"count"];
            [uriInfo setObject:[UIImage imageNamed:@"help-icon" ] forKey:@"image"];
            

        [self addToDictionary:dayDict uriInfo:uriInfo rowID:uriString0];
        }
        [clientBrowsingHistory setObject:dayDict forKey:@"Data"];
        
    }
    else{
        NSLog(@"prepare errMSg %s",sqlite3_errmsg(database));
    }
    sqlite3_step(compiledStatement);
    sqlite3_finalize(compiledStatement);

    sqlite3_close(database);
    return clientBrowsingHistory;
}

+ (void)addToDictionary:(NSMutableDictionary *)rowIndexValDict uriInfo:(NSMutableDictionary *)uriInfo rowID:(NSString *)day{
    NSMutableArray *augArray = [rowIndexValDict valueForKey:[NSString stringWithFormat:@"%@",day]];
    if(augArray != nil){
        [augArray addObject:uriInfo];
        [rowIndexValDict setValue:augArray forKey:[NSString stringWithFormat:@"%@",day]];
    }else{
        NSMutableArray *tempArray = [NSMutableArray new];
        [tempArray addObject:uriInfo];
        [rowIndexValDict setValue:tempArray forKey:[NSString stringWithFormat:@"%@",day]];
    }
}
+(void)insertRecordFromFile:(NSString *)fileName{
    NSDictionary *dict = [self parseJson:fileName];
    [self insertHistoryRecord:dict];
}

#pragma mark insertMethods
+(NSString *)insertHistoryRecord:(NSDictionary *)hDict{
    NSString *query = @"INSERT OR REPLACE INTO HistoryTB (DATE,UNIQUEKEY,AMAC,CMAC, URIS,COUNT,TIME) VALUES(?,?,?,?,?,?,?)";
    [self setHistoryTable];
    return [self insertHistoryEntries:hDict query:query];
//    [self updateEndIdentifier:@""];
}
+ (NSString *)insertHistoryEntries:(NSDictionary *)hDict query:(NSString *)query{
    sqlite3_stmt *statement;
    NSString *endtag;
    
    //NSLog(@"dict = %@",hDict);
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *insert_stmt = [query UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        NSArray *allObj = hDict[@"Data"];
        
        ////NSLog(@"allDate %@",allDate);
        for(NSDictionary *uriDict in allObj)
        {
//            NSString *date = dayDict[@"Date"];
//            NSArray *uriArr = dayDict[@"URIs"];
//            for(NSDictionary *uriObj in uriArr)
//                {
                    ////NSLog(@"uriObj %@",uriObj);
                    NSString *str = @"-2";
                    sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
                    ////NSLog(@"fail to sqlite3_prepare_v2 %s",sqlite3_errmsg(database));
                    sqlite3_bind_text(statement, 1, [uriDict[@"Date"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 2, [str UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 3, [hDict[@"AlmondMAC"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 4, [hDict[@"ClientMAC"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 5, [uriDict[@"Domain"] UTF8String], -1, SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(statement, 6, [[NSString stringWithFormat:@"%@",uriDict[@"Count"]] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_int(statement, 7, [[NSString stringWithFormat:@"%@",uriDict[@"LastVisitedEpoch"]] integerValue]);
//                    sqlite3_bind_text(statement, 7, [[NSString stringWithFormat:@"%@",uriDict[@"LastVisitedEpoch"]] UTF8String], -1, SQLITE_TRANSIENT);
                    if (sqlite3_step(statement) == SQLITE_DONE){
                        //NSLog(@" successS");
                    }
                    else {
                        //NSLog(@" errorSS");
                    }
//                }
            endtag = uriDict[@"LastVisitedEpoch"];
            //NSLog(@"LastVisitedEpoch == %@",endtag);
        }

        sqlite3_close(database);
    }
    else{
        //NSLog(@"fail to open %s",sqlite3_errmsg(database));
    }
    return  endtag;
}
#pragma mark update_count_deleteMethods
+(void)updateEndIdentifier:(NSString *)endIdntifier{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {

    sqlite3_stmt *statement;
    const char *insert_stmt = "UPDATE HistoryTB SET ENDIDENTIFIER = ? WHERE AMAC = ? AND CMAC = ?";
    if (sqlite3_prepare_v2(database, insert_stmt, -1, &statement, nil)
        == SQLITE_OK)
    {
        {
            sqlite3_bind_text(statement, 1, [@"1468493266" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [@"251176215905264" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [@"14:30:c6:46:b7:15" UTF8String], -1, SQLITE_TRANSIENT);
        }
        NSLog(@"error: %s", sqlite3_errmsg(database));
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            NSLog(@"error on updating ens identifier: %s", sqlite3_errmsg(database));
        }
        else
        {
            NSLog(@"updateContact SUCCESS - executed command ");
        }
//        sqlite3_reset(statement);
//        sqlite3_step(statement);
        sqlite3_finalize(statement);
        
        // sqlite3_finalize(statement);
    }
    else
    NSLog(@"error: %s", sqlite3_errmsg(database));
    }
}
+(NSString *)getStartTag{
    int max = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT MAX(TIME) from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84"];
        
        sqlite3_stmt *statement;
        //NSLog(@"count statment  %s",[sqlcountStat UTF8String]);
        if( sqlite3_prepare_v2(database, [sqlcountStat UTF8String],-1, &statement, NULL)== SQLITE_OK)
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                
                max = sqlite3_column_int(statement, 0);
                NSLog(@"database max db= %d",max);
                
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    else{
        NSLog(@"error while opening database file");
    }
    return [NSString stringWithFormat:@"%d",max];
}
+(int)GetHistoryDatabaseCount{
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT COUNT(*) from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84"];
        //        const char* sqlcountStat = "SELECT COUNT(*) FROM HistoryTB WHERE AMAC = ? AND CMAC = ?";
        sqlite3_stmt *statement;
        //NSLog(@"count statment  %s",[sqlcountStat UTF8String]);
        if( sqlite3_prepare_v2(database, [sqlcountStat UTF8String],-1, &statement, NULL)== SQLITE_OK)
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                
                count = sqlite3_column_int(statement, 0);
                
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    else{
        //NSLog(@"error whilw opening database file");
    }
 
    return count;
}
+(void)deleteOldEntries{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSLog(@"database path %s",dbpath);
        sqlite3_stmt *statement;
        NSString *delStatmrnt = [NSString stringWithFormat:@"DELETE FROM HistoryTB WHERE TIME IN(SELECT TIME FROM HistoryTB order by TIME ASC limit 50)"];
        if (sqlite3_prepare_v2(database, [delStatmrnt UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"succes true done");
            }
            else
            {
                NSLog(@"%s: step not ok: %s", __FUNCTION__, sqlite3_errmsg(database));
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"%s: prepare failure: %s", __FUNCTION__, sqlite3_errmsg(database));
        }
    }
    else
    {
        NSLog(@"%s: open failure: %s", __FUNCTION__, sqlite3_errmsg(database));
    }
    return ;
}

+(void)deleteDB{
   
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {

        const char *sql = "DROP TABLE HistoryTB";
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(database, sql,-1, &statement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_DONE){
            }
            else
            {
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}
#pragma mark method for searchPage
+(NSDictionary *)runQuery:(NSString *)sqlStatement{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *compiledStatement;
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement];
        return dict;
    }
    else{
        NSLog(@"Fail to open ");
    }
}
+(NSDictionary* )todaySearch{
     NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE = \"%@\" ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",@"10-8-2016"];
    return [self runQuery:sqlStatement];
}

+(NSDictionary* )ThisWeekSearch{
     NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE IN(SELECT DATE FROM HistoryTB WHERE DATE != \"%@\" )  AND TIME >= \"%f\" ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",@"10-8-2016",[[NSDate date] timeIntervalSince1970] - 3600*24*7];
    return [self runQuery:sqlStatement];
    
}
+(NSDictionary* )LastHourSearch{
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND TIME >= \"%f\" ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",[[NSDate date] timeIntervalSince1970] - 3600];
    return [self runQuery:sqlStatement];
}

+(NSDictionary* )weekDaySearch:(NSString *)search{
    int weekDayNum = [BrowsingHistoryUtil getWeeKdayNumber:search];
    NSString *sqlStatement2 =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE TIME IN(SELECT TIME FROM HistoryTB WHERE strftime('%%w', datetime(TIME,'unixepoch'))= '%d' ) ORDER BY TIME DESC",weekDayNum];
   return [self runQuery:sqlStatement2];

}
+(NSDictionary* )DaySearch:(NSString *)search{
    NSString *str = [BrowsingHistoryUtil getFormateOfDate:search];
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE LIKE  '%%%@%%'  ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",str];
    NSLog(@"sql statement = %@",sqlStatement);
    return  [self runQuery:sqlStatement];

}
+ (NSDictionary *)getSearchString:(NSString *)search{
     NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND URIS LIKE  '%%%@%%'  ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",search];
     return  [self runQuery:sqlStatement];
}
+ (NSString *)getTodayDate{
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd-MM-yyyy"]; // Date formater
    NSString *date = [dateformate stringFromDate:[NSDate date]]; // Convert date to string
    NSLog(@"date getTodayDate:%@",date);
    return date;
    
}


@end
