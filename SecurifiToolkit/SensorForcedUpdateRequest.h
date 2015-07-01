//
//  DeviceDataForcedUpdateRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 15/01/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCommandRequest.h"
#import "SecurifiCommand.h"

@interface SensorForcedUpdateRequest : BaseCommandRequest <SecurifiCommand>
@property (nonatomic, copy) NSString *almondMAC;
@end
