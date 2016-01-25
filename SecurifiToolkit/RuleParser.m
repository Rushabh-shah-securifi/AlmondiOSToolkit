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
    [center addObserver:self selector:@selector(onDynamicRuleUpdateParser:) name:DYNAMIC_RULE_UPDATED object:nil];
    [center addObserver:self selector:@selector(onDynamicRuleRemovedParser:) name:DYNAMIC_RULE_REMOVE_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onDynamicRuleRemoveAllParser:) name:DYNAMIC_RULE_REMOVEALL object:nil];//DYNAMIC_RULE_ADDED
    [center addObserver:self selector:@selector(onDynamicRuleChanged:) name:DYNAMIC_RULE_LISTCHANGED object:nil];

}


-(void)onRuleListResponse:(id)sender{
    
    self.rules = [NSMutableArray new];
    NSDictionary *postData = nil;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *mainDict = [data valueForKey:@"data"];
    NSLog(@"onRuleList: %@",mainDict);
    self.rules = [NSMutableArray new];
    if([[mainDict valueForKey:@"CommandType"] isEqualToString:@"RuleList"]){
        if ([[mainDict valueForKey:@"Rules"] isKindOfClass:[NSArray class]]) {
            NSArray *dDictArray = [mainDict valueForKey:@"Rules"];
            
            for (NSDictionary *dict in dDictArray) {
                [self.rules addObject:[self createRule:dict]];
            }
        }
        toolkit.ruleList = self.rules;
        
        if (self.rules) {
            postData = @{
                     @"data" : self.rules,
                     };
        }
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_TABLEVIEW_RULE_COMMAND object:nil userInfo:postData];
    NSLog(@" rulesList in ruleParser %@",toolkit.ruleList);
}
-(Rule *)createRule:(NSDictionary*)dict{
    Rule *rule = [Rule new];
    rule.name = [dict valueForKey:@"Name"];
    rule.ID = [dict valueForKey:@"ID"];
    
    rule.triggers= [NSMutableArray new];
    
    SFIButtonSubProperties *timeProperty=[SFIButtonSubProperties new];
    timeProperty.time=[self getTime:[dict valueForKey:@"Triggers"]];
    [rule.triggers addObject:timeProperty];
    
    [self getTriggersList:[dict valueForKey:@"Triggers"] list:rule.triggers];
    
    rule.actions= [NSMutableArray new];
    [self getTriggersList:[dict valueForKey:@"Results"] list:rule.actions];
    NSLog(@" rule action list count %ld",(unsigned long)rule.actions.count);
    return rule;
    
}

-(void)getTriggersList:(NSArray*)triggers list:(NSMutableArray *)list{
   
    for(NSDictionary *triggersDict in triggers){
        SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
        subProperties.deviceId = [[triggersDict valueForKey:@"ID"] intValue];
        subProperties.index = [[triggersDict valueForKey:@"Index"] intValue];
        subProperties.matchData = [triggersDict valueForKey:@"Value"];
        subProperties.eventType = [triggersDict valueForKey:@"EventType"];
        NSLog(@"Ruleparser eventType :- %@ index :%d",subProperties.eventType,subProperties.index);
        [list addObject:subProperties];
    }
    
}

-(RulesTimeElement*)getTime:(NSArray*)triggers{
    RulesTimeElement *time = [[RulesTimeElement alloc]init];
    for(NSDictionary *timeDict in triggers){
        if([[timeDict valueForKey:@"Type"] isEqualToString:@"TimeTrigger"]){
            time.range = [[timeDict valueForKey:@"Range"] intValue];
            time.hours = [[timeDict valueForKey:@"Hour"] intValue];
            time.mins = [[timeDict valueForKey:@"Minutes"] intValue];
            time.dayOfMonth = [timeDict valueForKey:@"DayOfMonth"] ;
            time.dayOfWeek = [timeDict valueForKey:@"DayOfWeek"];
            time.monthOfYear = [timeDict valueForKey:@"MonthOfYear"];
            time.date = [self getDateFrom:time.hours minutes:time.mins];
            time.dateFrom = time.date;
            time.segmentType = 1;
            if(time.range > 0){
                
                NSDate *timeTo = [time.dateFrom dateByAddingTimeInterval:((time.range+1)*60)];
                time.dateTo = timeTo;
                time.segmentType = 2;
                
            }
            
        }
    }
    return time;
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
