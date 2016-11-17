//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "DynamicAlmondModeChange.h"


@implementation DynamicAlmondModeChange

+ (DynamicAlmondModeChange *)parseJson:(NSDictionary *)payload {
    //"{"commandtype":"AlmondModeUpdated","data":{"2":{"emailid":"msd@mingfu.tw"}}}"
    /*  {"CommandType":"DynamicAlmondModeUpdated","Mode":"2","EmailId":"NULL"}  */ //NEW COMMAND

    DynamicAlmondModeChange *res = DynamicAlmondModeChange.new;
    res.success = YES;

//    NSDictionary *data = payload[@"data"];
//
//    NSString *modeValue = data.allKeys.firstObject;
    NSString *modeValue = payload[@"Mode"];
    NSString *emailId = payload[@"EmailId"];
    if (modeValue) {
        res.mode = (SFIAlmondMode) modeValue.intValue;
        res.userId = emailId;

    }

    return res;
}

@end