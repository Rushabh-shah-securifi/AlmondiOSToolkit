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
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || dataInfo[@"data"]==nil ) {
        return;
    }
    
    if(local){
        payload = dataInfo[@"data"];
    }else{
        NSLog(@"cloud data");
        if(![dataInfo[@"data"] isKindOfClass:[NSData class]])
            return;
        payload = [dataInfo[@"data"] objectFromJSONData];
    }
    
    //    payload = [self parseJson:@"DeviceListResponse"];
    //NSLog(@"devices - payload: %@", payload);
    
    BOOL isMatchingAlmondOrLocal = ([payload[ALMONDMAC] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
    NSString *commandType = payload[COMMAND_TYPE];

    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUBSCRIPTION_PARSED object:nil];
}
@end
