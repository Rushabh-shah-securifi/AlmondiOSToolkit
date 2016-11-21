//
//  GenericValue.m
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericValue.h"

@implementation GenericValue
-(id) initWithDisplayText:(NSString*)displayText icon:(NSString*)icon toggleValue:(NSString*)toggleValue value:(NSString*)value excludeFrom:(NSString*)excludeFrom eventType:(NSString *)eventType notificationText:(NSString *)notificationText{
    self = [super init];
    if(self){
        self.icon = icon;
        self.value = value;
        self.displayText = displayText;
        self.toggleValue = toggleValue;
        self.excludeFrom = excludeFrom;
        self.eventType = eventType;
        self.notificationText = notificationText;
    }
    return self;
}

- (id)initWithDisplayText:(NSString*)displayText iconText:(NSString*)iconText value:(NSString*)value excludeFrom:(NSString*)excludeFrom transformedValue:(NSString*)transformedValue prefix:(NSString *)notificationPrefix {
    self = [super init];
    if(self){
        self.iconText = iconText;
        self.displayText = displayText;
        if(iconText == nil)
            self.icon = @"1";
        self.value = value;
        self.excludeFrom = excludeFrom;
        self.transformedValue = transformedValue;
        self.notificationPrefix = notificationPrefix;
    }
    return self;
}
- (id)initWithDisplayTextNotification:(NSString*)icon value:(NSString*)value prefix:(NSString *)notificationPrefix {
    self = [super init];
    if(self){
        self.icon = icon;
        self.value = value;
        self.notificationPrefix = notificationPrefix;
    }
    return self;
}
- (id)initWithDisplayTextNotification:(NSString*)icon value:(NSString*)value prefix:(NSString *)notificationPrefix andUnit:(NSString *)unit {
    self = [super init];
    if(self){
        self.icon = icon;
        self.value = value;
        self.notificationPrefix = notificationPrefix;
        self.unit = unit;
    }
    return self;
}

- (id) initWithDisplayText:(NSString*)displayText icon:(NSString*)icon toggleValue:(NSString*)toggleValue value:(NSString*)value excludeFrom:(NSString*)excludeFrom eventType:(NSString*)eventType transformedValue:(NSString*)transformedValue prefix:(NSString *)notificationPrefix andUnits:(NSString *)unit{
    self = [super init];
    if(self){
        self.icon = icon;
        self.value = value;
        self.displayText = displayText;
        self.toggleValue = toggleValue;
        self.excludeFrom = excludeFrom;
        self.eventType = eventType;
        self.transformedValue = transformedValue;
        self.notificationPrefix = notificationPrefix;
        self.unit = unit;
    }
    return self;
}


+(GenericValue*)getCopy:(GenericValue*)genVal{
    GenericValue *copy = [GenericValue new];
    copy.value = genVal.value;
    copy.displayText = genVal.displayText;
    copy.icon = genVal.icon;
    copy.toggleValue = genVal.toggleValue;
    copy.excludeFrom = genVal.excludeFrom;
    copy.iconText = genVal.iconText;
    copy.eventType = genVal.eventType;
    copy.transformedValue = genVal.transformedValue;
    return copy;
}

-(id)initWithGenericValue:(GenericValue*)genericValue text:(NSString*)text{
    self = [super init];
    if(self){
        self.displayText = text;
        self.value = genericValue.value;
        self.icon = genericValue.icon;
        self.iconText = genericValue.iconText;
        self.toggleValue = genericValue.toggleValue;
        self.excludeFrom = genericValue.excludeFrom;
        self.eventType = genericValue.eventType;
        self.transformedValue = genericValue.transformedValue;
    }
    return self;
}

-(id)initUnknownDevice{
    self = [super init];
    if(self){
        self.displayText = @"Unknown";
        self.icon = @"Unknown";
    }
    return self;
}


@end
