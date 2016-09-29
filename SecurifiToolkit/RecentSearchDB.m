//
//  RecentSearch.m
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 28/09/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "RecentSearchDB.h"
#import <sqlite3.h>
#import <UIKit/UIKit.h>

#define DATABASE_FILE @"recentSearch.db"
@implementation RecentSearchDB
static NSString *databasePath;
static sqlite3 *database = nil;
static sqlite3 *DB = nil;
+(void)initializeCompleteDataBase{
    [self createDataBasePath:DATABASE_FILE];
    [self setRecentSearchTable];
}
+(void)createDataBasePath:(NSString*)dbPath{
    ////NSLog(@"createDataBasePath");
    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: dbPath]];
    
}
+(void)setRecentSearchTable{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSLog(@"file manager %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        [self createTable:@"CREATE TABLE IF NOT EXISTS recentDB (URIS TEXT,AMAC TEXT,CMAC TEXT,TIME INTEGER,PRIMARY KEY(URIS,AMAC,CMAC))"];
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
+(void)insertInRecentDB:(NSString *)uri cmac:(NSString*)cmac amac:(NSString*)amac{
    NSLog(@"amac = %@,cmac = %@",amac,cmac);
    const char *dbpath = [databasePath UTF8String];
    [self setRecentSearchTable];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        NSString *query = @"INSERT OR REPLACE INTO recentDB (URIS,AMAC,CMAC,TIME) VALUES(?,?,?,?)";
        NSLog(@"completeDB query %s",[query UTF8String]);
        
        if(sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, NULL)== SQLITE_OK){
            sqlite3_bind_text(statement, 1, [uri UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [amac UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [cmac UTF8String], -1, SQLITE_TRANSIENT);
            long int currentTime = [NSDate date].timeIntervalSince1970;
          
            sqlite3_bind_int(statement, 4, currentTime);
            NSLog(@" preparev2 CompleteDB success recent search  %ld",currentTime);
        }
        else{
            NSLog(@" preparev2 CompleteDB error recent search %s",sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
    }else{
        NSLog(@"fail to open %s",sqlite3_errmsg(database));
    }
    sqlite3_close(database);
    
}
#pragma mark getBrowsingHistoryMethods
+ (NSMutableArray *)getAllRecentwithLimit:(int)limit almonsMac:(NSString *)amac clientMac:(NSString *)cmac{
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from recentDB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ORDER BY TIME DESC limit %d",amac,cmac,limit];
        sqlite3_stmt *compiledStatement;
        
        NSMutableArray *Arr = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement];
        NSLog(@"search ddict %@",Arr);
        return Arr;
    }
    
}

+ (NSMutableArray *)prepareMethod:(sqlite3_stmt *)compiledStatement andsqlStatement:(NSString *)sqlStatement{
    
    NSLog(@"prepare method Querie: = %s",[sqlStatement UTF8String]);
    NSMutableArray *recentsearchHistory = [[NSMutableArray alloc]init];
    if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK){
        if (sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            NSString *uriString2 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 2)];
        }
        else
            NSLog(@"sqlite3_step 1 %s",sqlite3_errmsg(database));
        
        NSLog(@"success msg %s",sqlite3_errmsg(database));
        while (sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            NSString *uriString0 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 0)];
            NSMutableDictionary *uriInfo = [NSMutableDictionary new];
            [uriInfo setObject:uriString0 forKey:@"hostName"];
            NSLog(@"uriString0uris %@",uriString0);
            [uriInfo setObject:[UIImage imageNamed:@"search_icon"] forKey:@"image" ];
            [recentsearchHistory addObject:uriInfo];
           
            
        }
        NSLog(@"while not running errMSg %s",sqlite3_errmsg(database));
        
        
    }
    else{
        NSLog(@"prepare errMSg %s",sqlite3_errmsg(database));
    }
    sqlite3_step(compiledStatement);
    sqlite3_finalize(compiledStatement);
    
    sqlite3_close(database);
    //    NSLog(@"DB DayDict:: %@",clientBrowsingHistory);
    //    NSLog(@"clientBrowsingHistory :: %@",clientBrowsingHistory);
    NSLog(@"recentsearchHistory %@",recentsearchHistory);
    return recentsearchHistory;
}
+(int)GetHistoryDatabaseCount:(NSString *)amac clientMac:(NSString *)cmac{
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *sqlcountStat =[NSString stringWithFormat: @"SELECT COUNT(*) from recentDB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ",amac,cmac];
        //        const char* sqlcountStat = "SELECT COUNT(*) FROM HistoryTB WHERE AMAC = ? AND CMAC = ?";
        sqlite3_stmt *statement;
        //NSLog(@"count statment  %s",[sqlcountStat UTF8String]);
        if( sqlite3_prepare_v2(database, [sqlcountStat UTF8String],-1, &statement, NULL)== SQLITE_OK)
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                
                count = sqlite3_column_int(statement, 0);
                NSLog(@"counting...");
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
    return count;
}

@end
