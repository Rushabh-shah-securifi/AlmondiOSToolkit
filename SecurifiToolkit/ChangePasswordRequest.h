//
//  ChangePasswordRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface ChangePasswordRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *emailID;
@property(nonatomic, copy) NSString *currentPassword;
@property(nonatomic, copy) NSString *changedPassword;

- (NSString *)toXml;
@end
