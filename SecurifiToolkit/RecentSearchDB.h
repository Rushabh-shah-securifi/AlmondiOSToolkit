//
//  RecentSearch.h
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 28/09/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentSearchDB : NSObject
+(void)initializeCompleteDataBase;
+(void)insertInRecentDB:(NSString *)uri cmac:(NSString*)cmac amac:(NSString*)amac;
+ (NSMutableArray *)getAllRecentwithLimit:(int)limit almonsMac:(NSString *)amac clientMac:(NSString *)cmac;
+(int)GetHistoryDatabaseCount:(NSString *)amac clientMac:(NSString *)cmac;
@end
