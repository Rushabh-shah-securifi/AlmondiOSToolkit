//
//  SFIButtonSubProperties.m
//  SecurifiApp
//
//  Created by Masood on 15/10/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "SFIButtonSubProperties.h"

@implementation SFIButtonSubProperties

-(id)init{
    self = [super init];
    if(self){
        self.delay = @"0";
        self.eventType=nil;
        self.displayedData=nil;
        
    }
    return self;
}

- (SFIButtonSubProperties *)createNew{
    SFIButtonSubProperties *butProperties = [[SFIButtonSubProperties alloc]init];
    butProperties.deviceId = self.deviceId;
    butProperties.index = self.index;
    butProperties.matchData = self.matchData;
    butProperties.delay = self.delay;
    butProperties.eventType = self.eventType;
    butProperties.positionId = self.positionId;
    butProperties.deviceType = self.deviceType;
    butProperties.deviceName = self.deviceName;
    butProperties.type=self.type;
    butProperties.valid=self.valid;
    butProperties.condition = self.condition;
    
    if([self.eventType isEqualToString: @"TimeTrigger"])
        butProperties.time=[self.time createNew];

    return butProperties;
}
-(NSString*)getcondition{
    switch (self.condition) {
        case isEqual:
            return @"=";
        
        case isLessThan:
            return @"<";
           
        case isLessThanOrEqual:
            return @"<=";
            
        case isGreaterThan:
            return @">";
           
        case isGreaterThanOrEqual:
            return @">=";
          
            
        default:
            break;
    }
}
-(NSString*)getconditionPayload{
    NSLog(@"self.condition %d",self.condition);
    switch (self.condition) {
        case isEqual:
            return @"eq";
            
        case isLessThan:
            return @"lt";
            
        case isLessThanOrEqual:
            return @"le";
            
        case isGreaterThan:
            return @"gt";
            
        case isGreaterThanOrEqual:
            return @"ge";
            
            
        default:
            break;
    }
}

@end
