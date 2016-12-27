//
//  SFISecondaryUser.h
//  SecurifiToolkit
//
//  Created by K Murali Krishna on 27/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//


@interface SFISecondaryUser : NSObject 

@property NSString* emailId;
@property NSString* userId;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (id)copyWithZone:(NSZone *)zone;

@end

