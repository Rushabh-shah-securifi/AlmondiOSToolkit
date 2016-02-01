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
}


-(void)onRuleListResponse:(id)sender{
    if(![self validateResponse:sender])
        return;
    NSDictionary *mainDict = [[(NSNotification *) sender userInfo] valueForKey:@"data"];
    NSString *commandType=[mainDict valueForKey:@"CommandType"] ;
    NSLog(@"onRuleList: %@",mainDict);
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    //RuleList
    if([commandType isEqualToString:@"RuleList"]){
        NSArray *dDictArray = [mainDict valueForKey:@"Rules"];
        if (dDictArray)
            for (NSDictionary *dict in dDictArray) {
                [self createRule:dict];
            }
        
    }else if([commandType isEqualToString:@"DynamicRuleUpdated"] || [commandType isEqualToString:@"DynamicRuleAdded"]){
        NSDictionary *dDict = [mainDict valueForKey:@"Rules"];
        NSLog(@"onRuleListResponse Rule is %@",dDict);
        [self createRule:dDict];
    }else if([commandType isEqualToString:@"DynamicRuleRemoved"]){
        NSDictionary *dDict = [mainDict valueForKey:@"Rules"];
        Rule *deleteRule = [self findRule:[dDict valueForKey:@"ID"]];
        if(toolkit.ruleList!=nil && toolkit.ruleList.count>0)
            [toolkit.ruleList removeObject:deleteRule];
    }else if([commandType isEqualToString:@"DynamicAllRulesRemoved"] && toolkit.ruleList!=nil && toolkit.ruleList.count>0)
            [toolkit.ruleList removeAllObjects];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_TABLEVIEW_RULE_COMMAND object:nil userInfo:nil];
    NSLog(@" rulesList in ruleParser %@",toolkit.ruleList);
}
-(BOOL)validateResponse:(id)sender{
    NSLog(@"validateResponse: ");
    if(sender==nil)
        return NO;
    NSDictionary *data = [(NSNotification *) sender userInfo];
    if (data == nil)
        return NO;
    NSDictionary *mainDict = [data valueForKey:@"data"];
    if(mainDict==nil)
        return NO;
    if([mainDict valueForKey:@"CommandType"]==nil)
        return NO;
    return YES;
}
-(Rule *)createRule:(NSDictionary*)dict{
    Rule *rule = [self findRule:[dict valueForKey:@"ID"]];
    rule.name = [dict valueForKey:@"Name"]==nil?@"":[dict valueForKey:@"Name"];
    
    rule.triggers= [NSMutableArray new];
    [self addTime:[dict valueForKey:@"Triggers"] list:rule.triggers];
    [self getEntriesList:[dict valueForKey:@"Triggers"] list:rule.triggers];
    
    rule.actions= [NSMutableArray new];
    [self getEntriesList:[dict valueForKey:@"Results"] list:rule.actions];
    NSLog(@"CreateRule Rule is %d",rule);
    return rule;
    
}
-(Rule*)findRule:(NSString *)id{
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    toolkit.ruleList=toolkit.ruleList==nil?[NSMutableArray new]:toolkit.ruleList;
    
    for(Rule *rule  in toolkit.ruleList){
        if([rule.ID isEqualToString:id]){
            NSLog(@"findRule match %@",toolkit.ruleList);
            return rule;
        }
    }
    //Add New Rule
    Rule *newRule=[Rule new];
    newRule.ID=id;
    [toolkit.ruleList addObject:newRule];
    //[checkRules addObject:newRule];
     NSLog(@"findRule %lu",toolkit.ruleList.count);
    return newRule;
}

-(void)getEntriesList:(NSArray*)triggers list:(NSMutableArray *)list{
    for(NSDictionary *triggersDict in triggers){
        SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
        subProperties.deviceId = [self getIntegerValue:[triggersDict valueForKey:@"ID"]];
        subProperties.index = [self getIntegerValue:[triggersDict valueForKey:@"Index"]];
        subProperties.matchData = [triggersDict valueForKey:@"Value"];
        subProperties.eventType = [triggersDict valueForKey:@"EventType"];
        NSLog(@"Ruleparser eventType :- %@ index :%d",subProperties.eventType,subProperties.deviceId);
        
        [list addObject:subProperties];
    }
}

-(void)addTime:(NSArray*)triggers list:(NSMutableArray*)list{
    for(NSDictionary *timeDict in triggers){
        NSString *type=[timeDict valueForKey:@"Type"];
        if(type!=nil && [type isEqualToString:@"TimeTrigger"]){
            SFIButtonSubProperties *timeProperty=[SFIButtonSubProperties new];
            RulesTimeElement *time = [[RulesTimeElement alloc]init];
            
            time.range = [self getIntegerValue:[timeDict valueForKey:@"Range"]];
            time.hours = [self getIntegerValue:[timeDict valueForKey:@"Hour"]];
            time.mins = [self getIntegerValue:[timeDict valueForKey:@"Minutes"]];
            //time.dayOfMonth = [self getIntegerValue:[timeDict valueForKey:@"DayOfMonth"]];
            //time.dayOfWeek = [self getIntegerValue:[timeDict valueForKey:@"DayOfWeek"]];
            //time.monthOfYear = [self getIntegerValue:[timeDict valueForKey:@"MonthOfYear"]];
            time.date = [self getDateFrom:time.hours minutes:time.mins];
            time.dateFrom = time.date;
            time.segmentType = 1;
            if(time.range > 0){
                NSDate *timeTo = [time.dateFrom dateByAddingTimeInterval:((time.range+1)*60)];
                time.dateTo = timeTo;
                time.segmentType = 2;
            }
            
            timeProperty.time = time;
            timeProperty.eventType = @"TimeTrigger";
            [list addObject:timeProperty];
            break;
        }
    }
}

-(int)getIntegerValue:(NSString *) stringValue{
    @try {
        return [stringValue intValue];
    }
    @catch (NSException * e) {
        return [stringValue intValue];
    }
}
-(int)getStringValue:(NSString *) stringValue{
    return stringValue==nil?@"":stringValue;
}
-(NSDate *)getDateFrom:(NSInteger)hour minutes:(NSInteger)mins{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:[NSDate date]];
    [components setHour:hour];
    [components setMinute:mins];
    NSDate * date = [gregorian dateFromComponents:components];
    return date;
}
//{"CommandType":"DynamicRuleRemoved","Rules":{"ID""7"}}
//{"CommandType":"DynamicAllRulesRemoved"}
//"{"Type":"DeviceResult","ID":"%d","Index":"%d","Value":"%s","PreDelay":"%d","Validation":"%s"}"


@end
