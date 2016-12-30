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
                   name:ALMOND_PROPERTY_CHANGE_DYNAMIC_NOTIFIER
                 object:nil];
    
}

-(void)parseAlmondProperties:(id)sender{
    NSLog(@"parseAlmondProperties");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondConnectionMode connectionMode = [toolkit currentConnectionMode];
    NSDictionary *payload;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || dataInfo[@"data"]==nil ) {
        return;
    }
    
    if([toolkit currentConnectionMode]==SFIAlmondConnectionMode_local){
        payload = dataInfo[@"data"];
    }else{
        if(![dataInfo[@"data"] isKindOfClass:[NSData class]])
            return;
        payload = [dataInfo[@"data"] objectFromJSONData];
    }
    
    NSLog(@"dynamic subscription - payload: %@", payload);
    NSString *almondMAC = payload[ALMONDMAC];
    NSString *commandType = payload[COMMAND_TYPE];

    if([commandType isEqualToString:@"AlmondPropertiesResponse"] || [commandType isEqualToString:@"AlmondProperties"]){
        if(payload[@"AlmondProperties"]){//to handle while affiliation
            [AlmondProperties parseAlomndProperty:payload[@"AlmondProperties"]];
        }else{
            [AlmondProperties parseAlomndProperty:payload];
        }
        
    }
    
    else if([commandType isEqualToString:@"DynamicAlmondPropertiesResponse"]){
        if([self isNotMatchingMac:almondMAC])
            return;
        
        if(payload[@"AlmondProperties"]){
            [AlmondProperties parseNewDynamicProperty:payload];
        }else{//to support old firmware
            [AlmondProperties parseDynamicProperty:payload];
        }
        
    }
    else if([commandType isEqualToString:@"DynamicAlmondLocationChangeResponse"]){
        //need to store location in current almond
        if([self isNotMatchingMac:almondMAC])
            return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALMOND_PROPERTIES_PARSED object:nil];
}

- (BOOL)isNotMatchingMac:(NSString *)almondMAC{
    SFIAlmondConnectionMode connectionMode = [[SecurifiToolkit sharedInstance] currentConnectionMode];
    if(connectionMode == SFIAlmondConnectionMode_cloud && ![almondMAC isEqualToString:[AlmondManagement currentAlmond].almondplusMAC])
        return YES;
    else
        return NO;
}

@end
