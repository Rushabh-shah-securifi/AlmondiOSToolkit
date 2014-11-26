//
//  LoginResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginResponse : NSObject

@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *userID;
@property(nonatomic, copy) NSString *tempPass;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) int reasonCode;

//PY: 101014 - Not activated accounts can be accessed for 7 days
@property(nonatomic, copy) NSString *isAccountActivated;    //todo convert this to a BOOL type
@property(nonatomic, copy) NSString *minsRemainingForUnactivatedAccount; // todo convert this to unsigned int type
@end
