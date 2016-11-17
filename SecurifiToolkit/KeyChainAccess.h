//
//  KeyChainAccess.h
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#ifndef KeyChainAccess_h
#define KeyChainAccess_h
#import <Foundation/Foundation.h>
#import "KeyChainWrapper.h"

@interface KeyChainAccess : NSObject

+ (BOOL)hasLoginCredentials;
+ (void)clearSecCredentials;
+ (BOOL)hasSecPassword;
+ (BOOL)hasSecEmail;
+ (NSString *)secEmail;
+ (NSString *)secPassword;
+ (void)setSecEmail:(NSString *)email;
+ (void)setSecPassword:(NSString *)pwd;
+ (NSString *)secUserId;
+ (void)setSecUserId:(NSString *)userId;
+ (BOOL)secIsAccountActivated;
+ (void)setSecAccountActivationStatus:(BOOL)isActivated;
+ (NSUInteger)secMinsRemainingForUnactivatedAccount;
+ (void)setSecMinsRemainingForUnactivatedAccount:(NSUInteger)minsRemaining;
+ (BOOL)isSecApnTokenRegistered;
+ (NSString *)secRegisteredApnToken;
+ (void)setSecRegisteredApnToken:(NSString *)token;

@end
#endif /* KeyChainAccess_h */
