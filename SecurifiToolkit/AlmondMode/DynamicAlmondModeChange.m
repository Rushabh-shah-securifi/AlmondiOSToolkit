//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "DynamicAlmondModeChange.h"


@implementation DynamicAlmondModeChange

+ (DynamicAlmondModeChange *)parseJson:(NSDictionary *)payload {
    //"{"commandtype":"AlmondModeUpdated","data":{"2":{"emailid":"msd@mingfu.tw"}}}"

    DynamicAlmondModeChange *res = DynamicAlmondModeChange.new;
    res.success = YES;

    NSDictionary *data = payload[@"data"];

    NSString *modeValue = data.allKeys.firstObject;
    if (modeValue) {
        res.mode = (SFIAlmondMode) modeValue.intValue;
        res.userId = data[modeValue];

    }

    return res;
}

@end