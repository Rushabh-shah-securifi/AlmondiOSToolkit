//
//  GenericValue.m
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericValue.h"

@implementation GenericValue
-(id) initWithDisplayText:(NSString*) displayText icon:(NSString*)icon formattedValue:(NSString*)formattedValue toggleValue:(NSString*)toggleValue isIconText:(BOOL)isIconText{
    self = [super init];
    if(self){
        self.displayText = displayText;
        self.icon = icon;
        self.formatttedValue = formattedValue;
        self.toggleValue = toggleValue;
        self.isIconText = isIconText;
    }
    return self;
}

-(id)initWithGenericValue:(GenericValue*)genericValue text:(NSString*)text{
    self = [super init];
    if(self){
        self.displayText = text;
        self.icon = genericValue.icon;
        self.isIconText = genericValue.isIconText;
        self.formatttedValue = genericValue.formatttedValue;
        self.toggleValue = genericValue.toggleValue;
    }
    return self;
}
@end
