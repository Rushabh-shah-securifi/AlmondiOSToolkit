//
//  CompleteDB.m
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 23/09/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "CompleteDB.h"
#import <sqlite3.h>
#import "NSDate+Convenience.h"

#define DATABASE_FILE @"CompleteDB.db"

@interface CompleteDB()

@end

@implementation CompleteDB
static NSString *databasePath1;
static sqlite3 *database1 = nil;

#pragma mark initializeMethods
+(void)initializeCompleteDataBase{
    [self createDataBasePath:DATABASE_FILE];
    [self setCompleteDBTable];
}

+(void)createDataBasePath:(NSString*)dbPath{
    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath1 = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: dbPath]];
    
}

+(void)setCompleteDBTable{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSLog(@"file manager %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
        if ([filemgr fileExistsAtPath: databasePath1 ] == NO){
    [self createTable:@"CREATE TABLE IF NOT EXISTS CompleteDB (DATE TEXT,AMAC TEXT,CMAC TEXT,DATEINT INTEGER,PRIMARY KEY(DATE,AMAC,CMAC))"];
        }
}

+(BOOL)createTable:(NSString*)query{
    BOOL isSuccess = YES;
    
    NSLog(@"create table %@",query);
    const char *dbpath = [databasePath1 UTF8String];
    if (sqlite3_open(dbpath, &database1) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = [query UTF8String];
        if (sqlite3_exec(database1, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
            isSuccess = NO;
            NSLog(@"Failed to create table  %s",errMsg);
        }
        NSLog(@"created successfully");
        sqlite3_close(database1);
        return  isSuccess;
    }
    else {
        isSuccess = NO;
        NSLog(@"Failed to open/create database");
    }
    return isSuccess;
}

+(void)insertInCompleteDB:(NSString *)date cmac:(NSString*)cmac amac:(NSString*)amac{
    const char *dbpath = [databasePath1 UTF8String];
    [self setCompleteDBTable];
    
    if (sqlite3_open(dbpath, &database1) == SQLITE_OK)
    {
        int rc=0;
        sqlite3_stmt *statement ;
            NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
            [objDateformat setDateFormat:@"yyyy-MM-dd"];
            [objDateformat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
            NSString    *strUTCTime = [self GetUTCDateTimeFromLocalTime:date];
            
            NSDate *objUTCDate  = [objDateformat dateFromString:strUTCTime];
            NSLog(@"strUTCTime %@ date %@",strUTCTime,objUTCDate);
            NSInteger  milliseconds = [objUTCDate timeIntervalSince1970];
            NSLog(@"strUTCTime %ld ",milliseconds);

            NSString * query  = [NSString
                                 stringWithFormat:@"INSERT OR REPLACE INTO CompleteDB (DATE,AMAC,CMAC,DATEINT) VALUES (\"%@\",\"%@\",\"%@\",%ld)",date,amac,cmac,milliseconds];
            char * errMsg;
                        rc = sqlite3_exec(database1, [query UTF8String] ,&statement,NULL,&errMsg);
            if(SQLITE_OK != rc)
            {
                NSLog(@"Failed to insert record  rc:%d, msg=%s",rc,errMsg);
            }
    }
    else{
    NSLog(@"fail to open %s",sqlite3_errmsg(database1));
   
}
     sqlite3_close(database1);
}
+(NSArray *)betweenDays:(NSString *)date1 date2:(NSString *)date2 previousDate:(NSString *)previousDate{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd"];
    [f setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
    NSDate *startDate = [f dateFromString:date1];
    NSDate *endDate = [f dateFromString:date2];
    NSLog(@"startDate = %@ date1 %@ ,endDate %@ date2 %@",startDate,date1,endDate,date2);
    
    // minDate and maxDate represent your date range
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
  
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                                        fromDate:endDate
                                                          toDate:startDate
                                                         options:0];
    
    NSMutableArray *dateArr = [[NSMutableArray alloc]init];
    for (long int i = [components day] - 1; i>0; i--) {// skipping first and last day
        [components setDay:i];
        NSDate *date = [calendar dateByAddingComponents:components toDate:endDate options:0];
        
        NSString *convertedDateString = [f stringFromDate:date];
        
        [dateArr addObject:convertedDateString];
        
    }
    return dateArr;
    
}

+(NSString *)getLastDate:(NSString *)amac clientMac:(NSString *)cmac{
    int max = 0;
    const char *dbpath = [databasePath1 UTF8String];
    if (sqlite3_open(dbpath, &database1) == SQLITE_OK)
    {
        
        NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT MIN(DATEINT) from CompleteDB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",amac,cmac];
        
        sqlite3_stmt *statement;
        //NSLog(@"count statment  %s",[sqlcountStat UTF8String]);
        if( sqlite3_prepare_v2(database1, [sqlcountStat UTF8String],-1, &statement, NULL)== SQLITE_OK)
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                NSLog(@"finding ...");
                max = sqlite3_column_int(statement, 0);
                
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database1) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database1);
    }
    else{
        NSLog(@"error while opening database file");
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:max];
    //returning min date
    NSLog(@"max === %d",max);
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
}

+(NSString *)getMaxDate:(NSString *)amac clientMac:(NSString *)cmac{
    int max = 0;
    const char *dbpath = [databasePath1 UTF8String];
    if (sqlite3_open(dbpath, &database1) == SQLITE_OK)
    {
        
        NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT MAX(DATEINT) from CompleteDB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",amac,cmac];
        
        sqlite3_stmt *statement;
        //NSLog(@"count statment  %s",[sqlcountStat UTF8String]);
        if( sqlite3_prepare_v2(database1, [sqlcountStat UTF8String],-1, &statement, NULL)== SQLITE_OK)
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                max = sqlite3_column_int(statement, 0);
                
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database1) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database1);
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
+ (NSString *) GetUTCDateTimeFromLocalTime:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate  *objDate    = [dateFormatter dateFromString:dateStr];
    NSString *strDateTime   = [dateFormatter stringFromDate:objDate];
    return strDateTime;
}
+(void)deleteDateEntries:(NSString *)amac clientMac:(NSString *)cmac date:(NSString *)date{
    const char *dbpath = [databasePath1 UTF8String];
    
    if (sqlite3_open(dbpath, &database1) == SQLITE_OK)
    {
        NSLog(@"database path %s",dbpath);
        sqlite3_stmt *statement;
        //NSString *delStatmrnt = [NSString stringWithFormat:@"DELETE FROM HistoryTB WHERE TIME IN(SELECT TIME FROM HistoryTB order by TIME ASC limit 50)"];
        
        NSString *delStatmrnt = [NSString stringWithFormat:@"DELETE FROM CompleteDB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE = \"%@\"",amac,cmac,date];
        if (sqlite3_prepare_v2(database1, [delStatmrnt UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"succes true done");
            }
            else
            {
                NSLog(@"%s: step not ok: %s", __FUNCTION__, sqlite3_errmsg(database1));
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"%s: prepare failure: %s", __FUNCTION__, sqlite3_errmsg(database1));
        }
    }
    else
    {
        NSLog(@"%s: open failure: %s", __FUNCTION__, sqlite3_errmsg(database1));
    }
    return ;
}

