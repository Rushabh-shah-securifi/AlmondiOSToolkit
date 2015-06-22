//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "AlmondModeChangeResponse.h"


@implementation AlmondModeChangeResponse

+ (instancetype)parseJson:(NSDictionary *)payload {
//     // {"mii":"165","commandtype":"updatealmondmode","success":"true","data":{"mode":"3","emailid":"msd@mingfu.tw"}}

    NSString *str;

    AlmondModeChangeResponse *res = [AlmondModeChangeResponse new];

    str = payload[@"success"];
    res.success = [str isEqualToString:@"true"];

    return res;
}


@end