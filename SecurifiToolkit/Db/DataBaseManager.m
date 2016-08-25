//
//  DataBaseManager.m
//  JSONParsingAndSqliteDataBase
//
//  Created by Masood on 17/02/16.
//  Copyright © 2016 Masood. All rights reserved.
//

#import "DataBaseManager.h"
#import <sqlite3.h>


#define DATABASE_FILE @"devices.db"

#define DEVICE_TABLE @"devices"
#define DEVICE_INDEX_TABLE @"deviceIndexes"
#define HISTORY_TABLE @"historyTable"
#define HISTORYTABLE @"HistoryTB"

@interface DataBaseManager()

@end

@implementation DataBaseManager
static NSString *databasePath;
static DataBaseManager *dbSharedInstance = nil;
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
    [self setupDB];
    [self setUpHistoryDB];
}

+(void)createDataBasePath:(NSString*)dbPath{
    NSLog(@"createDataBasePath");
    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: dbPath]];
}


+(void)setupDB{
    NSLog(@"createDB");
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        [self createTable:@"CREATE TABLE IF NOT EXISTS devices (ID INTEGER PRIMARY KEY, DATA TEXT)"];
        [self createTable:@"CREATE TABLE IF NOT EXISTS deviceIndexes (ID INTEGER PRIMARY KEY, DATA TEXT)"];
    }
    NSDictionary *devicesJson = [self parseJson:@"deviceListJson"];
    NSDictionary *deviceIndexesJson = [self parseJson:@"GenericIndexesData"];

    [self insertData:devicesJson query:@"INSERT INTO devices (id,data) VALUES(?,?)"];
    [self insertData:deviceIndexesJson query:@"INSERT INTO deviceIndexes (id,data) VALUES(?,?)"];
}

+(void)setUpHistoryDB{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        [self createTable:@"CREATE TABLE IF NOT EXISTS historyTable (DATE TEXT PRIMARY KEY, URIS TEXT)"];
    }
//     NSDictionary *devicesJson = [self parseJson:@"temp_copy"];
//    [self insertData:devicesJson query:@"INSERT INTO historyTable (date,uris) VALUES(?,?)"];

}
+(void)setHistoryTable{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        [self createTable:@"CREATE TABLE IF NOT EXISTS HistoryTB (DATE TEXT,UNIQUE TEXT,AMAC TEXT,CMAC TEXT, URIS TEXT,COUNT TEXT,TIME TEXT)"];
    }
}


