//
//  AlmondPropertiesParser.m
//  SecurifiToolkit
//
//  Created by Masood on 12/19/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondPropertiesParser.h"
#import "AlmondPlusSDKConstants.h"
#import "AlmondManagement.h"
#import "SecurifiToolkit.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "AlmondProperties.h"

@implementation AlmondPropertiesParser
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
               selector:@selector(parseAlmondProperties:)
                   name:ALMOND_PROPERTIES_NOTIFIER
                 object:nil];
    
}

-(void)parseAlmondProperties:(id)sender{
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
    
    if([commandType isEqualToString:@"AlmondProperties"]){
        AlmondProperties *almondProp = [[AlmondProperties alloc]init];
        [AlmondProperties parseAlomndProperty:almondProp];
    }
    else if([commandType isEqualToString:@"DynamicAlmondProperties"]){
        NSString *propertyType = payload[@"Action"];
        NSString *value = payload[propertyType];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALMOND_PROPERTIES_PARSED object:nil];
}

@end
