//
//  UserProfileResponse.h
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 15/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfileResponse : NSObject
@property BOOL isSuccessful;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *addressLine1;
@property NSString *addressLine2;
@property NSString *addressLine3;
@property NSString *country;
@property NSString *zipCode;
@property int reasonCode;
@property NSString *reason;
@end
