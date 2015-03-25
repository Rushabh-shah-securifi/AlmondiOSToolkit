//
// Created by Matthew Sinclair-Day on 3/25/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"


// Requests the current count of new notifications
@interface NotificationCountRequest : BaseCommandRequest <SecurifiCommand>

@end