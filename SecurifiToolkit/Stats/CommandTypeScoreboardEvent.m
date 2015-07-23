//
// Created by Matthew Sinclair-Day on 7/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "CommandTypeScoreboardEvent.h"

@implementation CommandTypeScoreboardEvent

- (instancetype)initWithCommandType:(CommandType)commandType {
    self = [super init];
    if (self) {
        _commandType = commandType;
    }

    return self;
}

- (NSString *)label {
    return commandTypeToString(self.commandType);
}

@end