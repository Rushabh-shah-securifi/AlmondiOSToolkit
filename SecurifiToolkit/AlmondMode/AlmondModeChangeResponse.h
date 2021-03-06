//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
<root>
<AlmondModeChangeResponse success="true">
<Reason>Almond Mode changed successfully</Reason>
<ReasonCode>1</ReasonCode>
</AlmondModeChangeResponse>
</root>
 */

@interface AlmondModeChangeResponse : NSObject

+ (instancetype)parseJson:(NSDictionary *)payload;

@property(nonatomic) BOOL success;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) int reasonCode;

@end