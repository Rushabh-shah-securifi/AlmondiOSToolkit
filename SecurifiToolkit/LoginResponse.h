//
//  LoginResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginResponse : NSObject

@property BOOL isSuccessful;
@property NSString *userID;
@property NSString *tempPass;
@property NSString *reason;
@property int reasonCode;
@end