+(BOOL)createTable:(NSString*)query{
    BOOL isSuccess = YES;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = [query UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
            isSuccess = NO;
            NSLog(@"Failed to create table");
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
        NSLog(@"Error: was not able to load json file: %@.",fileName);
    }
    return data;
}
+(void)insertHistoryRecord:(NSDictionary *)hDict{
    NSString *query = @"INSERT INTO HistoryTB (DATE,UNIQUE,AMAC,CMAC, URIS,COUNT,TIME) VALUES(?,?,?,?,?,?)";
    [self insertHistoryData:hDict query:query];
}
+ (void)insertHistoryEntries:(NSDictionary *)hDict query:(NSString *)query{
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *insert_stmt = [query UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        for (NSDictionary *dateDict  in hDict[@"Data"])
        {
            for (NSString *date in [dateDict allKeys])
            {
                NSArray *uriArr = dateDict[date];
                
                for(NSDictionary *uriObj in uriArr)
                {
                    sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
                    sqlite3_bind_text(statement, 1, [date UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 2, [hDict[@"UNIQUE"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 3, [hDict[@"AMAC"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 4, [hDict[@"CMAC"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 5, [uriObj[@"URIS"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 6, [uriObj[@"COUNT"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 7, [uriObj[@"TIME"] UTF8String], -1, SQLITE_TRANSIENT);
                        if (sqlite3_step(statement) == SQLITE_DONE){
                            NSLog(@" success");
                        }
                        else {
                            NSLog(@" error");
                        }
                    
                }
            }
            
        }
      sqlite3_close(database);
    }

}

+ (void)insertData:(NSDictionary*)deviceIndexDict query:(NSString*)query
{   NSLog(@"deviceIndexDict = %@",deviceIndexDict);
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *insert_stmt = [query UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        for(NSString *indexID in [deviceIndexDict allKeys]){
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:[deviceIndexDict valueForKey:indexID] options:0 error:nil];
            NSString * indexData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
            sqlite3_bind_text(statement, 1, [indexID UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [indexData UTF8String],-1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@" success");
            }
            else {
                NSLog(@" error");
            }
        }
        sqlite3_close(database);
    }else {
        NSLog(@"Failed to open/create database");
    }
}

+ (NSDictionary*)findByID:(NSString*)ID fromTable:(NSString*)table{
    [self createTableIfNeeded:table];
    
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select data from \"%@\" where id=\"%@\"",table, ID];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *indexDetail = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                NSData *data = [indexDetail dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *indexDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                return indexDict;
            }
            else{
                NSLog(@"Not found - need to put entry in table");
                
            }
            sqlite3_close(database);
        }
    }
    return @{};
}
+ (NSDictionary*)getHistory:(NSString*)table byDate:(NSString *)date{
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        {
            NSString *querySQL = [NSString stringWithFormat:@"select uris from \"%@\" where date=\"%@\"",table,date];
            const char *query_stmt = [querySQL UTF8String];
            if (sqlite3_prepare_v2(database,query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *indexDetail = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    NSData *data = [indexDetail dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *indexDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    return indexDict;
                }
                else{
                    NSLog(@"Not found - need to put entry in table");
                    
                }
                sqlite3_close(database);
            }
        }
    }
    return @{};
}


+ (void)createTableIfNeeded:(NSString*)table{
    NSString *query_stmt = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"%@\"(ID INTEGER PRIMARY KEY, DATA TEXT)", table];
    if(![self createTable:query_stmt]){
        if([[table lowercaseString] isEqualToString:DEVICE_TABLE]){
            NSDictionary* deviceData = [self parseJson:@"deviceListJson"];
            [self insertData:[deviceData valueForKey:@"commandtype"] query:query_stmt];
        }else if([[table lowercaseString] isEqualToString:DEVICE_INDEX_TABLE]){
            NSDictionary* deviceIndexData = [self parseJson:@"GenericIndexesData"];
            [self insertData:[deviceIndexData valueForKey:@"commandtype"] query:query_stmt];
        }
    }
}
+ (void)createHistoryTable:(NSString *)table{
     NSString *query_stmt = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS historyTable (DATE TEXT PRIMARY KEY, URIS TEXT)", table];
    NSLog(@"query_stmt = %@",query_stmt);
    if(![self createTable:query_stmt]){
        NSLog(@"SUCCESS table created");
    }
    else{
        NSLog(@"FAIL to create table");
    }
}

+ (NSMutableDictionary*)getDevicesForIds:(NSArray*)deviceIds{
    NSMutableDictionary *devices = [[NSMutableDictionary alloc]init];
    for(NSString *ID in deviceIds){
        [devices setValue:[self findByID:ID fromTable:DEVICE_TABLE] forKey:ID];
    }
    return  devices;
}


+ (NSMutableDictionary*)getDeviceIndexesForIds:(NSArray*)indexIds{
    NSMutableDictionary *deviceIndexes = [[NSMutableDictionary alloc]init];
    for(NSString *ID in indexIds){
        [deviceIndexes setValue:[self findByID:ID fromTable:DEVICE_INDEX_TABLE] forKey:ID];
    }
    return  deviceIndexes;
}
+ (NSMutableDictionary*)getHistory:(NSArray *)dateArr{
    NSMutableDictionary *history = [[NSMutableDictionary alloc]init];
    for(NSString *date in dateArr){
        [history setValue:[self getHistory:HISTORY_TABLE byDate:date] forKey:date];
    }
    return  history;
}

+ (void)deleteTable{
    NSLog(@"deleteTable");
    NSString *query = @"DROP TABLE historyTable";
    const char *sqlStatement = [query UTF8String];
    const char *dbpath = [databasePath UTF8String];
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
}


+ (void)deleteDataBase{
    NSError *error;
    
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:databasePath]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
    
}
+ (void)hisTable{
    
    NSString *docDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    docDir = dirPaths[0];
    
    databasePath = [[NSString alloc]initWithString:[docDir stringByAppendingPathComponent:@"MyHistory.DB"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:databasePath]==NO){
        const char *dbPath = [databasePath UTF8String];
        if (sqlite3_open(dbPath, &DB) == SQLITE_OK){
            char *errmsg;
            const char *statement = "CREATE TABLE IF NOT EXISTS history(DATE TEXT PRIMARY KEY, URIS TEXT)";
            if(sqlite3_exec(DB, statement, NULL, NULL, errmsg)==SQLITE_OK){
                NSLog(@"success created");
            }
            else{
                NSLog(@"not created");
            }
            sqlite3_close(DB);
        }
    }
        
    
}
+ (void)InsertRecords:(NSDictionary *)dict
{
    [self insertHistoryData:dict query:@"INSERT INTO historyTable (date,uris) VALUES(?,?)"];
    
}

+ (void)insertHistoryData:(NSDictionary*)dict query:(NSString*)query
{
//     [self createDataBasePath:DATABASE_FILE];
    [self createHistoryTable:HISTORY_TABLE];
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    NSLog(@"dict == %@",dict);
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *insert_stmt = [query UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
       
        for(NSString *indexID in [dict allKeys]){
           
            NSError *err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:[dict valueForKey:indexID] options:0 error:&err];
            NSLog(@"err errormsg %@",err);
//            NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:[dict valueForKey:indexID]];
            NSString * indexData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"index data = %@",indexData);
            if(sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL)!=SQLITE_OK);
            NSLog(@"error  --'%s'", sqlite3_errmsg(database));
            sqlite3_bind_text(statement, 1, [indexID UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [indexData UTF8String],-1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@" success history");
            }
            else {
                NSLog(@" error history" @"'%s'", sqlite3_errmsg(database));
            }
        }
        sqlite3_close(database);
    }else {
        NSLog(@"Failed to open/create database");
    }
}
+ (NSDictionary *)getHistoryData
{
     [self createHistoryTable:HISTORY_TABLE];
    NSLog(@"getHistory data method");
    char *err;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement = @"SELECT * FROM historyTable";  // Your Tablename
        NSMutableDictionary *historyDict = [[NSMutableDictionary alloc]init];
        sqlite3_stmt *compiledStatement;
        NSLog(@"getHistory data method %@ ,%@",sqlStatement,databasePath);
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, err) == SQLITE_OK)
        {
            NSLog(@"sqlite3_prepare_v2 method");
            while (sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                 NSLog(@"sqlite3_step method");
                NSString *uriString = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 1)];
                 NSLog(@"indexDetail %@",uriString);
                NSData *data = [uriString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *uriDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"historyDict %@",uriDict);
                
                
                NSString *dateKey = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 0)];
                NSLog(@"indexDetail %@",dateKey);

                [historyDict setValue:uriDict forKey:dateKey];
                NSLog(@"historyDict %@",uriDict);
                
            }

        }
        else
            NSLog(@"fail to read %s",err);
        NSLog(@"history allKeys count %ld",[historyDict allKeys].count);
        return historyDict;
        sqlite3_finalize(compiledStatement);
    }
    NSLog(@"fail to get database ");
    sqlite3_close(database);
}
+ (void)updateDB:(NSString *)date with:(NSDictionary *)dict{
    [self createHistoryTable:HISTORY_TABLE];
    NSLog(@"getHistory data method");
    NSError *err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:[dict valueForKey:date] options:0 error:&err];
    NSLog(@"err errormsg %@",err);
    //            NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:[dict valueForKey:indexID]];
    NSString * uriString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"index data = %@",uriString);
    
    sqlite3_stmt *statement;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSLog(@"Exitsing data, Update Please");
        NSString *qury = [NSString stringWithFormat:@"UPDATE historyTable set uris = '%@' WHERE date = ?",uriString];
        const char *update_stmt = [qury UTF8String];
        sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL );
        sqlite3_bind_text(statement, 1, [date UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"Update Success");
        }
        else
            NSLog(@"upade fail");
         sqlite3_finalize(statement);
    
    }
    sqlite3_close(database);
    
    
}
+ (void)deleteHistoryTable{
    NSString *query = @"DELETE from historyTable";
    const char *sql = [query cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *statement = nil;
    if(sqlite3_prepare_v2(database,sql, -1, &statement, NULL)!= SQLITE_OK)
    {
        NSAssert1(0,@"error preparing statement",sqlite3_errmsg(database));
        NSLog(@"not deleted");
    }
    else
    {
        sqlite3_step(statement);
        NSLog(@"successFully deleted");
    }
    sqlite3_finalize(statement);
    
}
@end
