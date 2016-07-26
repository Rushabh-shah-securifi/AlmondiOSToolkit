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
    //NSLog(@"createDataBasePath");
    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: dbPath]];
   
}


+(void)setHistoryTable{
    NSFileManager *filemgr = [NSFileManager defaultManager];
     //NSLog(@"database path = %@",databasePath);
    if ([filemgr fileExistsAtPath: databasePath ] == NO){
        [self createTable:@"CREATE TABLE IF NOT EXISTS HistoryTB (DATE TEXT,UNIQUEKEY TEXT,AMAC TEXT,CMAC TEXT, URIS TEXT,COUNT TEXT,TIME TEXT)"];
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
        NSLog(@"Error: was not able to load json file: %@.",fileName);
    }
    return data;
}
+(void)updateHistory:(NSDictionary *)updateDict{
    NSString *updateSQL = [NSString stringWithFormat: @"UPDATE HistoryTB SET COUNT = ?, WHERE AMAC = ?,CMAC = ?, DATE = ?" ];
}



+ (NSDictionary *)getSearchString:(NSString *)searchPatten andSearchSting:(NSString *)search{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" AND URIS LIKE  '%%%@%%'  ORDER BY TIME DESC",@"251176215905264",@"14:30:c6:46:b7:15",search];
        sqlite3_stmt *compiledStatement;
    
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement searchPatten:searchPatten andSearchSting:search];
        NSLog(@"search ddict %@",dict);
    return dict;
    }
    
}
+ (NSDictionary *)getAllBrowsingHistory{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ORDER BY TIME DESC",@"251176215905264",@"14:30:c6:46:b7:15"];
        sqlite3_stmt *compiledStatement;
        
        NSDictionary *dict = [self prepareMethod:compiledStatement andsqlStatement:sqlStatement searchPatten:@"All" andSearchSting:@""];
        NSLog(@"search ddict %@",dict);
        return dict;
    }
    
}
+ (NSDictionary *)getManualString:(NSString *)searchPatten andSearchSting:(NSString *)search{
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
         NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ORDER BY TIME DESC",@"251176215905264",@"14:30:c6:46:b7:15"];
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
        NSMutableDictionary *dayDict = [NSMutableDictionary new];
        NSLog(@"success msg %s",sqlite3_errmsg(database));
        while (sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            NSString *uriString0 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 0)];
            if([[dayDict allKeys] containsObject:uriString0]){
                
            }
            NSString *uriString1 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 1)];
            
            
            NSString *uriString4 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 4)];
            NSLog(@"uriString4 %@",uriString4);
            NSString *uriString5 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 5)];
            NSLog(@"uriString5 %@",uriString5);
            NSString *uriString6 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 6)];
            NSLog(@"uriString6 %@",uriString6);
            NSDictionary *uriInfo = @{@"hostName":uriString4,
                                      @"Epoc":uriString6,
                                      @"count":uriString5
                                      };
            if([self isToaddDict:uriString6 searchPatten:searchPatten andSearchString:search])
            [self addToDictionary:dayDict uriInfo:uriInfo rowID:uriString0];
        }
        
        [clientBrowsingHistory setObject:dayDict forKey:@"Data"];
        
    }
    else{
        NSLog(@"errMSg %s",sqlite3_errmsg(database));
    }
    sqlite3_close(database);
    return clientBrowsingHistory;
}
+(BOOL)isToaddDict:(NSString *)timeEpoc searchPatten:(NSString *)searchPatten andSearchString:(NSString *)search{
    NSLog(@"searchPatten %@,search %@",searchPatten,search);
    if([searchPatten isEqualToString:@"All"])
        return YES;
    
    else if ([searchPatten isEqualToString:@"Today"]){
        return [BrowsingHistoryUtil isTodaySearch:timeEpoc];
    }
    else if ([searchPatten isEqualToString:@"weekDay"]){
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
//+(NSDictionary *)getHistory{
////    [self createHistoryTable:HISTORY_TABLE];
//    NSMutableDictionary *clientBrowsingHistory = [[NSMutableDictionary alloc]init];
//    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
//    {
//    NSString *sqlStatement =[NSString stringWithFormat: @"SELECT * from HistoryTB WHERE AMAC = \"%@\" AND CMAC = \"%@\" ORDER BY TIME DESC",@"251176215905264",@"14:30:c6:46:b7:15"];
//         sqlite3_stmt *compiledStatement;
//       
//        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK){
//            if (sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                NSString *uriString3 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 3)];
//                
//                NSString *uriString2 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 2)];
//                [clientBrowsingHistory setValue:uriString2 forKey:@"clientMac"];
//                [clientBrowsingHistory setValue:uriString3 forKey:@"almondMac"];
//                
//            
//            }
//             NSMutableDictionary *dayDict = [NSMutableDictionary new];
//             NSLog(@"success msg %s",sqlite3_errmsg(database));
//            while (sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                NSString *uriString0 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 0)];
//                if([[dayDict allKeys] containsObject:uriString0]){
//                    
//                }
//                NSString *uriString1 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 1)];
//
//                
//                NSString *uriString4 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 4)];
//                NSLog(@"uriString4 %@",uriString4);
//                NSString *uriString5 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 5)];
//                NSLog(@"uriString5 %@",uriString5);
//                NSString *uriString6 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(compiledStatement, 6)];
//                NSLog(@"uriString6 %@",uriString6);
//                NSDictionary *uriInfo = @{@"hostName":uriString4,
//                                          @"Epoc":uriString6,
//                                          @"count":uriString5
//                                          };
//                
//                [self addToDictionary:dayDict uriInfo:uriInfo rowID:uriString0];
//            }
//
//            [clientBrowsingHistory setObject:dayDict forKey:@"Data"];
//            
//        }
//        else{
//            NSLog(@"errMSg %s",sqlite3_errmsg(database));
//        }
//    }
//    sqlite3_close(database);
//    return clientBrowsingHistory;
//}
+ (void)addToDictionary:(NSMutableDictionary *)rowIndexValDict uriInfo:(NSDictionary *)uriInfo rowID:(NSString *)day{
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

+(void)insertHistoryRecord:(NSDictionary *)hDict{
    NSString *query = @"INSERT INTO HistoryTB (DATE,UNIQUEKEY,AMAC,CMAC, URIS,COUNT,TIME) VALUES(?,?,?,?,?,?,?)";
    [self setHistoryTable];
    [self insertHistoryEntries:hDict query:query];
}
+ (void)insertHistoryEntries:(NSDictionary *)hDict query:(NSString *)query{
    sqlite3_stmt *statement;
    
    //NSLog(@"dict = %@",hDict);
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *insert_stmt = [query UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        NSArray *allDate = hDict[@"Data"];
        //NSLog(@"allDate %@",allDate);
        for(NSDictionary *dayDict in allDate)
        {
            NSString *date = dayDict[@"Date"];
            NSArray *uriArr = dayDict[@"URIs"];
            for(NSDictionary *uriObj in uriArr)
                {
                    //NSLog(@"uriObj %@",uriObj);

                    sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
                    //NSLog(@"fail to sqlite3_prepare_v2 %s",sqlite3_errmsg(database));
                    sqlite3_bind_text(statement, 1, [date UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 2, [uriObj[@"key"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 3, [hDict[@"almondMAC"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 4, [hDict[@"clientMAC"] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(statement, 5, [uriObj[@"Hostname"] UTF8String], -1, SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(statement, 6, [[NSString stringWithFormat:@"%@",uriObj[@"Count"]] UTF8String], -1, SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(statement, 7, [[NSString stringWithFormat:@"%@",uriObj[@"Epoch"]] UTF8String], -1, SQLITE_TRANSIENT);
                    if (sqlite3_step(statement) == SQLITE_DONE){
                        NSLog(@" successS");
                    }
                    else {
                        NSLog(@" errorSS");
                    }
                }
        }

        sqlite3_close(database);
    }
    else{
        NSLog(@"fail to open %s",sqlite3_errmsg(database));
    }
    
}
@end
