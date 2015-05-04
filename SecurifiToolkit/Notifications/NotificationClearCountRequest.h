//
// Created by Matthew Sinclair-Day on 5/4/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandTypes.h"
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"


@interface NotificationClearCountRequest : BaseCommandRequest <SecurifiCommand>

@property (nonatomic, readonly) CommandType commandType;

@end