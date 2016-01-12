//
//  Rule.m
//  SecurifiApp
//
//  Created by Masood on 10/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "Rule.h"

@implementation Rule

-(id)init{
    if(self == [super init]){
        self.triggers = [[NSMutableArray alloc]init];
        self.actions = [[NSMutableArray alloc]init];
        self.wifiClients = [[NSMutableArray alloc]init];
        self.time = [[RulesTimeElement alloc]init];
        self.name = [[NSString alloc]init];
//        self.wificlientArray = [[NSMutableArray alloc]init];
    }
    return self;
}

 - (id)copyWithZone:(NSZone *)zone {
     NSLog(@"copyWithZone rule");
 Rule *copy = (Rule *) [[[self class] allocWithZone:zone] init];
 if (copy != nil) {
     copy.triggers = [NSMutableArray arrayWithArray:self.triggers];
 copy.actions = [NSMutableArray arrayWithArray:self.actions];
 copy.wifiClients = [NSMutableArray arrayWithArray:self.wifiClients];
 copy.time = self.time;
 copy.isActive = self.isActive;
 copy.name = self.name;
 copy.lastActivated = self.lastActivated;
 copy.ID = self.ID;
 }

 return copy;
 }
@end
