//
//  RuleParser.h
//  SecurifiToolkit
//
//  Created by Masood on 21/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rule.h"
#import "RulesTimeElement.h"

@interface RuleParser : NSObject
@property(nonatomic,strong)NSMutableArray *rules;
//-(void)onRuleListResponseParser:(id)sender;
//-(NSMutableArray*)onDynamicRuleUpdateParser:(id)sender;
//-(NSMutableArray *)onDynamicRuleRemovedParser:(id)sender;
//-(NSMutableArray *)onDynamicRuleRemoveAllParser:(id)sender;
@end
