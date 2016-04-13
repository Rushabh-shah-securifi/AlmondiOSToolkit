//
//  RouterParser.h
//  SecurifiToolkit
//
//  Created by Masood on 26/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouterParser : NSObject
+(void)testRouterParser;

+(void)sendrouterSummary;

+(void)getWirelessSetting;

+(void)setWirelessSetting;

+(void)updateFirmwareResponse;

+(void)setLogsResponce;

+(void)setRebootResponce;
@end
