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
        NSDate *currentDate = [[NSDate alloc]init];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: currentDate];
        self.range = 0;
        self.hours = [components hour];
        self.mins = [components minute];
        self.dayOfMonth = [NSString new];
        self.dayOfWeek = [NSMutableArray new];
        self.monthOfYear = [NSString new];
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
    element.dateFrom=self.dateFrom;
    element.dateTo=self.dateTo;
    element.segmentType=self.segmentType;
    return element;
}
@end
