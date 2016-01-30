//
//  RulesTimeElement.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 09/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "RulesTimeElement.h"

@implementation RulesTimeElement

-(id)init{
    if(self == [super init]){
        self.range = 0;
        self.hours = 0;
        self.mins = 0;
        self.dayOfMonth = [NSString new];
        self.dayOfWeek = [NSMutableArray new];
        self.monthOfYear = [NSString new];
        self.date = [NSDate new];
        self.dateFrom = [NSDate new];
        self.dateTo = [NSDate new];
        self.segmentType = 0;
    }
    return self;
}
-(id)createNew{
    RulesTimeElement *element=[RulesTimeElement new];
    element.range=self.range;
    element.hours=self.hours;
    element.mins=self.mins;
    element.dayOfMonth=self.dayOfMonth;
    element.dayOfWeek=self.dayOfWeek;
    element.monthOfYear=self.monthOfYear;
    element.date=self.date;
    element.dateFrom=self.dateFrom;
    element.dateTo=self.dateTo;
    element.segmentType=self.segmentType;

    return element;
}
@end
