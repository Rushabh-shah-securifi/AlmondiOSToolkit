//
//  GenericDeviceClass.m
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericDeviceClass.h"

@implementation GenericDeviceClass
-(id)initWithName:(NSString*)name type:(NSString*)type defaultIcon:(NSString*)defaultIcon isActuator:(BOOL)isActuator excludeFrom:(NSString*)excludeFrom indexes:(NSDictionary*)indexes isTrigger:(BOOL)isTrigger{
    self = [super init];
    if(self){
        self.name = name;
        self.type = type;
        self.defaultIcon = defaultIcon;
        self.isActuator = isActuator;
        self.excludeFrom = excludeFrom;
        self.Indexes = indexes;
        if(isTrigger == nil)
            isTrigger = YES;
        self.isTrigger = isTrigger;

    }
    return self;
}
@end
