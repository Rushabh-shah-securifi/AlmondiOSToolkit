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
    
    if([self.eventType isEqualToString: @"TimeTrigger"])
        butProperties.time=[self.time createNew];

    return butProperties;
}

@end
