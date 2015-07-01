//
//  NotificationRegistration.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 06/11/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface NotificationRegistration : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *regID;
@property(nonatomic, copy) NSString *platform;

- (NSString *)toXml;
@end
