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
                Rule *rule = [Rule new];
                rule.name = [dict valueForKey:@"Name"];
                rule.ID = [dict valueForKey:@"ID"];
                rule.triggers = [self getTriggersList:[dict valueForKey:@"Triggers"]];
                rule.wifiClients = [self getWifiClientsList:[dict valueForKey:@"Triggers"]];
                rule.time = [self getTime:[dict valueForKey:@"Triggers"]];
                rule.actions = [self getActionsList:[dict valueForKey:@"Results"]];
                if (rule.isActive) {
                    //                    activeClientsCount++;
                }else{
                    //                    inActiveClientsCount++;
                }
                [self.rules addObject:rule];
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

-(NSMutableArray*)getTriggersList:(NSArray*)triggers{
    NSMutableArray *triggersArray;
    triggersArray = [NSMutableArray new];
    for(NSDictionary *triggersDict in triggers){
        if([[triggersDict valueForKey:@"Type"] isEqualToString:@"EventTrigger"]){
            if([[triggersDict valueForKey:@"EventType"] isEqualToString:@"AlmondModeUpdated"]){
                SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
                subProperties.deviceId = 0;
                subProperties.index = 1;
                subProperties.matchData = [triggersDict valueForKey:@"Value"];
                [triggersArray addObject:subProperties];
            }
        }
        if([[triggersDict valueForKey:@"Type"] isEqualToString:@"DeviceTrigger"]){
            SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
            subProperties.deviceId = [[triggersDict valueForKey:@"ID"] intValue];
            subProperties.index = [[triggersDict valueForKey:@"Index"] intValue];
            subProperties.matchData = [triggersDict valueForKey:@"Value"];
            [triggersArray addObject:subProperties];
        }
    }
    
    return triggersArray;
}
-(NSMutableArray*)getWifiClientsList:(NSArray*)triggers{
    NSMutableArray *clientsArray = [NSMutableArray new];
    
    //    "{"Type":"EventTrigger","ID":"%d","EventType":"%s","Value":"%s","Grouping":"%s","Validation":"%s","Condition":"%s"}"
    for(NSDictionary *clientsDict in triggers){
        
        if([[clientsDict valueForKey:@"Type"] isEqualToString:@"EventTrigger"]){
            if([[clientsDict valueForKey:@"EventType"] isEqualToString:@"AlmondModeUpdated"]){
                continue;
            }
            SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
            subProperties.deviceId = [[clientsDict valueForKey:@"ID"] intValue];
            subProperties.index = [[clientsDict valueForKey:@"Index"] intValue];
            subProperties.matchData = [clientsDict valueForKey:@"Value"];
            subProperties.eventType = [clientsDict valueForKey:@"EventType"];
            [clientsArray addObject:subProperties];
            NSLog( @" client dict %@ ",clientsDict);
        }
    }
    NSLog( @" client list %@",clientsArray);
    return clientsArray;
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
            
            //assign segment
            //if range is nil construct date
            //else construct datefrom and dateto
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


-(NSMutableArray*)getActionsList:(NSArray*)actions{
    NSMutableArray *actionsArray = [NSMutableArray new];
    for(NSDictionary *actionsDict in actions){
        if([[actionsDict valueForKey:@"Type"] isEqualToString:@"EventResult"]){
            if([[actionsDict valueForKey:@"EventType"] isEqualToString:@"AlmondModeUpdated"]){
                SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
                subProperties.deviceId = 0;
                subProperties.index = 1;
                subProperties.matchData = [actionsDict valueForKey:@"Value"];
                subProperties.delay = [actionsDict valueForKey:@"PreDelay"];
                [actionsArray addObject:subProperties];
            }
        }
        if([[actionsDict valueForKey:@"Type"] isEqualToString:@"DeviceResult"]){
            SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
            subProperties.deviceId = [[actionsDict valueForKey:@"ID"] intValue];
            subProperties.delay = [actionsDict valueForKey:@"PreDelay"];
            subProperties.index = [[actionsDict valueForKey:@"Index"] intValue];
            subProperties.matchData = [actionsDict valueForKey:@"Value"];
            [actionsArray addObject:subProperties];
        }
    }
    
    return actionsArray;
}
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
            self.rules = [NSMutableArray new];
            Rule *rule = [Rule new];
            rule.name = [dDict valueForKey:@"Name"];
            rule.ID = [dDict valueForKey:@"ID"];
            rule.triggers = [self getTriggersList:[dDict valueForKey:@"Triggers"]];
            rule.wifiClients = [self getWifiClientsList:[dDict valueForKey:@"Triggers"]];
            rule.time = [self getTime:[dDict valueForKey:@"Triggers"]];
            rule.actions = [self getActionsList:[dDict valueForKey:@"Results"]];
            if (rule.isActive) {
                //                    activeClientsCount++;
            }else{
                //                    inActiveClientsCount++;
            }
            [toolkit.ruleList addObject:rule];
            NSDictionary *postData = nil;
            if (rule) {
                data = @{
                         @"data" : rule,
                         };
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:SAVED_TABLEVIEW_DYNAMIC_RULE_UPDATED object:nil userInfo:postData];

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
        
//        if ([[mainDict valueForKey:@"Rules"] isKindOfClass:[NSArray class]]) {
//            NSDictionary *dDict = [mainDict valueForKey:@"Rules"];
//            self.rules = [NSMutableArray new];
//            Rule *rule = [Rule new];
//            rule.name = [dDict valueForKey:@"Name"];
//            rule.ID = [dDict valueForKey:@"ID"];
//            rule.triggers = [self getTriggersList:[dDict valueForKey:@"Triggers"]];
//            rule.wifiClients = [self getWifiClientsList:[dDict valueForKey:@"Triggers"]];
//            rule.time = [self getTime:[dDict valueForKey:@"Triggers"]];
//            rule.actions = [self getActionsList:[dDict valueForKey:@"Results"]];
//            if (rule.isActive) {
//                //                    activeClientsCount++;
//            }else{
//                //                    inActiveClientsCount++;
//            }
//            [toolkit.ruleList addObject:rule];
//        }
//        
//        NSLog(@" rule dynamic added %@",toolkit.ruleList);
//    }
//
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
