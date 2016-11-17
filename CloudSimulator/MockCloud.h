//
//  MockCloud.h
//  SecurifiApp
//
//  Created by Masood on 06/08/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericCommand.h"

@interface MockCloud : NSObject

-(void) sendToMockCloud:(GenericCommand*) cmd;

@end
