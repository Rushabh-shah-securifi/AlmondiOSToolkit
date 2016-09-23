//
//  CompleteDB.m
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 23/09/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "CompleteDB.h"
#import <sqlite3.h>

#define DATABASE_FILE @"CompleteDB.db"

@interface CompleteDB()

@end

@implementation CompleteDB
static NSString *databasePath;
static sqlite3 *database = nil;
static sqlite3 *DB = nil;

#pragma mark initializeMethods
+(void)initializeCompleteDataBase{
    [self createDataBasePath:DATABASE_FILE];
    [self setCompleteDBTable];
}

+(void)createDataBasePath:(NSString*)dbPath{
    ////NSLog(@"createDataBasePath");
    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: dbPath]];
    
}

+(void)setCompleteDBTable{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSLog(@"file manager %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
        if ([filemgr fileExistsAtPath: databasePath ] == NO){
    [self createTable:@"CREATE TABLE IF NOT EXISTS CompleteDB (DATE TEXT,AMAC TEXT,CMAC TEXT,DATEINT INTEGER)"];
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

+(void)insertInCompleteDB:(NSString *)date cmac:(NSString*)cmac amac:(NSString*)amac{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
//        [self setCompleteDBTable];
        NSString *query = @"INSERT OR REPLACE INTO CompleteDB (DATE,AMAC,CMAC,DATEINT) VALUES(?,?,?,?)";
        NSLog(@"completeDB query %s",[query UTF8String]);
        if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, NULL)== SQLITE_OK){
            sqlite3_bind_text(statement, 1, [date UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [amac UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [cmac UTF8String], -1, SQLITE_TRANSIENT);
            NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
            [objDateformat setDateFormat:@"yyyy-MM-dd"];
            NSString    *strUTCTime = [self GetUTCDateTimeFromLocalTime:date];
             sqlite3_bind_int(statement, 4, [strUTCTime integerValue]);
            NSLog(@" preparev2 CompleteDB success ");
        }
        else{
            NSLog(@" preparev2 CompleteDB error %s",sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }else{
        NSLog(@"fail to open %s",sqlite3_errmsg(database));
    }
    
}

+(NSArray *)betweenDays:(NSString *)date1 date2:(NSString *)date2 previousDate:(NSString *)previousDate{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [f dateFromString:date1];
    NSDate *endDate = [f dateFromString:date2];
    
    // minDate and maxDate represent your date range
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    
    NSCalendar *gregorianCalendar1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    NSDateComponents *components1 = [[NSDateComponents alloc]init];
    NSLog(@"nos of day %ld", [components day]);
    NSMutableArray *dateArr = [[NSMutableArray alloc]init];
    for (long int i = 1; i<[components day]; i++) {
        [components1 setDay:-i];
        NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:components1 toDate:endDate options:0];
        
        NSString *convertedDateString = [f stringFromDate:date];
        
        NSLog(@"convertedDateString %@,date = %@",convertedDateString,date);
        [dateArr addObject:convertedDateString];
        
    }
    return dateArr;
    
}
+(NSString *)getLastDate:(NSString *)amac clientMac:(NSString *)cmac{
    int max = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT MIN(DATE) from CompleteDB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",amac,cmac];
        
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:max];
    //returning min date
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
}

+(NSString *)getMaxDate:(NSString *)amac clientMac:(NSString *)cmac{
    int max = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT MIN(DATE) from CompleteDB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",amac,cmac];
        
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:max];
    //returning min date
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
}
+ (NSString *) GetUTCDateTimeFromLocalTime:(NSString *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    NSString *strDateTime   = [dateFormatter stringFromDate:objDate];
    return strDateTime;
}
@end
