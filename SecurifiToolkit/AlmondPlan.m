//
//  AlmondPlan.m
//  SecurifiToolkit
//
//  Created by Masood on 12/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondPlan.h"
#import "SecurifiToolkit.h"
#import "AlmondManagement.h"
#import "NSDate+Convenience.h"

@implementation AlmondPlan
/*
 {
 CommandType: "Subscriptions",
 Almonds: {
 "23232323232": {
 PlanID: "Free",
 Time: 30
 },
 "3434343434": {
 PlanID: "one day"
 }
 }
 }
 */
+ (NSMutableDictionary *)getSubscriptions:(NSDictionary *)almondsDict{
    NSMutableDictionary *subcriptionsDict = [NSMutableDictionary new];
    for(NSString *almond in almondsDict.allKeys){
        NSDictionary *almondSubscDict = almondsDict[almond];
        
        AlmondPlan *plan = [AlmondPlan new];
        plan.planType = [self getPlanType:almondSubscDict[@"PlanID"]];
        
        plan.renewalDate = almondSubscDict[@"RenewalEpoch"]? [NSDate getSubscriptionExpiryDate:almondSubscDict[@"RenewalEpoch"] format:@"dd/MM/yyyy"]: @"**";

        NSLog(@"renewal date: %@", plan.renewalDate);
        [subcriptionsDict setObject:plan forKey:almond];
    }
    return subcriptionsDict;
}

+ (AlmondPlan *)getAlmondPlan:(NSString *)mac{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    AlmondPlan *plan = toolkit.subscription[mac];
    if(plan == nil){
        NSLog(@"plan nil");
        plan = [AlmondPlan new];
        plan.planType = PlanTypeNone;
    }
    return plan;
}

+ (void)updateAlmondPlan:(PlanType)planType epoch:(NSString *)epoch mac:(NSString *)mac{
    NSLog(@"updateAlmondPlan: %d", planType);
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    AlmondPlan *plan = toolkit.subscription[mac];
    if(plan == nil)
        [self addAlmondPlan:planType epoch:epoch mac:mac];
    else{
        plan.planType = planType;
        plan.renewalDate = [NSDate getSubscriptionExpiryDate:epoch format:@"dd/MM/yyyy"];
    }
}

+ (void)addAlmondPlan:(PlanType)planType epoch:(NSString *)epoch mac:(NSString *)mac{
    NSLog(@"addAlmondPlan");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    AlmondPlan *plan = [AlmondPlan new];
    plan.planType = planType;
    plan.renewalDate = [NSDate getSubscriptionExpiryDate:epoch format:@"dd/MM/yyyy"];
    [toolkit.subscription setObject:plan forKey:mac];
}

//Free|Cancelled|Paid1M|Paid3M         TrialExpired
+ (PlanType)getPlanType:(NSString *)planString{
    NSString *planStrLC = planString.lowercaseString;
    if([planStrLC isEqualToString:@"free"]){
        return PlanTypeFree;
    }else if([planStrLC isEqualToString:@"freeexpired"]){
        return PlanTypeFreeExpired;
    }else if([planStrLC isEqualToString:@"paid1d"]){
        return PlanTypeOneDay;
    }else if([planStrLC isEqualToString:@"paid1m"]){
        return PlanTypeOneMonth;
    }else if([planStrLC isEqualToString:@"paid3m"]){
        return PlanTypeThreeMonths;
    }else if([planStrLC isEqualToString:@"paid6m"]){
        return PlanTypeSixMonths;
    }
}

+ (NSString *)getPlanID:(PlanType)planType{
    switch (planType) {
        case PlanTypeFree:
            return @"Free";
            break;
        case PlanTypeOneDay:
            return @"Paid1D";
            break;
        case PlanTypeOneMonth:
            return @"Paid1M";
            break;
        case PlanTypeThreeMonths:
            return @"Paid3M";
            break;
        case PlanTypeSixMonths:
            return @"Paid6M";
            break;
        default:
            return @"***";
            break;
    }
}

+ (NSString *)getPlanString:(PlanType)planType{
    switch (planType) {
        case PlanTypeNone:
            return @"No Plan";
            break;
        case PlanTypeFree:
            return @"Free Plan";
            break;
        case PlanTypeOneDay:
            return @"1 Day Test";
            break;
        case PlanTypeOneMonth:
            return @"1 Month $5";
            break;
        case PlanTypeThreeMonths:
            return @"3 Months $12";
            break;
        case PlanTypeSixMonths:
            return @"6 Months $20";
            break;
        default:
            return @"***";
            break;
    }
}

+ (NSInteger)getPlanAmount:(PlanType)planType{
    switch (planType) {
        case PlanTypeFree:
            return 0;
            break;
        case PlanTypeOneDay:
            return 1;
            break;
        case PlanTypeOneMonth:
            return 5;
            break;
        case PlanTypeThreeMonths:
            return 12;
            break;
        case PlanTypeSixMonths:
            return 20;
            break;
        default:
            return -1;
            break;
    }
}

+ (NSInteger)getPlanMonths:(PlanType)planType{
    switch (planType) {
        case PlanTypeFree:
            return 1;
            break;
        case PlanTypeOneDay:
            return 1;
            break;
        case PlanTypeOneMonth:
            return 1;
            break;
        case PlanTypeThreeMonths:
            return 3;
            break;
        case PlanTypeSixMonths:
            return 6;
            break;
        default:
            return -1;
            break;
    }
}
+ (BOOL)hasPaidSubscription{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for(AlmondPlan *plan in toolkit.subscription.allValues){
        if(plan.planType != PlanTypeFree && plan.planType != PlanTypeFreeExpired && plan.planType != PlanTypeNone){
            return YES;
        }
    }
    return NO;
}

+ (BOOL)hasSubscription:(NSString *)mac{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    AlmondPlan *plan = toolkit.subscription[mac];
    if(plan.planType != PlanTypeFreeExpired && plan.planType != PlanTypeNone){
        return YES;
    }
    return NO;
}
@end
