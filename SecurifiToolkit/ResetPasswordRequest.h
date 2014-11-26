//
//  ResetPasswordRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 01/11/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface ResetPasswordRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *email;
@end
