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

/*
From: https://www.sqlite.org/backup.html

** Perform an online backup of database pDb to the database file named
** by zFilename. This function copies 5 database pages from pDb to
** zFilename, then unlocks pDb and sleeps for 250 ms, then repeats the
** process until the entire database is backed up.
**
** The third argument passed to this function must be a pointer to a progress
** function. After each set of 5 pages is backed up, the progress function
** is invoked with two integer parameters: the number of pages left to
** copy, and the total number of pages in the source file. This information
** may be used, for example, to update a GUI progress bar.
**
** While this function is running, another thread may use the database pDb, or
** another process may access the underlying database file via a separate
** connection.
**
** If the backup process is successfully completed, SQLITE_OK is returned.
** Otherwise, if an error occurs, an SQLite error code is returned.
*/
int backupDb(
        sqlite3 *pDb,               /* Database to back up */
        const char *zFilename,      /* Name of file to back up to */
        void(*xProgress)(int, int)  /* Progress function to invoke */
);

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
            char const *err_msg = sqlite3_errmsg(_database);
            sqlite3_close(_database);
            NSAssert2(0, @"Failed to open database from '%@', with message '%s'.", databasePath, err_msg);
            // Additional error handling, as appropriate...
            _database = nil;
        }
    }

    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
    _database = nil;
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

- (BOOL)copyTo:(NSString*)filePath {
    if (!filePath) {
        return NO;
    }
    char const *fileName = [filePath UTF8String];
    int result = backupDb(self.database, fileName, nil);
    return result == SQLITE_OK;
}

/*
From: https://www.sqlite.org/backup.html

** Perform an online backup of database pDb to the database file named
** by zFilename. This function copies 5 database pages from pDb to
** zFilename, then unlocks pDb and sleeps for 250 ms, then repeats the
** process until the entire database is backed up.
**
** The third argument passed to this function must be a pointer to a progress
** function. After each set of 5 pages is backed up, the progress function
** is invoked with two integer parameters: the number of pages left to
** copy, and the total number of pages in the source file. This information
** may be used, for example, to update a GUI progress bar.
**
** While this function is running, another thread may use the database pDb, or
** another process may access the underlying database file via a separate
** connection.
**
** If the backup process is successfully completed, SQLITE_OK is returned.
** Otherwise, if an error occurs, an SQLite error code is returned.
*/
int backupDb(
        sqlite3 *pDb,               /* Database to back up */
        const char *zFilename,      /* Name of file to back up to */
        void(*xProgress)(int, int)  /* Progress function to invoke */
){
    int rc;                     /* Function return code */
    sqlite3 *pFile;             /* Database connection opened on zFilename */
    sqlite3_backup *pBackup;    /* Backup handle used to copy data */

    /* Open the database file identified by zFilename. */
    rc = sqlite3_open(zFilename, &pFile);
    if( rc==SQLITE_OK ){

        /* Open the sqlite3_backup object used to accomplish the transfer */
        pBackup = sqlite3_backup_init(pFile, "main", pDb, "main");
        if( pBackup ){

            /* Each iteration of this loop copies 5 database pages from database
            ** pDb to the backup database. If the return value of backup_step()
            ** indicates that there are still further pages to copy, sleep for
            ** 250 ms before repeating. */
            do {
                rc = sqlite3_backup_step(pBackup, 5);
                if (xProgress) {
                    xProgress(
                            sqlite3_backup_remaining(pBackup),
                            sqlite3_backup_pagecount(pBackup)
                    );
                }
                if( rc==SQLITE_OK || rc==SQLITE_BUSY || rc==SQLITE_LOCKED ){
                    sqlite3_sleep(250);
                }
            } while( rc==SQLITE_OK || rc==SQLITE_BUSY || rc==SQLITE_LOCKED );

            /* Release resources allocated by backup_init(). */
            (void)sqlite3_backup_finish(pBackup);
        }
        rc = sqlite3_errcode(pFile);
    }

    /* Close the database connection opened on database file zFilename
    ** and return the result of this function. */
    (void)sqlite3_close(pFile);
    return rc;
}

@end
