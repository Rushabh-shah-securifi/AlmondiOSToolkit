//
//  KeyChainAccess.m
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "KeyChainAccess.h"
#import "SecurifiToolKit.h"

@implementation KeyChainAccess

+ (BOOL)hasLoginCredentials {
    // Keychains persist after an app is deleted. Therefore, to ensure credentials are "wiped out",
    // we keep track of whether this is a new install by storing a value in user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL logged_in_once = [defaults boolForKey:kPREF_USER_DEFAULT_LOGGED_IN_ONCE];
    
    return logged_in_once && [self hasSecEmail] && [self hasSecPassword];
}

+ (void)clearSecCredentials {
    [KeyChainWrapper removeEntryForUserEmail:SEC_EMAIL forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_PWD forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_USER_ID forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_APN_TOKEN forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_IS_ACCOUNT_ACTIVATED forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT forService:SEC_SERVICE_NAME];
}

+ (BOOL)hasSecPassword {
    return [KeyChainWrapper isEntryStoredForUserEmail:SEC_PWD forService:SEC_SERVICE_NAME];
}

+ (BOOL)hasSecEmail {
    return [KeyChainWrapper isEntryStoredForUserEmail:SEC_EMAIL forService:SEC_SERVICE_NAME];
}

+ (NSString *)secEmail {
    if (![self hasSecEmail]) {
        return nil;
    }
    return [KeyChainWrapper retrieveEntryForUser:SEC_EMAIL forService:SEC_SERVICE_NAME];
}

+ (void)setSecEmail:(NSString *)email {
    [KeyChainWrapper createEntryForUser:SEC_EMAIL entryValue:email forService:SEC_SERVICE_NAME];
}

+ (NSString *)secPassword {
    if (![self hasSecPassword]) {
        return nil;
    }
    return [KeyChainWrapper retrieveEntryForUser:SEC_PWD forService:SEC_SERVICE_NAME];
}

+ (void)setSecPassword:(NSString *)pwd {
    [KeyChainWrapper createEntryForUser:SEC_PWD entryValue:pwd forService:SEC_SERVICE_NAME];
}

+ (NSString *)secUserId {
    return [KeyChainWrapper retrieveEntryForUser:SEC_USER_ID forService:SEC_SERVICE_NAME];
}

+ (void)setSecUserId:(NSString *)userId {
    [KeyChainWrapper createEntryForUser:SEC_USER_ID entryValue:userId forService:SEC_SERVICE_NAME];
}

//PY: 101014 - Not activated accounts can be accessed for 7 days
+ (BOOL)secIsAccountActivated {
    NSString *value = [KeyChainWrapper retrieveEntryForUser:SEC_IS_ACCOUNT_ACTIVATED forService:SEC_SERVICE_NAME];
    if (value == nil) {
        return YES;
    }
    return [value boolValue];
}

+ (void)setSecAccountActivationStatus:(BOOL)isActivated {
    NSNumber *num = @(isActivated);
    [KeyChainWrapper createEntryForUser:SEC_IS_ACCOUNT_ACTIVATED entryValue:[num stringValue] forService:SEC_SERVICE_NAME];
}

+ (NSUInteger)secMinsRemainingForUnactivatedAccount {
    NSString *value = [KeyChainWrapper retrieveEntryForUser:SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT forService:SEC_SERVICE_NAME];
    if (value.length == 0) {
        return 0;
    }
    
    NSInteger mins = value.integerValue;
    return (NSUInteger) mins;
}

+ (void)setSecMinsRemainingForUnactivatedAccount:(NSUInteger)minsRemaining {
    NSNumber *num = @(minsRemaining);
    [KeyChainWrapper createEntryForUser:SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT entryValue:[num stringValue] forService:SEC_SERVICE_NAME];
}

+ (BOOL)isSecApnTokenRegistered {
    return [KeyChainWrapper isEntryStoredForUserEmail:SEC_APN_TOKEN forService:SEC_SERVICE_NAME];
}

+ (NSString *)secRegisteredApnToken {
    return [KeyChainWrapper retrieveEntryForUser:SEC_APN_TOKEN forService:SEC_SERVICE_NAME];
}

+ (void)setSecRegisteredApnToken:(NSString *)token {
    if (token == nil) {
        return;
    }
    [KeyChainWrapper createEntryForUser:SEC_APN_TOKEN entryValue:token forService:SEC_SERVICE_NAME];
}


@end
