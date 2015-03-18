//
//  ZHDatabase.h
//
//  Created by Matthew Sinclair-Day on 4/18/09.
//  Copyright 2015 Ming Fu Design Inc 明孚設計有限公司. All rights reserved.
//  Permission is granted to Securifi Ltd. to include and distribute source in their iOS products.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class ZHDatabaseStatement;


@interface ZHDatabase : NSObject

// Opaque reference to the SQLite immutable database.
@property(readonly, nonatomic) sqlite3 *database;

// Sanitizes a value, protecting against SQL injection attacks.
// All strings sent to the database should be sanitized.
+ (NSString *)sanitize:(NSString *)aInputStr;

// can be used by internal search pieces to cleanup strings before they are used to construct SQL queries;
// used to clean up user supplied inputs
+ (NSString *)encodeInput:(NSString *)aInputStr;

// inverse op of encodeInput:
+ (NSString *)decodeInput:(NSString *)aInputStr;

// Initializes with path to the primary database
- (id)initWithPath:(NSString *)aPathToDb;

// Called when initializing the user's db. Establishes attachment to zhentries db
// which is needed for searches
- (void)attachToDb:(NSString *)attachDbPath alias:(NSString *)dbAlias;

// Makes a new prepared statement; when the caller is done, it must be released; must be released before this database is
- (ZHDatabaseStatement *)newStatement:(NSString *)sql;

// Execute the supplied sql; returns true when no errors
- (BOOL)execute:(NSString *)sql;

// Execute the supplied sql; returns the number of changes caused by the sql
- (NSInteger)executeReturnChanges:(NSString *)sql;

// execute the select sql returning the first column's value, which must be integer value
- (NSInteger)executeReturnInteger:(NSString *)sql;

// Returns YES if the database needs to be vacuumed
- (BOOL)needsVacuuming;

// Vacuums the database, compacting it and making it more efficient.
// This method blocks until the operation is completed. This method may block for a long time.
- (void)vacuum;

- (void)markRuntTimeSinceLastVacuum;

- (BOOL)copyTo:(NSString *)filePath;

@end
