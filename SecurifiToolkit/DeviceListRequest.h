//
//  DeviceListRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface DeviceListRequest : BaseCommandRequest <SecurifiCommand>
@property NSString *almondMAC;

- (NSString *)description;

@end
