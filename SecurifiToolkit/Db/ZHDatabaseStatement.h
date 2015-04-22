//
//  ZHDatabaseStatement.h
//
//  Created by Matthew Sinclair-Day on 5/30/09.
//  Copyright 2015 Ming Fu Design Inc 明孚設計有限公司. All rights reserved.
//  Permission is granted to Securifi Ltd. to include and distribute source in their iOS products.
//

#import <Foundation/Foundation.h>
#import "ZHDatabase.h"
#import <sqlite3.h>

// Represents a prepared statement
//
@interface ZHDatabaseStatement : NSObject

- (id)initWithDb:(ZHDatabase *)aDatabase sql:(NSString *)aSqlExpression;

// reset the stmt preparing for new bindings
- (void)reset;

// bind an integer in the next column
- (void)bindNextInteger:(NSInteger)aValue;

- (void)bindNextDouble:(double)value;

- (void)bindNextBool:(BOOL)value;

- (void)bindNextTimeInterval:(NSTimeInterval)value;

- (void)bindNextText:(NSString *)aValue;

// binds a text, escaping sqlite tokens before storing
- (void)bindNextTextEncode:(NSString *)aValue;

// executes the statement; used for inserts and updates
- (BOOL)execute;

// executes the statement and steps through the results, capturing a single string value per step
- (NSArray *)executeReturnArray;

- (long)executeReturnInteger;

- (BOOL)executeReturnBool;

// execute and step through the result set row; returns bool when there is data to be read
// all steps should eventually be followed by a reset
- (BOOL)step;

// step to the next column in the result set row, expecting an integer type
// returns 0 when a record is not found
- (long)stepNextInteger;

- (double)stepNextDouble;

// step to the next column in the result set row, expecting a time interval type
// returns 0 when a record is not found
- (NSTimeInterval)stepNextTimeInterval;

- (BOOL)stepNextBool;

// step to the next column in the result set row, expecting a string type
- (NSString *)stepNextString;

// same as stepNextString but the value is also unpacked; inverse of bindNextTextEncode 
//- (NSString*) stepNextStringDecode;

@end
