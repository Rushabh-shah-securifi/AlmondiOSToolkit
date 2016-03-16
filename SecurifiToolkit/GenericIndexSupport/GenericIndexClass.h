//
//  GenericIndexClass.h
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Formatter.h"

@interface GenericIndexClass : NSObject
@property NSString *label;
@property NSString *icon;
@property NSString *ID;
@property NSString *placement;
@property NSDictionary *values;
@property Formatter *formatter;
@property NSString* layoutType;

-(id)initWithLabel:(NSString*)label icon:(NSString*)icon identifier:(NSString*)ID placement:(NSString*)placement values:(NSDictionary*)values formatter:(Formatter*)formatter layoutType:(NSString*)layoutType;

@end
