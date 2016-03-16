//
//  Formatter.h
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Formatter : NSObject
@property float factor;
@property int min;
@property int max;
@property NSString* units;

-(id)initWithFactor:(float)factor min:(int)min max:(int)max units:(NSString*)units;
-(NSString*)transform:(NSString*)value;
@end
