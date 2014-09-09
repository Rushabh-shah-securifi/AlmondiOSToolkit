//
//  DeviceValueRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface DeviceValueRequest : NSObject <SecurifiCommand>
@property NSString *almondMAC;

- (NSString *)description;



@end
