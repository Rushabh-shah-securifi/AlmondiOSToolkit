//
//  Formatter.h
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Formatter : NSObject
@property (nonatomic) float factor;
@property (nonatomic)int min;
@property (nonatomic)int max;
@property (nonatomic)NSString* units;

-(id)initWithFactor:(float)factor min:(int)min max:(int)max units:(NSString*)units;
-(NSString*)transform:(NSString*)value;
-(NSString*)transformValue:(NSString*)value;
+(Formatter*)getFormatterCopy:(Formatter*)formatter;
@end
