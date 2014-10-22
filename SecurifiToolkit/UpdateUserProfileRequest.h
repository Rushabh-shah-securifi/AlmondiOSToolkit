//
//  UpdateUserProfileRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 18/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface UpdateUserProfileRequest : BaseCommandRequest <SecurifiCommand>
@property NSString *firstName;
@property NSString *lastName;
@property NSString *addressLine1;
@property NSString *addressLine2;
@property NSString *addressLine3;
@property NSString *country;
@property NSString *zipCode;

- (NSString *)toXml;

@end
