//
//  GenericDeviceClass.m
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericDeviceClass.h"

@implementation GenericDeviceClass
-(id)initWithName:(NSString*)name type:(NSString*)type defaultIcon:(NSString*)defaultIcon isActuator:(BOOL)isActuator excludeFrom:(NSString*)excludeFrom indexes:(NSDictionary*)indexes isTrigger:(NSString*)isTrigger{
    self = [super init];
    if(self){
        self.name = name;
        self.type = type;
        self.defaultIcon = defaultIcon;
        self.isActuator = isActuator;
        self.excludeFrom = excludeFrom;
        self.Indexes = indexes;
        self.isTrigger = isTrigger? [isTrigger boolValue]: YES;
    }
    return self;
}
@end
