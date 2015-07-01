//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"


@interface AlmondModeChangeRequest : BaseCommandRequest <SecurifiCommand>

@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic, copy) NSString *userId;  // change made by logged in user
@property(nonatomic) SFIAlmondMode mode;

- (NSString *)toXml;

- (NSData*)toJson;

@end
