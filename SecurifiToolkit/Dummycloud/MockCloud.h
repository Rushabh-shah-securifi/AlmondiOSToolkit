//
//  MockCloud.h
//  SecurifiApp
//
//  Created by Masood on 06/08/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scoreboard.h"
#import "GenericCommand.h"
//#import "CommandTypes.h"
#include "AlmondPlusSDKConstants.h"
#include "MobileCommandRequest.h"


@interface MockCloud : NSObject

@property(nonatomic, readonly) NSMutableArray *events;
@property(nonatomic, readonly) Scoreboard *scoreboard;


@property(nonatomic, readonly) dispatch_queue_t socketCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t callbackQueue;          // queue used for posting notifications




-(void) sendToMockCloud:(GenericCommand*) cmd;

@end
