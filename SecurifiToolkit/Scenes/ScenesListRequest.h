//
//  ScenesListRequest.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 28.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCommandRequest.h"
#import "SecurifiCommand.h"

@interface ScenesListRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic, copy) NSString *deviceID;

- (NSString *)toXml;

@end