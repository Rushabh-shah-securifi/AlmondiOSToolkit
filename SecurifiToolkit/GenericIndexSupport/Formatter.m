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

-(NSString*)transform:(NSString*)value genericId:(NSString *)genericIndexID{
    if(value.length == 0)
        return @"";
    
    float fVal = [value floatValue];
    float roundVal = roundf(fVal*self.factor);
    NSLog(@"actual value:%f, multiplied value: %f, rounded value: %f", fVal, fVal*self.factor, roundVal);
    int genId = [genericIndexID intValue];
    if(genId == 86 || genId == 52 || genId == 53) //power, voltage, current
        return [NSString stringWithFormat:@"%.2f%@", fVal, self.units == nil? @"": self.units];
    else
        return [NSString stringWithFormat:@"%d%@", (int)roundVal, self.units == nil? @"": self.units];
}

-(NSString*)transformValue:(NSString*)value{
    float fVal = [value floatValue];
    int roundedValue = roundf(fVal*self.factor);
    NSLog(@"transformValue - actual value: %.1f, roundedval: %d", fVal*self.factor, roundedValue);
    return [NSString stringWithFormat:@"%d",roundedValue];
}
@end
