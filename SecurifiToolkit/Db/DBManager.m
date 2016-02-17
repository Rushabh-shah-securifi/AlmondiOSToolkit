//
//  DBManager.m
//  JSONParsingAndSqliteDataBase
//
//  Created by Masood on 17/02/16.
//  Copyright © 2016 Masood. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@interface DBManager()
@property NSString *databasePath;

@end

@implementation DBManager
static DBManager *dbSharedInstance = nil;
static sqlite3 *database = nil;


//+(DBManager*)getSharedInstance{
//    static dispatch_once_t once_predicate;
//    dispatch_once(&once_predicate, ^{
//        dbSharedInstance = [[super alloc] initDB];
//    });
//    return dbSharedInstance;
//}

- (instancetype)initDB{
    NSLog(@"initDB");
    self = [super init];
    if(self){
        [self createDataBasePath:@"deviceIndex.db"];
    }
    return self;
}


-(void)createDataBasePath:(NSString*)dbPath{
    NSLog(@"createDataBasePath");
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: dbPath]];
}

-(BOOL)createDB{
    NSLog(@"createDB");
    BOOL isSuccess = YES;
    NSDate *methodStart = [NSDate date];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        NSLog(@"file does not ExistsAtPath");
        const char *dbpath = [_databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS deviceIndexDetail (ID INTEGER PRIMARY KEY, DATA TEXT)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"create database executionTime = %f", executionTime);
    return isSuccess;
}

- (void)insertData:(NSDictionary*)deviceIndexDict
{
    NSLog(@"insertData");
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    NSDate *methodStart = [NSDate date];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO deviceIndexDetail (id,data) VALUES(?,?)"];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);

        for(NSString *indexID in [deviceIndexDict allKeys]){
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:[deviceIndexDict valueForKey:indexID] options:0 error:nil];
            NSString * indexData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
            sqlite3_bind_text(statement, 1, [indexID UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [indexData UTF8String],-1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@"success");
            }
            else {
                NSLog(@"error");
            }

        }
        
        sqlite3_close(database);
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"insert database executionTime = %f", executionTime);
}

-(void)updateData:(NSString*)ID indexData:(NSString*)indexData{
    NSLog(@"updateData");
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *insertSQL = [NSString stringWithFormat:@"UPDATE deviceIndexDetail SET data = (?) WHERE id = (?)"];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [ID UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [indexData UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"success");
        }
        else {
            NSLog(@"error");
        }
        sqlite3_close(database);
    }
}



- (NSString*)findByID:(NSString*)ID
{
    NSLog(@"findByID");
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    NSDate *methodStart = [NSDate date];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select data from deviceIndexDetail where id=\"%@\"",ID];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *indexDetail = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                NSData *data = [indexDetail dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *indexDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"indexname: %@", [indexDict valueForKey:@"IndexName"]);
                return [indexDict valueForKey:@"IndexName"];
            }
            else{
                NSLog(@"Not found");
            }
            sqlite3_close(database);
        }
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"delete database executionTime = %f", executionTime);

    return @"not found";
}



-(void)deleteTable{//[db executeQuery:@"DROP TABLE myTableName"];
    NSLog(@"deleteTable");
    NSDate *methodStart = [NSDate date];
    NSString *query = @"DELETE FROM deviceIndexDetail";
    const char *sqlStatement = [query UTF8String];
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *compiledStatement;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                NSLog(@"result is here");
            }
        }
    }else{
        NSLog(@"error - delete table");
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"delete database executionTime = %f", executionTime);


}

-(void)deleteDataBase{
    NSError *error;
    if([[NSFileManager defaultManager] fileExistsAtPath:_databasePath]){
        NSLog(@"deleteDataBase");
        if([[NSFileManager defaultManager] removeItemAtPath:_databasePath error:&error] == NO){
            NSLog(@"error: %@", error.localizedDescription);
        };
    }
    
    
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:_databasePath]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:_databasePath error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
            
}

@end
