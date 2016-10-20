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
#import "CompleteDB.h"

#import <sqlite3.h>


#define DATABASE_FILE @"BrowsingHistory.db"
#define HISTORYTABLE @"HistoryTB"

@interface BrowsingHistoryDataBase()

@end

@implementation BrowsingHistoryDataBase
static NSString *databasePath;
static BrowsingHistoryDataBase *dbSharedInstance = nil;
static sqlite3 *database = nil;
typedef void(^myCompletion)(BOOL);
#pragma mark initializeMethods
+(void)initializeDataBase{
    NSLog(@"Calling this Database");
    sqlite3_shutdown();
    if (sqlite3_threadsafe() > 0) {
        int retCode = sqlite3_config(SQLITE_CONFIG_SERIALIZED);
        if (retCode == SQLITE_OK) {
            NSLog(@"Can now use sqlite on multiple threads, using the same connection");
        } else {
            NSLog(@"setting sqlite thread safe mode to serialized failed!!! return code: %d", retCode);
        }
    } else {
        NSLog(@"Your SQLite database is not compiled to be threadsafe.");
    }
    sqlite3_initialize();
    
    [self createDataBasePath:DATABASE_FILE];
    [self setHistoryTable];
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
        NSLog(@"DB Opened :1");
        
    }
    else{
        NSLog(@"DB closed :1");
        sqlite3_close(database);
    }
    
}

+(void)createDataBasePath:(NSString*)dbPath{
    ////NSLog(@"createDataBasePath");
    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: dbPath]];
    
}

+(void)closeDB{
    NSLog(@"Hello I am in Close");
    sqlite3_close(database);
}
+ (BOOL)openDB{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSLog(@"Hello I am in Open");
        return YES;
    }
    return NO;
}

+(void)setHistoryTable{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        [self createTable:@"CREATE TABLE IF NOT EXISTS HistoryTB (DATE TEXT,AMAC TEXT,CMAC TEXT, URIS TEXT,CATEGORYID TEXT,TIME INTEGER,CATEGORY TEXT,CATEGORYNAME TEXT,DATEINT INTEGER,PRIMARY KEY(DATE,AMAC,CMAC,URIS))"];
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
        //sqlite3_close(database);
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
+ (NSDictionary *)getAllBrowsingHistorywithLimit:(int)limit almonsMac:(NSString *)amac clientMac:(NSString *)cmac{
    
    
    //    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    //    {
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ORDER BY TIME DESC  limit %d",amac,cmac,limit];
    sqlite3_stmt *compiledStatement;
    
    NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement];
    //NSLog(@"search ddict %@",dict);
    return dict;
    //}
    
}

+ (NSDictionary *)prepareMethod:(sqlite3_stmt *)compiledStatement andsqlStatement:(NSString *)sqlStatement{
    
    NSMutableDictionary *clientBrowsingHistory = [[NSMutableDictionary alloc]init];
    if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK){
        NSMutableDictionary *dayDict = [NSMutableDictionary new];
        while (sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            NSString *uriString3 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 2)];
            
            NSString *uriString2 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 1)];
            [clientBrowsingHistory setValue:uriString2 forKey:@"clientMac"];
            [clientBrowsingHistory setValue:uriString3 forKey:@"almondMac"];
            
            NSString *uriString0 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 0)];
            
            
            
            NSString *uriString4 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 3)];
            NSString *uriString5 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 4)];
            
            
            int field1 =  sqlite3_column_int(compiledStatement, 5);
            NSString *uriString6 = [NSString stringWithFormat:@"%d",field1];
            
            NSString *uriString7 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 6)];
            NSString *uriString8 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 7)];
            
            
            NSDictionary *categoryObj = @{@"ID":uriString5,
                                          @"categoty":uriString7,
                                          @"subCategory":uriString8};
            
            NSDictionary *uriInfo1 = @{
                                       @"hostName":uriString4,
                                       @"Epoc" : uriString6,
                                       @"count" : uriString5,
                                       @"date" : uriString0,
                                       @"categoryObj" : categoryObj
                                       };
            [self addToDictionary:dayDict uriInfo:uriInfo1 rowID:uriString0];
            
        }
        //        NSLog(@"while not running errMSg %s",sqlite3_errmsg(database));
        [clientBrowsingHistory setObject:dayDict forKey:@"Data"];
        
    }
    else{
        NSLog(@"prepare errMSg %s",sqlite3_errmsg(database));
    }
    sqlite3_step(compiledStatement);
    sqlite3_finalize(compiledStatement);
    
    // sqlite3_close(database);
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

