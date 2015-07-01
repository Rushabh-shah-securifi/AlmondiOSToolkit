//
//  ValidateAccountRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 01/11/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface ValidateAccountRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *email;
@end
