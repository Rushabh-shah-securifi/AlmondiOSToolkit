//
// Created by Matthew Sinclair-Day on 7/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scoreboard.h"
#import "CommandTypes.h"


@interface CommandTypeScoreboardEvent : NSObject <ScoreboardEvent>

@property(readonly) CommandType commandType;

- (instancetype)initWithCommandType:(CommandType)commandType;

@end