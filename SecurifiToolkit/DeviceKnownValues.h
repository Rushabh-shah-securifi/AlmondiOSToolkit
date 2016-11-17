//
//  DeviceKnownValues.h
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

@interface DeviceKnownValues : NSObject

@property(nonatomic) unsigned int index;
@property(nonatomic) NSString *valueName;
@property(nonatomic) NSString *value;

@end
