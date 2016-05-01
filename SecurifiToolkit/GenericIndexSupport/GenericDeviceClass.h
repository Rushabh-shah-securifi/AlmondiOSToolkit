//
//  GenericDeviceClass.h
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericDeviceClass : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic)NSString *type;
@property (nonatomic)NSString *defaultIcon;
@property (nonatomic)BOOL isActuator;
@property (nonatomic)BOOL isTrigger;
@property (nonatomic)NSString *excludeFrom;
@property (nonatomic)NSDictionary *Indexes;

-(id)initWithName:(NSString*)name type:(NSString*)type defaultIcon:(NSString*)defaultIcon isActuator:(BOOL)isActuator excludeFrom:(NSString *)excludeFrom indexes:(NSDictionary*)indexes isTrigger:(BOOL)isTrigger;
@end
