//
//  ZHDatabaseStatement.m
//
//  Created by Matthew Sinclair-Day on 5/30/09.
//  Copyright 2015 Ming Fu Design Inc 明孚設計有限公司. All rights reserved.
//  Permission is granted to Securifi Ltd. to include and distribute source in their iOS products.
//

#import "ZHDatabaseStatement.h"

@interface ZHDatabaseStatement ()
@property(nonatomic, copy) NSString *sql;
@property(nonatomic, strong) ZHDatabase *database;
@property(nonatomic) sqlite3_stmt *stmt;
@property(nonatomic) int currentBinding;
@property(nonatomic) int currentStep;
@end

@implementation ZHDatabaseStatement

#pragma mark -
#pragma mark Lifecycle methods

- (id)initWithDb:(ZHDatabase *)aDatabase sql:(NSString *)aSqlExpression {
    self = [super init];
    if (self) {
        _stmt = nil;
        self.sql = aSqlExpression;
        self.database = aDatabase;

        int result_code = sqlite3_prepare_v2(aDatabase.database, [self.sql UTF8String], -1, &_stmt, NULL);
        if (result_code != SQLITE_OK) {
            int ext_result_code = sqlite3_extended_errcode(aDatabase.database);
            const char *msg = sqlite3_errmsg(aDatabase.database);
            NSLog(@"Error: %d (%d) : failed to prepare statement '%@' with message '%s'.", result_code, ext_result_code, self.sql, msg);
            NSAssert4(0, @"Error: %d (%d) : failed to prepare statement '%@' with message '%s'.", result_code, ext_result_code, self.sql, msg);
        }

        [self resetBinding];
        [self resetStep];
    }

    return self;
}

- (void)dealloc {
    if (_stmt != nil) {
        [self reset];
        sqlite3_finalize(_stmt);
        _stmt = nil;
    }
}

#pragma mark -
#pragma mark Public methods

- (void)reset {
    [self resetBinding];
    [self resetStep];
    sqlite3_reset(self.stmt);
}

- (void)bindNextInteger:(NSInteger)value {
    int pos = [self nextBinding];
    int rc = sqlite3_bind_int(self.stmt, pos, (int) value);
    if (rc != SQLITE_OK) {
        [self checkErrors:rc];
    }
}

- (void)bindNextDouble:(double)value {
    int pos = [self nextBinding];
    int rc = sqlite3_bind_double(self.stmt, pos, value);
    if (rc != SQLITE_OK) {
        [self checkErrors:rc];
    }
}

- (void)bindNextBool:(BOOL)value {
    NSInteger int_val = value ? 1 : 0;
    [self bindNextInteger:int_val];
}

- (void)bindNextTimeInterval:(NSTimeInterval)value {
    int pos = [self nextBinding];
    int rc = sqlite3_bind_double(self.stmt, pos, value);
    if (rc != SQLITE_OK) {
        [self checkErrors:rc];
    }
}

- (void)bindNextText:(NSString *)value {
    int pos = [self nextBinding];
    int rc = sqlite3_bind_text(self.stmt, pos, [value UTF8String], -1, SQLITE_TRANSIENT);
    if (rc != SQLITE_OK) {
        [self checkErrors:rc];
    }
}

- (void)bindNextTextEncode:(NSString *)value {
    NSString *sanitized = [ZHDatabase encodeInput:value];
    [self bindNextText:sanitized];
}

- (BOOL)execute {
    [self resetStep];
    int rc = sqlite3_step(self.stmt);

    BOOL success = (rc == SQLITE_DONE);
    if (!success) {
        [self checkErrors:rc];
    }

    [self reset];
    return success;
}

- (NSArray *)executeReturnArray {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:10];
    while ([self step]) {
        NSString *value = [self stepNextString];
        [result addObject:value];
    }

    [self reset];

    return result;
}

- (NSInteger)executeReturnInteger {
    NSInteger count = 0;
    if ([self step]) {
        count = [self stepNextInteger];
    }
    [self reset];
    return count;
}

- (BOOL)executeReturnBool {
    BOOL b = NO;
    if ([self step]) {
        b = [self stepNextBool];
    }
    [self reset];
    return b;
}


- (BOOL)step {
    [self resetStep];
    int rc = sqlite3_step(self.stmt);
    BOOL success = (rc == SQLITE_ROW);
    BOOL done = (rc == SQLITE_DONE);
    if (!success && !done) {
        [self checkErrors:rc];
    }
    return success;
}

- (NSInteger)stepNextInteger {
    return [self stepInteger:[self nextStep]];
}

- (double)stepNextDouble {
    return [self stepDouble:[self nextStep]];
}

- (NSTimeInterval)stepNextTimeInterval {
    return [self stepDouble:[self nextStep]];
}

- (BOOL)stepNextBool {
    return [self stepNextInteger] == 1;
}

- (NSString *)stepNextString {
    return [self stepString:[self nextStep]];
}

- (double)stepDouble:(NSInteger)pos {
    return sqlite3_column_double(self.stmt, (int) pos);
}

- (NSInteger)stepInteger:(NSInteger)pos {
    return sqlite3_column_int(self.stmt, (int) pos);
}

- (NSString *)stepString:(NSInteger)pos {
    char *val = (char *) sqlite3_column_text(self.stmt, (int) pos);
    if (val == nil) {
        return [NSString string];
    }
    return [NSString stringWithUTF8String:val];
}

#pragma mark -
#pragma mark Private methods

- (int)nextBinding {
    self.currentBinding++;
    return self.currentBinding;
}

- (void)resetBinding {
    self.currentBinding = 0;
}

- (NSInteger)nextStep {
    self.currentStep++;
    return self.currentStep;
}

- (void)resetStep {
    self.currentStep = -1; // stepping is zero based unless binding which is 1 based...
}

- (void)checkErrors:(int)rc {
    sqlite3 *db = self.database.database;
    if (!db) {
        return;
    }

    int ext_result_code = sqlite3_extended_errcode(db);
    const char *msg = sqlite3_errmsg(db);
    NSLog(@"Error: %d (%d) : failed executing '%@' with message '%s'.", rc, ext_result_code, self.sql, msg);
}

@end
