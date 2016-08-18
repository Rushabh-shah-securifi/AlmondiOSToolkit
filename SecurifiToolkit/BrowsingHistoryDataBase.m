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


//+(DBManager*)getSharedInstance{
//    static dispatch_once_t once_predicate;
//    dispatch_once(&once_predicate, ^{
//        dbSharedInstance = [[super alloc] initDB];
//    });
//    return dbSharedInstance;
//}


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
     ////NSLog(@"database path = %@",databasePath);
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        [self createTable:@"CREATE TABLE IF NOT EXISTS HistoryTB (DATE TEXT,UNIQUEKEY TEXT,AMAC TEXT,CMAC TEXT, URIS TEXT,COUNT TEXT,TIME INTEGER,ENDIDENTIFIER TEXT)"];
    }
}


+(BOOL)createTable:(NSString*)query{
    BOOL isSuccess = YES;
    //NSLog(@"create table %@",query);
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = [query UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
            isSuccess = NO;
            //NSLog(@"Failed to create table  %s",errMsg);
        }
        //NSLog(@"created successfully");
        sqlite3_close(database);
        return  isSuccess;
    }
    else {
        isSuccess = NO;
        //NSLog(@"Failed to open/create database");
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


+ (NSDictionary *)getSearchString:(NSString *)searchPatten andSearchSting:(NSString *)search{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND URIS LIKE  '%%%@%%'  ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",search];
        sqlite3_stmt *compiledStatement;
    
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement searchPatten:searchPatten andSearchSting:search];
        //NSLog(@"search ddict %@",dict);
    return dict;
    }
    
}
+ (NSDictionary *)getAllBrowsingHistory{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84"];
        sqlite3_stmt *compiledStatement;
        
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement searchPatten:@"All" andSearchSting:@""];
        //NSLog(@"search ddict %@",dict);
        return dict;
    }
    
}
+ (NSDictionary *)getManualString:(NSString *)searchPatten andSearchSting:(NSString *)search{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
         NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84"];
        sqlite3_stmt *compiledStatement;
        
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement searchPatten:searchPatten andSearchSting:search];
        NSLog(@"search ddict %@",dict);
        return dict;
    }
    
}
+ (NSDictionary *)prepareMethod:(sqlite3_stmt *)compiledStatement andsqlStatement:(NSString *)sqlStatement searchPatten:(NSString *)searchPatten andSearchSting:(NSString *)search{
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
            NSDate *date = [NSDate convertStirngToDate:uriString0];
            if([[dayDict allKeys] containsObject:uriString0]){
                
            }
            NSString *uriString1 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 1)];
            
            
            NSString *uriString4 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 4)];
            //NSLog(@"uriString4 %@",uriString4);
            NSString *uriString5 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 5)];
            //NSLog(@"uriString5 %@",uriString5);
//            NSString *uriString6 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 6)];
             int field1 =  sqlite3_column_int(compiledStatement, 6);
            NSString *uriString6 = [NSString stringWithFormat:@"%d",field1];
            NSMutableDictionary *uriInfo = [NSMutableDictionary new];
            [uriInfo setObject:uriString4 forKey:@"hostName"];
            [uriInfo setObject:uriString6 forKey:@"Epoc"];
            [uriInfo setObject:uriString5 forKey:@"count"];
            [uriInfo setObject:[UIImage imageNamed:@"help-icon" ] forKey:@"image"];
            
//            //NSLog(@"upadte time epoc %@",[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 7)]);
           
            if([self isToaddDict:uriString6 searchPatten:searchPatten andSearchString:search])
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
+(BOOL)isToaddDict:(NSString *)timeEpoc searchPatten:(NSString *)searchPatten andSearchString:(NSString *)search{
    if([searchPatten isEqualToString:@"All"])
        return YES;
    
    else if ([searchPatten isEqualToString:@"Today"]){
        return [BrowsingHistoryUtil isTodaySearch:timeEpoc];
    }
    else if ([searchPatten isEqualToString:@"weekDay"]){
//        NSLog(@"week day search... %d",[BrowsingHistoryUtil searchByWeeKDay:timeEpoc andSearchString:search]);
        return [BrowsingHistoryUtil searchByWeeKDay:timeEpoc andSearchString:search];
    }
    else if ([searchPatten isEqualToString:@"monthDay"]){
        return ([BrowsingHistoryUtil monthDateSearch:timeEpoc andSearch:search]);
    }
    else if ( [searchPatten isEqualToString:@"lastHour"]){
        return ([BrowsingHistoryUtil isLastHour:timeEpoc]);
    }
    else if ([searchPatten isEqualToString:@"lastWeek"])
        return ([BrowsingHistoryUtil isLastWeek:timeEpoc]);
    else
        return NO;
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
        //NSLog(@"error: %s", sqlite3_errmsg(database));
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            //NSLog(@"error on updating ens identifier: %s", sqlite3_errmsg(database));
        }
        else
        {
            //NSLog(@"updateContact SUCCESS - executed command ");
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
        NSLog(@"error whilw opening database file");
    }
