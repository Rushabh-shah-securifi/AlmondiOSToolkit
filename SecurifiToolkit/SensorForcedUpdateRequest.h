//
//  DeviceDataForcedUpdateRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 15/01/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface SensorForcedUpdateRequest : NSObject <SecurifiCommand>
@property NSString *almondMAC;
@property NSString *mobileInternalIndex;
@end
