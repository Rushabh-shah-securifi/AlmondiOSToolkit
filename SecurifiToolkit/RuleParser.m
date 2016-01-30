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
NSArray *deviceArray;\
SecurifiToolkit *toolkit;
- (instancetype)init {
    self = [super init];
    [self initNotification];
   
    return self;
}
-(void)initNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onRuleListResponse:) name:RULE_LIST_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onDynamicRuleUpdateParser:) name:DYNAMIC_RULE_UPDATED object:nil];
    [center addObserver:self selector:@selector(onDynamicRuleRemovedParser:) name:DYNAMIC_RULE_REMOVE_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onDynamicRuleRemoveAllParser:) name:DYNAMIC_RULE_REMOVEALL object:nil];//DYNAMIC_RULE_ADDED
    [center addObserver:self selector:@selector(onDynamicRuleChanged:) name:DYNAMIC_RULE_LISTCHANGED object:nil];
    
}


-(void)onRuleListResponse:(id)sender{
    if(sender==nil)
        return;
    NSDictionary *data = [(NSNotification *) sender userInfo];
    if (data == nil)
        return;
    NSDictionary *mainDict = [data valueForKey:@"data"];
    if(mainDict==nil)
        return;
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    toolkit.ruleList = [NSMutableArray new];
    NSLog(@"onRuleList: %@",mainDict);
    if([[mainDict valueForKey:@"CommandType"] isEqualToString:@"RuleList"]){
        NSArray *dDictArray = [mainDict valueForKey:@"Rules"];
        if (dDictArray)
            for (NSDictionary *dict in dDictArray) {
                [toolkit.ruleList  addObject:[self createRule:dict]];
            }
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_TABLEVIEW_RULE_COMMAND object:nil userInfo:nil];
    NSLog(@" rulesList in ruleParser %@",toolkit.ruleList);
}
-(Rule *)createRule:(NSDictionary*)dict{
    Rule *rule = [Rule new];
    rule.name = [dict valueForKey:@"Name"]==nil?@"":[dict valueForKey:@"Name"];
    rule.ID = [dict valueForKey:@"ID"];
    rule.triggers= [NSMutableArray new];
    [self addTime:[dict valueForKey:@"Triggers"] list:rule.triggers];
    [self getEntriesList:[dict valueForKey:@"Triggers"] list:rule.triggers];
    
    rule.actions= [NSMutableArray new];
    [self getEntriesList:[dict valueForKey:@"Results"] list:rule.actions];
    return rule;
    
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

//"{"Type":"DeviceResult","ID":"%d","Index":"%d","Value":"%s","PreDelay":"%d","Validation":"%s"}"



-(void)onDynamicRuleUpdateParser:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *mainDict = [data valueForKey:@"data"];
    NSLog(@"dynamaic updated : %@",mainDict);
    if([[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicRuleUpdated"] || [[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicRuleAdded"]){
        if ([[mainDict valueForKey:@"Rules"] isKindOfClass:[NSArray class]]) {
            NSDictionary *dDict = [mainDict valueForKey:@"Rules"];
            //            self.rules = [NSMutableArray new];
            //            Rule *rule = [Rule new];
            //            rule.name = [dDict valueForKey:@"Name"];
            //            rule.ID = [dDict valueForKey:@"ID"];
            //            rule.triggers = [self getTriggersList:[dDict valueForKey:@"Triggers"] ];
            //            rule.wifiClients = [self getWifiClientsList:[dDict valueForKey:@"Triggers"]];
            //            rule.time = [self getTime:[dDict valueForKey:@"Triggers"]];
            //            rule.actions = [self getTriggersList:[dDict valueForKey:@"Results"]];
            //            if (rule.isActive) {
            //                //                    activeClientsCount++;
            //            }else{
            //                //                    inActiveClientsCount++;
            //            }
            //            [toolkit.ruleList addObject:rule];
            //            NSDictionary *postData = nil;
            //            if (rule) {
            //                data = @{
            //                         @"data" : rule,
            //                         };
            //            }
            //            [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_TABLEVIEW_DYNAMIC_RULE_UPDATED object:nil userInfo:postData];
            
        }
        
        
        
        
        
        NSLog(@" rule dynamic updated %@",toolkit.ruleList);
    }
    
    return;
}
-(void)onDynamicRuleRemovedParser:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *mainDict = [data valueForKey:@"data"];
    NSLog(@"dynamaic removed: %@",mainDict);
    if([[mainDict valueForKey:@"CommandType"] isEqualToString:@"DynamicRuleRemoved"]){
        NSDictionary *dDict = [mainDict valueForKey:@"Rules"];
        NSString *RemoveRuleID = [dDict valueForKey:@"ID"];
        Rule *deleteRule = [Rule new];
        for(Rule *toBeDeleteRule in self.rules){
            if([toBeDeleteRule.ID isEqualToString:RemoveRuleID])
            {
                deleteRule = toBeDeleteRule;
            }
        }
        [toolkit.ruleList removeObject:deleteRule];
    }
    // toolkit.ruleList = self.rules;
    
    return ;
    
}
-(void)onDynamicRuleRemoveAllParser:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *mainDict = [data valueForKey:@"data"];
    NSLog(@"dynamaic removed: %@",mainDict);
    if([[mainDict valueForKey:@"CommandType"] isEqualToString:@"RemoveAllRules"]){
        if([[mainDict valueForKey:@"Success"] isEqualToString:@"true"]){
            [toolkit.ruleList removeAllObjects];
        }
        
    }
    return;
}
-(void)onDynamicRuleChanged:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *mainDict = [data valueForKey:@"data"];
    NSLog(@"dynamaic added in parser : %@",mainDict);
    
    
    
    if([[mainDict valueForKey:@"commandtype"] isEqualToString:@"RuleUpdated"] || [[mainDict valueForKey:@"commandtype"] isEqualToString:@"RuleAdded"] || [[mainDict valueForKey:@"commandtype"] isEqualToString:@"RemoveRule"] || [[mainDict valueForKey:@"commandtype"] isEqualToString:@"RuleRemoveAll"]){//RemoveRule
        NSLog(@" rulelist update sended");
        [self requestForRuleList];
        
    }
    
    return;
    
}
-(void)requestForRuleList{
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    GenericCommand *cmd = [GenericCommand websocketRequestAlmondRules];
    [[SecurifiToolkit sharedInstance] asyncSendToLocal:cmd almondMac:plus.almondplusMAC];
}


@end
