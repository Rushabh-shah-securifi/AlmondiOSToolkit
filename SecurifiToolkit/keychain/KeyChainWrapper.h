//
//  KeyChainWrapper.h
//
// KeyChain wrapper by Stephen Anderson is licensed under 
// a Creative Commons Attribution-ShareAlike 3.0 Unported License.
// Permissions beyond the scope of this license may be available at 
// ruralcoder.com.

#import <Foundation/Foundation.h>

//
// !REQUIREMENT: Security.framework!
//

@interface KeyChainWrapper : NSObject

+ (NSMutableDictionary *)createSearchQueryForUser:(NSString *)userEmail forService:(NSString *)service;

+ (NSDictionary *)searchForUserEmail:(NSString *)userEmail forService:(NSString *)service;

+ (NSString *)retrieveEntryForUser:(NSString *)userEmail forService:(NSString *)service;

+ (BOOL)createEntryForUser:(NSString *)userEmail entryValue:(NSString *)entryValue forService:(NSString *)service;

+ (BOOL)isEntryStoredForUserEmail:(NSString *)userEmail forService:(NSString *)service;

+ (BOOL)removeEntryForUserEmail:(NSString *)userEmail forService:(NSString *)service;

+ (NSString *)keyChainErrorToString:(OSStatus)status;

+ (void)printAttributes:(NSDictionary *)attributes;


@end
