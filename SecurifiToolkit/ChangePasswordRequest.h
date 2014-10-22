//
//  ChangePasswordRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface ChangePasswordRequest : BaseCommandRequest  <SecurifiCommand>
@property NSString *emailID;
@property NSString *currentPassword;
@property NSString *changedPassword;
- (NSString*)toXml;
@end
