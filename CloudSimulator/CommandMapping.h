//
//  CommandMapping.h
//  SecurifiToolkit
//
//  Created by Masood on 28/08/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericCommand.h"
#import "CommandObject.h"

@interface CommandMapping : NSObject

-(void) mapCommand: (GenericCommand *)cmd;

@end
