//
//  MockCloud.m
//  SecurifiApp
//
//  Created by Masood on 06/08/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//





#import "MockCloud.h"
#import "CommandMapping.h"



//checkpoint

@implementation MockCloud


- (void) sendToMockCloud:(GenericCommand *)cmd{
    
    NSLog(@"**** In mock cloud ***** ");
    
    CommandMapping *commandMapping = [[CommandMapping alloc] init];
    [commandMapping mapCommand:cmd];
    
}


@end
