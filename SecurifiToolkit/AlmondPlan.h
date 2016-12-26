//
//  AlmondPlan.h
//  SecurifiToolkit
//
//  Created by Masood on 12/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PlanType){
    PlanTypeNone,
    PlanTypeFree,
    PlanTypeOneDay,
    PlanTypeOneMonth,
    PlanTypeThreeMonths,
    PlanTypeSixMonths,
    PlanTypeCancel,
    PlanTypeFreeExpired
};

@interface AlmondPlan : NSObject
@property (nonatomic)PlanType planType;
@property (nonatomic)NSString *renewalDate;

+ (NSMutableDictionary *)getSubscriptions:(NSDictionary *)almondsDict;
+ (NSString *)getPlanString:(PlanType)planType;
+ (AlmondPlan *)getAlmondPlan:(NSString *)mac;
+ (NSInteger)getPlanAmount:(PlanType)planType;
+ (NSString *)getPlanID:(PlanType)planType;
+ (BOOL)hasPaidSubscription;
+ (void)updateAlmondPlan:(PlanType)planType epoch:(NSString *)epoch mac:(NSString *)mac;
+ (NSInteger)getPlanMonths:(PlanType)planType;
+ (PlanType)getPlanType:(NSString *)planString;
+ (BOOL)hasSubscription:(NSString *)mac;
@end
