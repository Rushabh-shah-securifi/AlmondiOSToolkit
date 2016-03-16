//
//  GenericDeviceClass.h
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericDeviceClass : NSObject
@property NSString *name;
@property NSString *type;
@property NSString *defaultIcon;
@property BOOL isActuator;
@property BOOL isTriggerDevice;
@property NSDictionary *Indexes;

-(id)initWithName:(NSString*)name type:(NSString*)type defaultIcon:(NSString*)defaultIcon isActuator:(BOOL)isActuator isTriggerDevice:(BOOL)isTriggerDevice indexes:(NSDictionary*)indexes;
@end