//    NSLog(@"total dict = %@",[self getAllBrowsingHistory]);
//    NSLog(@"database max = %d",max);
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
            //NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    else{
        //NSLog(@"error whilw opening database file");
    }
    //NSLog(@"database count = %d",count);
//    [self deleteOldEntries];
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
         //NSLog(@"delete db method");
//        NSString *query = @"DROP TABLE historyTable";
        const char *sql = "DROP TABLE HistoryTB";
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(database, sql,-1, &statement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_DONE){
                // executed
                //NSLog(@"success deleted all");
            }else{
                //NSLog(@"fail delete %s",sqlite3_errmsg(database));
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}

+(NSDictionary* )todaySearch{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE IN(SELECT DATE FROM HistoryTB WHERE DATE = \"%@\" ) ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",@"10-8-2016"];
        sqlite3_stmt *compiledStatement;
        
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement searchPatten:@"All" andSearchSting:@""];
//        NSLog(@"search ddict %@",dict);
        return dict;
    }

}
+(NSDictionary* )LastHourSearch{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND TIME >= \"%f\" ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",[[NSDate date] timeIntervalSince1970] - 3600];
//        NSLog(@"crrent time epoch %d",[[NSDate date] timeIntervalSince1970] - 3600);
        
        sqlite3_stmt *compiledStatement;//[[NSDate date] timeIntervalSince1970] - 3600
        
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement searchPatten:@"All" andSearchSting:@""];
        NSLog(@"search ddict time %@",dict);
        [self weekDaySearch];
        return dict;
    }
    
}
+(NSDictionary* )weekDaySearch{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND TIME IN(SELECT TIME FROM HistoryTB WHERE strftime('%w', TIME)= \'0\' ) ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84"];
        sqlite3_stmt *compiledStatement;//[[NSDate date] timeIntervalSince1970] - 3600
         NSLog(@"sql statement week = %@",sqlStatement);
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement searchPatten:@"All" andSearchSting:@""];
        NSLog(@"search ddict weekDay %@",dict);
        
        [self week1];
//        [self DaySearch];
        [self getTodayDate];
        return dict;
    }
    
}
+(void)week1{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement2 =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND TIME IN(SELECT TIME FROM HistoryTB WHERE strftime('%w', TIME)= \'%f\' ) ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",2];
        sqlite3_stmt *compiledStatement2;//[[NSDate date] timeIntervalSince1970] - 3600
        NSLog(@"sql statement week1 = %@",sqlStatement2);
        NSDictionary *dict1 = [self prepareMethod:compiledStatement2 andsqlStatement:sqlStatement2 searchPatten:@"All" andSearchSting:@""];
        NSLog(@"search ddict weekDay1 %@",dict1);
        
         }
    [self week2];
}
+(void)week2{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement3 =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND TIME IN(SELECT TIME FROM HistoryTB WHERE strftime('%w', TIME)= '0' ) ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84"];
        sqlite3_stmt *compiledStatement3;//[[NSDate date] timeIntervalSince1970] - 3600
        NSLog(@"sql statement week3 = %@",sqlStatement3);
        NSDictionary *dict3 = [self prepareMethod:compiledStatement3 andsqlStatement:sqlStatement3 searchPatten:@"All" andSearchSting:@""];
        NSLog(@"search ddict weekDay3 %@",dict3);
        [self getTodayDate];
    }
    
}
+(void)week3{
    
}
+(NSDictionary* )DaySearch{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND TIME IN(SELECT TIME FROM HistoryTB WHERE strftime('%Y-%m-%d',TIME) = \"%@\") ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",@"2016-8-10"];
        NSLog(@"sql statement = %@",sqlStatement);
        sqlite3_stmt *compiledStatement;//[[NSDate date] timeIntervalSince1970] - 3600
        
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement searchPatten:@"All" andSearchSting:@""];
        NSLog(@"search ddict mday %@",dict);
        return dict;
    }
    
}
+ (NSString *)getTodayDate{
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd-MM-yyyy"]; // Date formater
    NSString *date = [dateformate stringFromDate:[NSDate date]]; // Convert date to string
    NSLog(@"date getTodayDate:%@",date);
    return date;
}
//@"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND TIME IN(SELECT TIME FROM HistoryTB WHERE strftime('%w', TIME) = \"%@\" ) ORDER BY TIME DESC",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",@"1"

@end
