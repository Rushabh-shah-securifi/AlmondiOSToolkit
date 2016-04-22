//
//  Formatter.m
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "Formatter.h"
@interface Formatter()

@end

@implementation Formatter
-(id)initWithFactor:(float)factor min:(int)min max:(int)max units:(NSString*)units{
    self = [super init];
    if(self){
        self.factor = factor;
        self.min = min;
        self.max = max;
        self.units = units;
    }
    return self;
}

-(NSString*)transform:(NSString*)value{
    int intValue = value.intValue;
    NSLog(@"value:%d, factor:%f", intValue, self.factor);
    return [NSString stringWithFormat:@"%.1f%@", intValue*self.factor, self.units];
}
-(NSString*)transformValue:(NSString*)value{
    int intValue = value.intValue;
    NSLog(@"value:%d, factor:%f", intValue, self.factor);
    return [NSString stringWithFormat:@"%.1f", intValue*self.factor];
}
@end
