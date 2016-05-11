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

+(Formatter*)getFormatterCopy:(Formatter*)formatter{
    Formatter *copy = [[Formatter alloc]init];
    copy.factor = formatter.factor;
    copy.min = formatter.min;
    copy.max = formatter.max;
    copy.units = formatter.units;
    return copy;
}

-(NSString*)transform:(NSString*)value{
    float fVal = [value floatValue];
    NSLog(@"transform - value:%f factor:%f", fVal, self.factor);
    return [NSString stringWithFormat:@"%.1f%@", roundf(fVal*self.factor), self.units];
}
-(NSString*)transformValue:(NSString*)value{
    float fVal = [value floatValue];
    int roundedValue = roundf(fVal*self.factor);
    NSLog(@"transformValue - actual value: %.1f, roundedval: %d", fVal*self.factor, roundedValue);
    return [NSString stringWithFormat:@"%d",roundedValue];
}
@end
