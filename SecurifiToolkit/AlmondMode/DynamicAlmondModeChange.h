//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"
#import "SFIAlmondModeRef.h"


@interface DynamicAlmondModeChange : NSObject <SFIAlmondModeRef>

@property(nonatomic) BOOL success;
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic, copy) NSString *userId;  // change made by logged in user
@property(nonatomic) SFIAlmondMode mode;

+ (DynamicAlmondModeChange *)parseJson:(NSDictionary *)payload;
@end