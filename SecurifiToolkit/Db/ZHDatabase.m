//
//  ZHDatabase.m
//
//  Created by Matthew Sinclair-Day on 4/18/09.
//  Copyright 2015 Ming Fu Design Inc 明孚設計有限公司. All rights reserved.
//  Permission is granted to Securifi Ltd. to include and distribute source in their iOS products.
//

#import "ZHDatabase.h"
#import "ZHDatabaseStatement.h"

#define PREF_RUN_TIMES_SINCE_LAST_VACUUM @"zhdatabase_runTimesSinceLastVacuum"

@interface ZHDatabase ()
- (void)setLastCallbackValue:(char *)aValue;
@end

@implementation ZHDatabase {
@private
    NSString *databasePath;
    NSString *last_callbackVal;
}

+ (NSString *)sanitize:(NSString *)aInputStr {
    //(replaceAll "/[\\s'\";#%]/" "")
    NSString *sanitized;
    sanitized = [aInputStr stringByReplacingOccurrencesOfString:@"'" withString:@""]; // escape ' => ''
    sanitized = [sanitized stringByReplacingOccurrencesOfString:@"\"" withString:@""]; // escape " => \"
    return sanitized;
}

+ (NSString *)encodeInput:(NSString *)aInputStr {
    //(replaceAll "/[\\s'\";#%]/" "")
    NSString *sanitized;
    sanitized = [aInputStr stringByReplacingOccurrencesOfString:@"'" withString:@"\'\'"]; // escape ' => ''
    sanitized = [sanitized stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""]; // escape " => \"
    return sanitized;
}

+ (NSString *)decodeInput:(NSString *)aInputStr {
    //(replaceAll "/[\\s'\";#%]/" "")
    NSString *inverse;
    inverse = [aInputStr stringByReplacingOccurrencesOfString:@"\'\'" withString:@"'"]; // escape ' => ''
    inverse = [inverse stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""]; // escape " => \"
    return inverse;
}

// sqlite3_open_v2(path, &database, SQLITE_OPEN_READONLY, NULL /*VFS module: use default*/);

- (id)initWithPath:(NSString *)aPathToDb {
    self = [super init];
    if (self) {
        databasePath = [aPathToDb copy];
        // Open the database
        if (sqlite3_open([databasePath UTF8String], &_database) != SQLITE_OK) {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(_database);
            NSAssert2(0, @"Failed to open database from '%@', with message '%s'.", databasePath, sqlite3_errmsg(_database));
            // Additional error handling, as appropriate...
        }
    }

    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
}

- (void)attachToDb:(NSString *)attachDbPath alias:(NSString *)dbAlias {
    NSString *sql = [NSString stringWithFormat:@"attach database '%@' as %@", attachDbPath, dbAlias];
    [self execute:sql];
}

- (ZHDatabaseStatement *)newStatement:(NSString *)theSql {
    return [[ZHDatabaseStatement alloc] initWithDb:self sql:theSql];
}

// sets last callback value
int callback(void *dbPtr, int argCount, char **argVector, char **azColName) {
    ZHDatabase *db = (__bridge ZHDatabase *) dbPtr;

    if (argCount == 0) {
        [db setLastCallbackValue:nil];
    }
    else {
        [db setLastCallbackValue:argVector[0]];
    }

    return 0;
}


- (BOOL)execute:(NSString *)sql {
    return [self internalExecute:sql doCallback:NO];
}

- (NSInteger)executeReturnChanges:(NSString *)sql {
    [self internalExecute:sql doCallback:NO];
    return sqlite3_changes(self.database);
}


- (NSInteger)executeReturnInteger:(NSString *)sql {
    BOOL success = [self internalExecute:sql doCallback:YES];
    if (!success) {
        return 0;
    }

    if (last_callbackVal == nil || [last_callbackVal length] == 0) {
        return 0;
    }

    return [last_callbackVal integerValue];
}

#pragma mark -
#pragma mark Database maintenance

- (BOOL)needsVacuuming {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numTimesSinceLastVacuum = [defaults integerForKey:PREF_RUN_TIMES_SINCE_LAST_VACUUM];
    return numTimesSinceLastVacuum > 5;
}

- (void)vacuum {
    // "VACUUM only works on the main database. It is not possible to VACUUM an attached database file."
    // "The VACUUM command may change the ROWIDs of entries in any tables that do not have an explicit INTEGER PRIMARY KEY."
    [self internalExecute:@"VACUUM" doCallback:NO];
    [self resetRuntTimeSinceLastVacuum];
}

- (void)markRuntTimeSinceLastVacuum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numTimesSinceLastVacuum = [defaults integerForKey:PREF_RUN_TIMES_SINCE_LAST_VACUUM];
    numTimesSinceLastVacuum++;
    [defaults setInteger:numTimesSinceLastVacuum forKey:PREF_RUN_TIMES_SINCE_LAST_VACUUM];
    [defaults synchronize];
}

- (void)resetRuntTimeSinceLastVacuum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numTimesSinceLastVacuum = 0;
    [defaults setInteger:numTimesSinceLastVacuum forKey:PREF_RUN_TIMES_SINCE_LAST_VACUUM];
    [defaults synchronize];
}

#pragma mark -
#pragma mark Private methods

- (BOOL)internalExecute:(NSString *)sql doCallback:(BOOL)callbackYesNo {
    [self setLastCallbackValue:nil];

    DLog(@"Executing sql %@", sql);

    if ([self _exec:sql callbackYesNo:callbackYesNo]) {
        return YES;
    }

    NSLog(@"Trying to rollback");

    if ([self _exec:@"ROLLBACK;" callbackYesNo:callbackYesNo]) {
        NSLog(@"Success on rollback");
        return YES;
    }
    else {
        NSLog(@"Failed on rollback");
        return NO;
    }
}

- (BOOL)_exec:(NSString *)aSqlToExecute callbackYesNo:(BOOL)callbackYesNo {
    char *zErrMsg = 0;
    int rc;

    if (callbackYesNo) {
        rc = sqlite3_exec(self.database, [aSqlToExecute UTF8String], callback, (__bridge void *)(self), &zErrMsg);
    }
    else {
        rc = sqlite3_exec(self.database, [aSqlToExecute UTF8String], NULL, NULL, &zErrMsg);
    }

    if (rc == SQLITE_OK) {
        return YES;
    }

    NSLog(@"Failed to execute sql %@ with message '%s'", aSqlToExecute, zErrMsg);
    /* This will free zErrMsg if assigned */
    if (zErrMsg) {
        sqlite3_free(zErrMsg);
    }

    return NO;
}

- (void)setLastCallbackValue:(char *)aValue {
    if (aValue == nil) {
        last_callbackVal = nil;
        return;
    }

    last_callbackVal = [[NSString alloc] initWithUTF8String:aValue];
}

@end
