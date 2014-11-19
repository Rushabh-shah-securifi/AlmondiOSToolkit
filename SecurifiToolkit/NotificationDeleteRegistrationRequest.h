//
//  NotificationDeleteRegistrationRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 07/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface NotificationDeleteRegistrationRequest : BaseCommandRequest <SecurifiCommand>
@property NSString *regID;
@property NSString *platform;

- (NSString *)toXml;
@end
