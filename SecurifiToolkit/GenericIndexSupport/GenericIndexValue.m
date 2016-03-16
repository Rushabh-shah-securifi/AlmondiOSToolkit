//
//  GenericIndexValue.m
//  SecurifiToolkit
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericIndexValue.h"

@implementation GenericIndexValue
-(id)initWithGenericIndex:(GenericIndexClass*)genericIndex genericValue:(GenericValue*)genericValue{
    self = [super init];
    if(self){
        self.genericIndex = genericIndex;
        self.genericValue = genericValue;
    }
    return self;
}
@end
