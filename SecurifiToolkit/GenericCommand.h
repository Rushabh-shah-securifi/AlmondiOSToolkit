//
//  GenericCommand.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandTypes.h"

@interface GenericCommand : NSObject

@property(nonatomic) id command;
@property(nonatomic) CommandType commandType;

- (NSString *)description;

- (NSString *)debugDescription;

@end
