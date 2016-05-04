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
    float fVal = [value floatValue];
    NSLog(@"value:%f factor:%f", fVal, self.factor);
    return [NSString stringWithFormat:@"%.1f%@", fVal*self.factor, self.units];
}
-(NSString*)transformValue:(NSString*)value{
    float fVal = [value floatValue];
    NSLog(@"value:%f factor:%f", fVal, self.factor);
    return [NSString stringWithFormat:@"%.1f", fVal*self.factor];
}
@end
