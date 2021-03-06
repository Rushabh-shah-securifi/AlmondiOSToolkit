//
//  LoginResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginResponse : NSObject

@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *userID;
@property(nonatomic, copy) NSString *tempPass;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) int reasonCode;

//PY: 101014 - Not activated accounts can be accessed for 7 days
@property(nonatomic, assign) BOOL isAccountActivated;
@property(nonatomic, assign) NSUInteger minsRemainingForUnactivatedAccount;

@end
