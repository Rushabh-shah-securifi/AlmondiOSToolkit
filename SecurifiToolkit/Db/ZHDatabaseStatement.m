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
        int result_code = sqlite3_prepare_v2(aDatabase.database, [self.sql UTF8String], -1, &_stmt, NULL);
        if (result_code != SQLITE_OK) {
            int ext_result_code = sqlite3_extended_errcode(aDatabase.database);
            const char *msg = sqlite3_errmsg(aDatabase.database);
            NSLog(@"Error: %d (%d) : failed to prepare statement '%@' with message '%s'.", result_code, ext_result_code, self.sql, msg);
            NSAssert4(0, @"Error: %d (%d) : failed to prepare statement '%@' with message '%s'.", result_code, ext_result_code, self.sql, msg);
        }

        [self resetBinding];
        [self resetStep];

        self.database = aDatabase;
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
    sqlite3_bind_int(self.stmt, pos, (int) value);
}

- (void)bindNextDouble:(double)value {
    int pos = [self nextBinding];
    sqlite3_bind_double(self.stmt, pos, value);
}

- (void)bindNextBool:(BOOL)value {
    NSInteger int_val = value ? 1 : 0;
    [self bindNextInteger:int_val];
}

- (void)bindNextTimeInterval:(NSTimeInterval)value {
    int pos = [self nextBinding];
    sqlite3_bind_double(self.stmt, pos, value);
}

- (void)bindNextText:(NSString *)value {
    int pos = [self nextBinding];
    sqlite3_bind_text(self.stmt, pos, [value UTF8String], -1, SQLITE_TRANSIENT);
}

- (void)bindNextTextEncode:(NSString *)value {
    NSString *sanitized = [ZHDatabase encodeInput:value];
    [self bindNextText:sanitized];
}

- (BOOL)execute {
    [self resetStep];
    int rc = sqlite3_step(self.stmt);
    [self reset];
    return (rc == SQLITE_DONE);
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
    return (sqlite3_step(self.stmt) == SQLITE_ROW);
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


@end
