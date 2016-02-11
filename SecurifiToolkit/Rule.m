//
//  Rule.m
//  SecurifiApp
//
//  Created by Masood on 10/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "Rule.h"
#import "SFIButtonSubProperties.h"

@implementation Rule

-(id)init{
    if(self == [super init]){
        self.triggers = [[NSMutableArray alloc]init];
        self.actions = [[NSMutableArray alloc]init];
        self.name = [[NSString alloc]init];
    }
    return self;
}

 - (id)copyWithZone:(NSZone *)zone {
     Rule *copy = (Rule *) [[[self class] allocWithZone:zone] init];
     if (copy != nil) {
         copy.triggers = [NSMutableArray arrayWithArray:self.triggers];
         copy.actions = [NSMutableArray arrayWithArray:self.actions];
         copy.isActive = self.isActive;
         copy.name = self.name;
         copy.lastActivated = self.lastActivated;
         copy.ID = self.ID;
     }

     return copy;
 }
- (NSMutableArray *)copyEntries:(NSArray *)entries{
    NSMutableArray *newEntries= [NSMutableArray new];
    for(SFIButtonSubProperties *properties in entries){
        [newEntries addObject:[properties createNew]];
    }
    return newEntries;
}
- (id)createNew{
    Rule *copy = [Rule new];
    
    copy.triggers = [self copyEntries:self.triggers];
    copy.actions = [self copyEntries:self.actions];
    copy.isActive = self.isActive;
    copy.name = self.name;
    copy.lastActivated = self.lastActivated;
    copy.ID = self.ID;
    
    return copy;
}

@end
