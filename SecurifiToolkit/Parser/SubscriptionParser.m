//
//  SubscriptionParser.m
//  SecurifiToolkit
//
//  Created by Masood on 12/19/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SubscriptionParser.h"
#import "AlmondPlusSDKConstants.h"
#import "AlmondManagement.h"
#import "SecurifiToolkit.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "AlmondPlan.h"

@implementation SubscriptionParser
- (instancetype)init {
    self = [super init];
    if(self){
        [self initNotification];
    }
    return self;
}

-(void)initNotification{
    NSLog(@"init device notification");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(parseDeviceListAndDynamicDeviceResponse:)
                   name:NOTIFICATION_SUBSCRIPTION_RESPONSE
                 object:nil];

}

-(void)parseDeviceListAndDynamicDeviceResponse:(id)sender{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
 
    NSDictionary *payload;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || dataInfo[@"data"]==nil ) {
        return;
    }
    
    if([toolkit currentConnectionMode]==SFIAlmondConnectionMode_local){
        payload = dataInfo[@"data"];
    }else{
        NSLog(@"cloud data");
        if(![dataInfo[@"data"] isKindOfClass:[NSData class]])
            return;
        payload = [dataInfo[@"data"] objectFromJSONData];
    }
    
    NSLog(@"dynamic subscription - payload: %@", payload);
    
    if([toolkit currentConnectionMode]==SFIAlmondConnectionMode_local)
        return;
    NSString *commandType = payload[COMMAND_TYPE];
    
    if([commandType isEqualToString:@"SubscribeMe"]){
        PlanType type = [AlmondPlan getPlanType:payload[@"PlanID"]];
        [AlmondPlan updateAlmondPlan:type epoch:payload[@"RenewalEpoch"] mac:payload[@"AlmondMAC"]];
    }else if([commandType isEqualToString:@"DeleteSubscription"]){
        [AlmondPlan updateAlmondPlan:PlanTypeFreeExpired epoch:nil mac:payload[@"AlmondMAC"]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUBSCRIPTION_PARSED object:nil];
}
@end
