//
//  DeviceDataForcedUpdateRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 15/01/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@class BaseCommandRequest;

@interface SensorForcedUpdateRequest : BaseCommandRequest <SecurifiCommand>
@property NSString *almondMAC;
@end
