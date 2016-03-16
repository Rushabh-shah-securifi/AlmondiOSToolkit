//
//  GenericDeviceClass.m
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericDeviceClass.h"

@implementation GenericDeviceClass
-(id)initWithName:(NSString*)name type:(NSString*)type defaultIcon:(NSString*)defaultIcon isActuator:(BOOL)isActuator isTriggerDevice:(BOOL)isTriggerDevice indexes:(NSDictionary*)indexes{
    self = [super init];
    if(self){
        self.name = name;
        self.type = type;
        self.defaultIcon = defaultIcon;
        self.isActuator = isActuator;
        self.isTriggerDevice = isTriggerDevice;
        self.Indexes = indexes;
    }
    return self;
}
@end
