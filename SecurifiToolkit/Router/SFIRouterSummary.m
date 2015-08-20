//
//  SFIRouterSummary.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIRouterSummary.h"
#import "SFIWirelessSetting.h"
#import "SFIWirelessSummary.h"
#import "NSData+Securifi.h"

@implementation SFIRouterSummary

- (NSString *)decryptPassword:(NSString *)almondMac {
    NSString *pwd = self.password;
    if (!pwd) {
        return nil;
    }

    NSData *payload = [[NSData alloc] initWithBase64EncodedString:pwd options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [payload securifiDecryptPasswordForAlmond:almondMac almondUptime:self.uptime];
}

- (void)updateWirelessSummaryWithSettings:(NSArray *)wirelessSettings {
    for (SFIWirelessSummary *sum in self.wirelessSummaries) {
        // check for wireless settings
        for (SFIWirelessSetting *setting in wirelessSettings) {
            if (setting.index == sum.wirelessIndex) {
                sum.ssid = setting.ssid;
                sum.enabled = setting.enabled;
                break;
            }
        }
    }
}

@end