#pragma mark insertMethods
+(NSMutableDictionary *)insertAndGetHistoryRecord:(NSDictionary *)hDict readlimit:(int)limit amac:(NSString *)amac cmac:(NSString *)camc{
    NSMutableDictionary *recordDict;
//    
//    [self addtoCompleteDB:@"2016-10-11" lastDate:@"2016-10-04" amac:amac cmac:camc];
//    [CompleteDB searchDatePresentOrNot:amac clientMac:camc andDate:@""];
//    NSLog(@" max date %@ and min date %@",[CompleteDB getMaxDate:amac clientMac:camc],[CompleteDB getLastDate:amac clientMac:camc]);
//    NSLog(@"date present %d",[CompleteDB searchDatePresentOrNot:amac clientMac:camc andDate:@"2016-10-19"]);
    
    
    NSString *query = @"INSERT OR REPLACE INTO HistoryTB (DATE,AMAC,CMAC, URIS,CATEGORYID,TIME,CATEGORY,CATEGORYNAME,DATEINT) VALUES(?,?,?,?,?,?,?,?,?)";
    [self setHistoryTable];
    if([self openDB]== NO)
        return nil;
    const char *dbpath = [databasePath UTF8String];
    //    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    //    {
    if(hDict !=NULL)
        [self insertHistoryEntries:hDict query:query];
    if(limit != 0)
        recordDict = [self getAllBrowsingHistorywithLimit:limit almonsMac:amac clientMac:camc];
    //    }
    //    else{
    //        NSLog(@"error while opening");
    //    }
    
    //sqlite3_close(database);
    return recordDict;
}

