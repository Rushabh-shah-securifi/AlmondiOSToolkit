//
//  Rule.h
//  SecurifiApp
//
//  Created by Masood on 10/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RulesTimeElement.h"

@interface Rule : NSObject

@property (nonatomic,strong) NSMutableArray *triggers;
@property (nonatomic,strong) NSMutableArray *actions;
@property (nonatomic, strong) RulesTimeElement *time;
@property (nonatomic) BOOL isActive;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* lastActivated;
@property (nonatomic, strong) NSString* ID;
@end
