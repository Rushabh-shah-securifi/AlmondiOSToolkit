//
//  LogoutAllResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, LogoutAllResponseResonCode) {
    LogoutAllResponseResonCode_usernameNotFound     = 1,
    LogoutAllResponseResonCode_wrongPassword        = 2,
    LogoutAllResponseResonCode_notValidatedEmail    = 3,
    LogoutAllResponseResonCode_invalidEmailPassword = 4,
    LogoutAllResponseResonCode_databaseError        = 5,
    LogoutAllResponseResonCode_internalDbError      = 6,
};

@interface LogoutAllResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) LogoutAllResponseResonCode reasonCode;
@end
