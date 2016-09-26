//
//  RuleParser.m
//  SecurifiToolkit
//
//  Created by Masood on 21/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//
//
#import "RuleParser.h"
#import "SFIButtonSubProperties.h"
#import "SecurifiToolkit.h"
#import "AlmondPlusSDKConstants.h"
#import "AlmondJsonCommandKeyConstants.h"


@implementation RuleParser

- (instancetype)init {
    self = [super init];
    [self initNotification];
    
    return self;
}

-(void)initNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onRuleListResponse:) name:NOTIFICATION_RULE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER object:nil];
}


-(void)onRuleListResponse:(id)sender{
    if(![self validateResponse:sender])
        return;
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    BOOL local = [toolkit useLocalNetwork:[toolkit currentAlmond].almondplusMAC];
    NSDictionary *mainDict=[[(NSNotification *) sender userInfo] valueForKey:@"data"];
    if(!local){
        if(![[[(NSNotification *) sender userInfo] valueForKey:@"data"] isKindOfClass:[NSData class]])
            return;

         mainDict = [[[(NSNotification *) sender userInfo] valueForKey:@"data"] objectFromJSONData];
    }
    if([mainDict isKindOfClass:[NSDictionary class]] == NO)
        return;
    
    BOOL isMatchingAlmondOrLocal = ([mainDict[ALMONDMAC] isEqualToString:toolkit.currentAlmond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
    
    NSString *commandType=mainDict[@"CommandType"];
    NSDictionary *rulesDict = mainDict[@"Rules"];
    
    //NSLog(@"onRuleList: %@",mainDict);
    //RuleList
    if([commandType isEqualToString:@"RuleList"] || [commandType isEqualToString:@"DynamicRuleList"]){
        if([mainDict[@"Rules"] isKindOfClass:[NSArray class]])
            return;
        NSDictionary *rulesPayload = mainDict[@"Rules"];
        [toolkit.ruleList removeAllObjects];
        
        NSArray *rulePosKeys = rulesPayload.allKeys;
        NSArray *sortedPostKeys = [rulePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
        }];
        for (NSString *key in sortedPostKeys) {
            //NSLog(@"create rule:: %@",rulesPayload[key]);
            [self createRule:rulesPayload[key] ruleID:key];
        }
    }
    else if([commandType isEqualToString:@"DynamicRuleUpdated"] || [commandType isEqualToString:@"DynamicRuleAdded"]){
        NSString *Id = [[rulesDict allKeys] objectAtIndex:0];
        NSDictionary *dDict = rulesDict[Id];
        [self createRule:dDict ruleID:Id];
    }
    else if([commandType isEqualToString:@"DynamicRuleRemoved"]){
        NSString *Id = [[rulesDict allKeys] objectAtIndex:0]; //use this when ID key is removed
        //NSLog(@"dynamic rule removed %@",Id);
        Rule *deleteRule = [self findRule:Id];
        if(toolkit.ruleList!=nil && toolkit.ruleList.count>0)
            [toolkit.ruleList removeObject:deleteRule];
    }
    else if([commandType isEqualToString:@"DynamicAllRulesRemoved"] && toolkit.ruleList!=nil && toolkit.ruleList.count>0)
        [toolkit.ruleList removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_TABLEVIEW_RULE_COMMAND object:nil userInfo:nil];
}

-(BOOL)validateResponse:(id)sender{
    if(sender==nil)
        return NO;
    NSDictionary *data = [(NSNotification *) sender userInfo];
    if (data == nil)
        return NO;
    NSDictionary *mainDict = data[@"data"];
    if(mainDict==nil)
        return NO;
    return YES;
}
-(Rule *)createRule:(NSDictionary*)dict ruleID:(NSString*)ruleID{
    Rule *rule = [self findRule:ruleID];
    rule.name = dict[@"Name"]==nil?@"":dict[@"Name"];
    rule.isActive = [dict[@"Valid"] boolValue];
    rule.triggers= [NSMutableArray new];
    
    [self getEntriesList:dict[@"Triggers"] list:rule.triggers];
    rule.actions= [NSMutableArray new];
    [self getEntriesList:dict[@"Results"] list:rule.actions];
    return rule;
}

-(Rule*)findRule:(NSString *)ID{
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    //NSLog(@"toolkit.rulelist count before %ld ",toolkit.ruleList.count);
    
    toolkit.ruleList=toolkit.ruleList==nil?[NSMutableArray new]:toolkit.ruleList;
    //NSLog(@"toolkit.rulelist count after %ld ",toolkit.ruleList.count);
    for(Rule *rule  in toolkit.ruleList){
        if([rule.ID isEqualToString:ID]){
            return rule;
        }
    }
    //Add New Rule
    Rule *newRule=[Rule new];
    newRule.ID=ID;
    [toolkit.ruleList addObject:newRule];
    //[checkRules addObject:newRule];
    return newRule;
}

-(void)getEntriesList:(NSArray*)triggers list:(NSMutableArray *)list{
    
    for(NSDictionary *triggersDict in triggers){
        int indexID;
        int ID = [self getIntegerValue:triggersDict[@"ID"]];
        
        if([triggersDict[@"EventType"] isEqualToString:@"ClientJoined"] || [triggersDict[@"EventType"] isEqualToString:@"ClientLeft"]){
            indexID = 1;
        }
        else if ([triggersDict[@"EventType"] isEqualToString:@"AlmondModeUpdated"]){
            indexID = 1;
        }
        else if([triggersDict[@"Type"] isEqualToString:@"WeatherTrigger"]){
            indexID = [self getWeatherTriggerIndex:triggersDict];
            ID = -1;
            NSLog(@"weather type: %@, index: %d", triggersDict[@"WeatherType"], indexID);
        }
        else{
            indexID = [self getIntegerValue:triggersDict[@"Index"]];
        }
        
        SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
        BOOL isSunRiseSet = [triggersDict[@"WeatherType"] isEqualToString:@"SunRiseTime"] ||[triggersDict[@"WeatherType"] isEqualToString:@"SunSetTime"];
        subProperties.deviceId = ID;
        //NSLog(@"[triggersDict index id %@ eventType %@",[triggersDict valueForKey:@"Index"],[triggersDict valueForKey:@"EventType"]);
        subProperties.index = indexID;
        subProperties.matchData = isSunRiseSet? triggersDict[@"WeatherType"]: triggersDict[@"Value"];
        subProperties.eventType = triggersDict[@"WeatherType"]? triggersDict[@"WeatherType"]: triggersDict[@"EventType"];
        subProperties.type = triggersDict[@"Type"];
        subProperties.delay= isSunRiseSet? triggersDict[@"Value"]: triggersDict[@"PreDelay"];
        subProperties.valid= [triggersDict[@"Valid"] boolValue];
        //NSLog(@"conditions %@",[triggersDict valueForKey:@"Condition"]);
        subProperties.condition = [self getconditionType:triggersDict[@"Condition"]]? [self getconditionType:triggersDict[@"Condition"]]: isEqual;
        
        [self addTime:triggersDict timeProperty:subProperties];
        //NSLog(@"subproperty.matchdata %@",subProperties.matchData);
        [list addObject:subProperties];
    }
}

-(int)getWeatherTriggerIndex:(NSDictionary*)triggerDict{
    if([triggerDict[@"WeatherType"] isEqualToString:@"SunRiseTime"] || [triggerDict[@"WeatherType"] isEqualToString:@"SunSetTime"])
        return 1;
    else if([triggerDict[@"WeatherType"] isEqualToString:@"WeatherCondition"])
        return 2;
    else if([triggerDict[@"WeatherType"] isEqualToString:@"Temperature"])
        return 3;
    else if([triggerDict[@"WeatherType"] isEqualToString:@"Humidity"])
        return 4;
    else if([triggerDict[@"WeatherType"] isEqualToString:@"Pressure"])
        return 5;
}

-(conditionType)getconditionType:(NSString *)condition{
    //NSLog(@"getconditionType  condition type %@",condition);
    if([condition isEqualToString:@"lt"])
        return  isLessThan;
    else if([condition isEqualToString:@"gt"])
        return  isGreaterThan;
    else if([condition isEqualToString:@"le"])
        return  isLessThanOrEqual;
    else if([condition isEqualToString:@"ge"])
        return  isGreaterThanOrEqual;
    else
        return  isEqual;

}
-(void)addTime:(NSDictionary*)timeDict timeProperty:(SFIButtonSubProperties *)timeProperty{
    
    if(![timeDict[@"Type"] isEqualToString:@"TimeTrigger"])
        return;
    RulesTimeElement *time = [[RulesTimeElement alloc]init];
    time.range = [self getIntegerValue:timeDict[@"Range"]];
    time.hours = [self getIntegerValue:timeDict[@"Hour"]];
    time.mins = [self getIntegerValue:timeDict[@"Minutes"]];
    time.dayOfMonth = timeDict[@"DayOfMonth"];
    time.dayOfWeek = [self getArray:timeDict[@"DayOfWeek"]];
    time.monthOfYear = timeDict[@"MonthOfYear"];
    time.dateFrom = [self getDateFrom:time.hours minutes:time.mins];
    time.segmentType = 1;
    if(time.range > 0){
        time.dateTo =[time.dateFrom dateByAddingTimeInterval:((time.range)*60)];
        time.segmentType = 2;
    }
    
    timeProperty.time = time;
    timeProperty.eventType = @"TimeTrigger";
    
}

-(int)getIntegerValue:(NSString *) stringValue{
    @try {
        return [stringValue intValue];
    }
    @catch (NSException * e) {
        return [stringValue intValue];
    }
}
-(NSMutableArray*)getArray:(NSString*)stringValue{
    @try {
        if([stringValue isEqualToString:@"*"])
            return [NSMutableArray new];
        return [stringValue componentsSeparatedByString:@","];
    }
    @catch (NSException *exception) {
        return [NSMutableArray new];
    }
}

-(NSDate *)getDateFrom:(NSInteger)hour minutes:(NSInteger)mins{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:[NSDate date]];
    [components setHour:hour];
    [components setMinute:mins];
    return [gregorian dateFromComponents:components];
}
@end
