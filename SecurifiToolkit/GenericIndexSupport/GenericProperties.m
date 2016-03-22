

//
//  GenericProperty.m
//  SecurifiToolkit
//
//  Created by Masood on 21/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericProperties.h"

@implementation GenericProperties

-(id)initWithDeviceID:(int)deviceID index:(int)index genericValue:(GenericValue*)genericValue{
    self  = [super init];
    if(self){
        self.deviceID = deviceID;
        self.index = index;
        self.genericValue = genericValue;
    }
    return self;
}
@end
