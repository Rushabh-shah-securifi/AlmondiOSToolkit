//
//  GenericProperty.h
//  SecurifiToolkit
//
//  Created by Masood on 21/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericValue.h"

@interface GenericProperties : NSObject
@property int index;
@property int deviceID;
@property GenericValue *genericValue;

-(id)initWithDeviceID:(int)deviceID index:(int)index genericValue:(GenericValue*)genericValue;
@end