+(int)getCount:(NSString *)amac clientMac:(NSString *)cmac{
    int count = 0;
    NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT COUNT(*) from CompleteDB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",amac,cmac];
    sqlite3_stmt *statement;
    if( sqlite3_prepare_v2(database1, [sqlcountStat UTF8String],-1, &statement, NULL)== SQLITE_OK)
    {
        while( sqlite3_step(statement) == SQLITE_ROW )
        {
            NSLog(@"counting ...");
            count = sqlite3_column_int(statement, 0);
        }
    }
    else
    {
        NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database1) );
    }
    
    // Finalize and close database.
    sqlite3_finalize(statement);
    return count;
}
+(BOOL)searchDatePresentOrNot:(NSString *)amac clientMac:(NSString *)cmac andDate:(NSString *)date{
    const char *dbpath = [databasePath1 UTF8String];
    NSString *uriString3;
    if (sqlite3_open(dbpath, &database1) == SQLITE_OK)
    {
        NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from CompleteDB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND DATE LIKE  '%%%@%%' ",amac,cmac,date];
        //        const char* sqlcountStat = "SELECT COUNT(*) FROM HistoryTB WHERE AMAC = ? AND CMAC = ?";
        sqlite3_stmt *statement;
        
        NSLog(@"count statment  %d",[self getCount:amac clientMac:cmac]);
        
        if( sqlite3_prepare_v2(database1, [sqlStatement UTF8String],-1, &statement, NULL)== SQLITE_OK)
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                uriString3 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database1) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database1);
    }
    else{
        NSLog(@"error whilw opening database file");
    }
    if(uriString3 != NULL)
        return YES;
    else
        return NO;
    
}

@end
