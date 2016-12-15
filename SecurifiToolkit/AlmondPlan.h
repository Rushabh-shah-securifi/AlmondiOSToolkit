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
    PlanTypeOneMonth,
    PlanTypeThreeMonths,
    PlanTypeSixMonths,
    PlanTypeCancel,
    PlanTypeFreeExpired
};

@interface AlmondPlan : NSObject
@property (nonatomic)PlanType planType;
@property (nonatomic)NSString *renewalDate;

+ (NSDictionary *)getSubscriptions:(NSDictionary *)almondsDict;
+ (NSString *)getPlanString:(PlanType)planType;
+ (AlmondPlan *)getAlmondPlan;
+ (NSInteger)getPlanAmount:(PlanType)planType;
+ (NSString *)getPlanID:(PlanType)planType;
+ (BOOL)hasPaidSubscription;
+ (void)updateAlmondPlan:(PlanType)planType;
+ (NSInteger)getPlanMonths:(PlanType)planType;
@end
