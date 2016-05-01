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

@implementation RuleParser


- (instancetype)init {
    self = [super init];
    [self initNotification];
    
    return self;
}

-(void)initNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onRuleListResponse:) name:RULE_LIST_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onRuleListResponse:) name:NOTIFICATION_RULE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER object:nil];
}


-(void)onRuleListResponse:(id)sender{
    if(![self validateResponse:sender])
        return;
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    BOOL local = [toolkit useLocalNetwork:[toolkit currentAlmond].almondplusMAC];
    NSDictionary *mainDict=[[(NSNotification *) sender userInfo] valueForKey:@"data"];
    if(!local)
         mainDict = [[[(NSNotification *) sender userInfo] valueForKey:@"data"] objectFromJSONData];
    
    if([mainDict valueForKey:@"CommandType"]==nil)
        return;

    NSString *commandType=[mainDict valueForKey:@"CommandType"];
    NSDictionary *rulesDict = mainDict[@"Rules"];
    NSLog(@"onRuleList: %@",mainDict);
    //RuleList
    if([commandType isEqualToString:@"RuleList"]){
        NSDictionary *rulesPayload = [mainDict valueForKey:@"Rules"];
        NSArray *ruleIds = rulesPayload.allKeys;
        for (NSString *key in ruleIds) {
            [self createRule:rulesPayload[key]];
        }
    }
    else if([commandType isEqualToString:@"DynamicRuleUpdated"] || [commandType isEqualToString:@"DynamicRuleAdded"]){
        NSString *Id = [[rulesDict allKeys] objectAtIndex:0];
        NSDictionary *dDict = rulesDict[Id];
        [self createRule:dDict];
    }
    else if([commandType isEqualToString:@"DynamicRuleRemoved"]){
        NSString *Id = [[rulesDict allKeys] objectAtIndex:0]; //use this when ID key is removed
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
    NSDictionary *mainDict = [data valueForKey:@"data"];
    if(mainDict==nil)
        return NO;
    return YES;
}
-(Rule *)createRule:(NSDictionary*)dict{
    Rule *rule = [self findRule:[dict valueForKey:@"ID"]];
    rule.name = [dict valueForKey:@"Name"]==nil?@"":[dict valueForKey:@"Name"];
    rule.isActive = [[dict valueForKey:@"Valid"] boolValue];
    rule.triggers= [NSMutableArray new];
    
    [self getEntriesList:[dict valueForKey:@"Triggers"] list:rule.triggers];
    rule.actions= [NSMutableArray new];
    [self getEntriesList:[dict valueForKey:@"Results"] list:rule.actions];
    return rule;
}

-(Rule*)findRule:(NSString *)id{
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    toolkit.ruleList=toolkit.ruleList==nil?[NSMutableArray new]:toolkit.ruleList;
    
    for(Rule *rule  in toolkit.ruleList){
        if([rule.ID isEqualToString:id]){
            return rule;
        }
    }
    //Add New Rule
    Rule *newRule=[Rule new];
    newRule.ID=id;
    [toolkit.ruleList addObject:newRule];
    //[checkRules addObject:newRule];
    return newRule;
}

-(void)getEntriesList:(NSArray*)triggers list:(NSMutableArray *)list{
    for(NSDictionary *triggersDict in triggers){
        SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
        subProperties.deviceId = [self getIntegerValue:[triggersDict valueForKey:@"ID"]];
        NSLog(@"[triggersDict index id %@",[triggersDict valueForKey:@"Index"]);
        subProperties.index = [self getIntegerValue:[triggersDict valueForKey:@"Index"]];
        subProperties.matchData = [triggersDict valueForKey:@"Value"];
        subProperties.eventType = [triggersDict valueForKey:@"EventType"];
        subProperties.type = [triggersDict valueForKey:@"Type"];
        subProperties.delay=[triggersDict valueForKey:@"PreDelay"];
        subProperties.valid= [[triggersDict valueForKey:@"Valid"] boolValue];
        [self addTime:triggersDict timeProperty:subProperties];
        [list addObject:subProperties];
    }
}

-(void)addTime:(NSDictionary*)timeDict timeProperty:(SFIButtonSubProperties *)timeProperty{
    
    if(![[timeDict valueForKey:@"Type"] isEqualToString:@"TimeTrigger"])
        return;
    RulesTimeElement *time = [[RulesTimeElement alloc]init];
    time.range = [self getIntegerValue:[timeDict valueForKey:@"Range"]];
    time.hours = [self getIntegerValue:[timeDict valueForKey:@"Hour"]];
    time.mins = [self getIntegerValue:[timeDict valueForKey:@"Minutes"]];
    time.dayOfMonth = [timeDict valueForKey:@"DayOfMonth"];
    time.dayOfWeek = [self getArray:[timeDict valueForKey:@"DayOfWeek"]];
    time.monthOfYear = [timeDict valueForKey:@"MonthOfYear"];
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
