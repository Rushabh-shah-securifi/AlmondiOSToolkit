//
//  CompleteDB.h
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 23/09/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompleteDB : NSObject

+(void)initializeCompleteDataBase;

+(NSArray *)betweenDays:(NSString *)date1 date2:(NSString *)date2 previousDate:(NSString *)previousDate;

+(void)insertInCompleteDB:(NSString *)date cmac:(NSString*)cmac amac:(NSString*)amac;

+(NSString *)getMaxDate:(NSString *)amac clientMac:(NSString *)cmac;

+(NSString *)getLastDate:(NSString *)amac clientMac:(NSString *)cmac;

+(void)deleteDateEntries:(NSString *)amac clientMac:(NSString *)cmac date:(NSString *)date;
+(BOOL)searchDatePresentOrNot:(NSString *)amac clientMac:(NSString *)cmac andDate:(NSString *)date;
@end