//
//  DeviceListRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface DeviceListRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *almondMAC;

- (NSString *)description;

@end
