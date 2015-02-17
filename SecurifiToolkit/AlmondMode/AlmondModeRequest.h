//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"


@interface AlmondModeRequest : BaseCommandRequest <SecurifiCommand>

@property(nonatomic, copy) NSString *almondMAC;

- (NSString *)toXml;

@end