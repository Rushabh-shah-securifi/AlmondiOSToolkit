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
@property(nonatomic) NSString *userID;
@property(nonatomic) NSString *tempPass;
@property(nonatomic) NSString *reason;
@property(nonatomic) int reasonCode;

//PY: 101014 - Not activated accounts can be accessed for 7 days
@property (nonatomic) NSString *isActivated;
@property(nonatomic)  NSString *minsRemaining;
@end
