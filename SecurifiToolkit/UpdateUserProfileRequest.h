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
@property(nonatomic, copy) NSString *firstName;
@property(nonatomic, copy) NSString *lastName;
@property(nonatomic, copy) NSString *addressLine1;
@property(nonatomic, copy) NSString *addressLine2;
@property(nonatomic, copy) NSString *addressLine3;
@property(nonatomic, copy) NSString *country;
@property(nonatomic, copy) NSString *zipCode;

- (NSString *)toXml;

@end