+ (void )insertHistoryEntries:(NSDictionary *)hDict query:(NSString *)query{
    sqlite3_stmt *statement;
    NSString *endtag;
    NSArray *allObj = hDict[@"Data"];
    if([allObj count]<= 0)
        return ;
    NSDictionary *catogeryDict = [self parseJson:@"CategoryMap"];
    
    NSString* statement1;
    static sqlite3_stmt *init_statement = nil;
    statement1 = @"BEGIN EXCLUSIVE TRANSACTION";
    
    if (sqlite3_prepare_v2(database, [statement1 UTF8String], -1, &init_statement, NULL) != SQLITE_OK) {
        printf("db error: %s\n", sqlite3_errmsg(database));
        return ;
    }
    if (sqlite3_step(init_statement) != SQLITE_DONE) {
        sqlite3_finalize(init_statement);
        printf("db error: %s\n", sqlite3_errmsg(database));
        return ;
    }
    
    const char *insert_stmt = [query UTF8String];
    sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
    
    

    for(NSDictionary *uriDict in allObj)
    {
        if(sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL)== SQLITE_OK){
            NSLog(@"insert date = %@",uriDict[@"Date"]);
            NSString *todayDate = [self getTodayDate];
//            if([uriDict[@"Date"] isEqualToString:@""])
//                sqlite3_bind_text(statement, 1, [todayDate UTF8String], -1, SQLITE_TRANSIENT);
//            else
                sqlite3_bind_text(statement, 1, [uriDict[@"Date"] UTF8String], -1, SQLITE_TRANSIENT);
            
            sqlite3_bind_text(statement, 2, [hDict[@"AMAC"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [hDict[@"CMAC"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [uriDict[@"Domain"] UTF8String], -1, SQLITE_TRANSIENT);
            
            //categoryID instead of count
            int ID = [uriDict[@"subCategory"] intValue] ;
            
            NSDictionary *categoryName = catogeryDict[@(ID).stringValue];
            if(categoryName == NULL){
                categoryName = @{@"category":@"G",
                                 @"categoryName": @"Real Estate"   };
            }
            int mii = arc4random()%81;
            sqlite3_bind_text(statement, 5, [[NSString stringWithFormat:@"%d",mii] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 6, [[NSString stringWithFormat:@"%@",uriDict[@"LastVisitedEpoch"]] integerValue]);
            sqlite3_bind_text(statement, 7, [categoryName[@"category"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 8, [categoryName[@"categoryName"] UTF8String], -1, SQLITE_TRANSIENT);
            int rc;
            
            NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
            [objDateformat setDateFormat:@"yyyy-MM-dd"];
            NSString    *strUTCTime = [self GetUTCDateTimeFromLocalTime:uriDict[@"Date"]];
            NSDate *objUTCDate  = [objDateformat dateFromString:strUTCTime];
            long long milliseconds = (long long)([objUTCDate timeIntervalSince1970]);
            
            sqlite3_bind_int(statement, 9, milliseconds);
            if (sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@" successS");
                
            }
            else {
                NSLog(@"sqlite3_step error writing %s",sqlite3_errmsg(database));
            }
            
        }
        else{
            NSLog(@" preparev2 error %s %s",sqlite3_errmsg(database),__PRETTY_FUNCTION__);
        }
        
        endtag = hDict[@"pageState"];
        //NSLog(@"LastVisitedEpoch == %@",endtag);
    }
    statement1 = @"COMMIT TRANSACTION";
    sqlite3_stmt *commitStatement;
    if (sqlite3_prepare_v2(database, [statement1 UTF8String], -1, &commitStatement, NULL) != SQLITE_OK) {
        printf("db error: %s\n", sqlite3_errmsg(database));
        return ;
    }
    if (sqlite3_step(commitStatement) != SQLITE_DONE) {
        printf("db error: %s\n", sqlite3_errmsg(database));
        return ;
    }
    
    sqlite3_finalize(statement);
    sqlite3_finalize(commitStatement);
    //sqlite3_close(database);
    
    NSDictionary *first_uriDict = [allObj firstObject];
    NSString *first_date = first_uriDict[@"Date"];
    
    
    NSDictionary *last_uriDict = [allObj lastObject];
    NSString *last_date = last_uriDict[@"Date"];
    
    // put last_date and & ps in incomplete DB
    if([first_date isEqualToString:last_date]){
       
    }
    else{
        //[self addtoCompleteDB:first_date lastDate:last_date amac:hDict[@"AMAC"] cmac:hDict[@"CMAC"]];
        
    }
    return ;
}
+(void)addtoCompleteDB:(NSString *)firstDate lastDate:(NSString*)lastDate amac:(NSString*)amac cmac:(NSString *)cmac{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd"];
    NSString *todayDate = [f stringFromDate:[NSDate date]];
    
    if([firstDate isEqualToString:todayDate]){
        // take b/w date
        NSArray *arr = [CompleteDB betweenDays:todayDate date2:lastDate previousDate:NULL];
        NSLog(@" in between days today arr %@",arr);
        for(NSString *dateStr in arr){
            [CompleteDB insertInCompleteDB:dateStr cmac:cmac amac:amac];
        }
    }
    else{
        NSArray *arr = [CompleteDB betweenDays:firstDate date2:lastDate previousDate:NULL];
        if(![firstDate isEqualToString:todayDate]){
            arr =[CompleteDB betweenDays:todayDate date2:lastDate previousDate:NULL];
        }
        NSLog(@" in between days today not %@",arr);
        
            for(long int i = 0;i < arr.count ;i++){
                [CompleteDB insertInCompleteDB:[arr objectAtIndex:i] cmac:cmac amac:amac];
            }
    }
}
+ (NSString *)GetUTCDateTimeFromLocalTime:(NSString *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    NSString *strDateTime   = [dateFormatter stringFromDate:objDate];
    return strDateTime;
}

#pragma mark update_count_deleteMethods


+(int)getCount:(NSString *)amac clientMac:(NSString *)cmac{
    int count = 0;
    NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT COUNT(*) from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",amac,cmac];
    sqlite3_stmt *statement;
    if( sqlite3_prepare_v2(database, [sqlcountStat UTF8String],-1, &statement, NULL)== SQLITE_OK)
    {
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
    return count;
}
+(int)GetHistoryDatabaseCount:(NSString *)amac clientMac:(NSString *)cmac{
    int count = 0;

    if([self openDB] == NO)
        return nil;
    
    const char *dbpath = [databasePath UTF8String];
   
    NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT COUNT(*) from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",amac,cmac];
    
    sqlite3_stmt *statement;
    
    if( sqlite3_prepare_v2(database, [sqlcountStat UTF8String],-1, &statement, NULL)== SQLITE_OK)
    {
        //Loop through all the returned rows (should be just one)
        while( sqlite3_step(statement) == SQLITE_ROW )
        {
            NSLog(@"Inb loop ");
            count = sqlite3_column_int(statement, 0);
            
        }
    }
    else
    {
        NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
    }
    
    // Finalize and close database.
    sqlite3_finalize(statement);
    // sqlite3_close(database);
    //    }
    //    else{
    //        //NSLog(@"error whilw opening database file");
    //    }
    return count;
}
+(void)deleteOldEntries:(NSString *)amac clientMac:(NSString *)cmac date:(NSString *)date{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSLog(@"database path %s",dbpath);
        sqlite3_stmt *statement;
        
        NSString *delStatmrnt = [NSString stringWithFormat:@"DELETE FROM HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE = \"%@\"",amac,cmac,date];
        if (sqlite3_prepare_v2(database, [delStatmrnt UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"succes true done");
            }
            //            else
            //            {
            //                NSLog(@"%s: step not ok: %s", __FUNCTION__, sqlite3_errmsg(database));
            //            }
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
+(NSString *)getLastDate:(NSString *)amac clientMac:(NSString *)cmac{
    int max = 0;
    const char *dbpath = [databasePath UTF8String];
    NSString *dateStr;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        int count = [self getCount:amac clientMac:cmac];
        if(count > 500)
        {
            count = [self getCount:amac clientMac:cmac];
            NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT MIN(DATEINT) from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",amac,cmac];
            
            sqlite3_stmt *statement;
            //NSLog(@"count statment  %s",[sqlcountStat UTF8String]);
            if( sqlite3_prepare_v2(database, [sqlcountStat UTF8String],-1, &statement, NULL)== SQLITE_OK)
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    
                    max = sqlite3_column_int(statement, 0);
                    
                }
            }
            else
            {
                NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:max];
            dateStr = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
            //delete
            
            
            NSString *delStatmrnt = [NSString stringWithFormat:@"DELETE FROM HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE = \"%@\"",amac,cmac,dateStr];
            if (sqlite3_prepare_v2(database, [delStatmrnt UTF8String], -1, &statement, NULL) == SQLITE_OK)
            {
                while(sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"succes true done");
                }
                sqlite3_finalize(statement);
            }
            else
            {
                NSLog(@"%s: prepare failure: %s", __FUNCTION__, sqlite3_errmsg(database));
            }
            //NSLog(<#NSString * _Nonnull format, ...#>)
            [CompleteDB deleteDateEntries:amac clientMac:cmac date:dateStr];
        }
        sqlite3_close(database);
    }
    else{
        NSLog(@"error while opening database file");
    }
    
    //returning min date
    return dateStr;
    
    
}

+(void)deleteDB:(NSString *)amac clientMac:(NSString *)cmac{
    NSLog(@" I am here Deleting Database");
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
+(void)deleteOldEntries:(NSString *)amac clientMac:(NSString *)cmac{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        int record = [self getCount:amac clientMac:cmac] - 500;
        if(record > 0)
        {
            NSLog(@"database path %s",dbpath);
            sqlite3_stmt *statement;
            NSString *delStatmrnt = [NSString stringWithFormat:@"DELETE FROM HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND TIME IN(SELECT TIME FROM HistoryTB order by TIME ASC limit %d)",amac,cmac,record];
            if (sqlite3_prepare_v2(database, [delStatmrnt UTF8String], -1, &statement, NULL) == SQLITE_OK)
            {
                if(sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"succes delete done");
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
    }
    else
    {
        NSLog(@"%s: open failure: %s", __FUNCTION__, sqlite3_errmsg(database));
    }
    return ;
}
#pragma mark method for searchPage
+(NSDictionary *)runQuery:(NSString *)sqlStatement{
//    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
//    {
        sqlite3_stmt *compiledStatement;
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement];
        return dict;
//    }
//    else{
//        NSLog(@"Fail to open ");
//    }
}

+(NSDictionary* )todaySearch:(NSString *)amac clientMac:(NSString *)cmac{
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE = \"%@\" ORDER BY TIME DESC",amac,cmac,[self getTodayDate]];
    return [self runQuery:sqlStatement];
}

+(NSDictionary* )ThisWeekSearch:(NSString *)amac clientMac:(NSString *)cmac{
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE IN(SELECT DATE FROM HistoryTB WHERE DATE != \"%@\" )  AND TIME >= \"%f\" ORDER BY TIME DESC",amac,cmac,[self getTodayDate],[[NSDate date] timeIntervalSince1970] - 3600*24*7];
    return [self runQuery:sqlStatement];
    
}
+(NSDictionary* )LastHourSearch:(NSString *)amac clientMac:(NSString *)cmac{
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND TIME >= \"%f\" ORDER BY TIME DESC",amac,cmac,[[NSDate date] timeIntervalSince1970] - 3600];
    return [self runQuery:sqlStatement];
}

+(NSDictionary* )weekDaySearch:(NSString *)search almonsMac:(NSString *)amac clientMac:(NSString *)cmac{
    int weekDayNum = [BrowsingHistoryUtil getWeeKdayNumber:search];
    NSString *sqlStatement2 =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE TIME IN(SELECT TIME FROM HistoryTB WHERE strftime('%%w', datetime(TIME,'unixepoch'))= '%d' ) ORDER BY TIME DESC",weekDayNum];
    return [self runQuery:sqlStatement2];
    
}
+(NSDictionary *)searchBYCategoty:(NSString*)search almonsMac:(NSString *)amac clientMac:(NSString *)cmac{
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND CATEGORY = \"%@\"  ORDER BY TIME DESC",amac,cmac,search];
    return  [self runQuery:sqlStatement];
}
+(NSDictionary* )DaySearch:(NSString *)search almonsMac:(NSString *)amac clientMac:(NSString *)cmac{
    NSString *str = [BrowsingHistoryUtil getFormateOfDate:search];
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE LIKE  '%%%@%%'  ORDER BY TIME DESC",amac,cmac,str];
    NSLog(@"sql statement = %@",sqlStatement);
    return  [self runQuery:sqlStatement];
    
}
+ (NSDictionary *)getSearchString:(NSString *)search almonsMac:(NSString *)amac clientMac:(NSString *)cmac{
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND URIS LIKE  '%%%@%%'  ORDER BY TIME DESC",amac,cmac,search];
    return  [self runQuery:sqlStatement];
}
+ (NSString *)getTodayDate{
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"yyyy-MM-dd"]; // Date formater
    NSString *date = [dateformate stringFromDate:[NSDate date]]; // Convert date to string
    return date;
    
}


@end
