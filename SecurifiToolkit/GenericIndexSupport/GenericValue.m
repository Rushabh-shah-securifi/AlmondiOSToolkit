//
//  GenericValue.m
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericValue.h"

@implementation GenericValue
-(id) initWithDisplayText:(NSString*)displayText icon:(NSString*)icon toggleValue:(NSString*)toggleValue value:(NSString*)value excludeFrom:(NSString*)excludeFrom eventType:(NSString *)eventType{
    self = [super init];
    if(self){
        self.value = value;
        self.displayText = displayText;
        self.icon = icon;
        self.toggleValue = toggleValue;
        self.excludeFrom = excludeFrom;
        self.eventType = eventType;
    }
    return self;
}

-(id)initWithGenericValue:(GenericValue*)genericValue text:(NSString*)text{
    self = [super init];
    if(self){
        self.displayText = text;
        self.icon = genericValue.icon;
        self.iconText = genericValue.iconText;
        self.toggleValue = genericValue.toggleValue;
        self.excludeFrom = genericValue.excludeFrom;
        self.eventType = genericValue.eventType;
    }
    return self;
}

- (id)initWithDisplayText:(NSString*)displayText iconText:(NSString*)iconText value:(NSString*)value excludeFrom:(NSString*)excludeFrom{
    self = [super init];
    if(self){
        self.displayText = displayText;
        self.iconText = iconText;
        if(iconText == nil)
            self.icon = @"1";
        self.value = value;
        self.excludeFrom = excludeFrom;
    }
    return self;
}
@end
