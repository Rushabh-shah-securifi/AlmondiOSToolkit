//
//  AffiliationResponse.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "AffiliationUserComplete.h"
#import "SFIAlmondPlus.h"

@interface AffiliationUserComplete ()
@property(nonatomic) NSArray *cleanedWifiSSID;
@end

@implementation AffiliationUserComplete

- (NSString *)formattedAlmondPlusMac {
    return [SFIAlmondPlus convertDecimalToMacHex:self.almondplusMAC];
}

- (NSInteger)ssidCount {
    if (!self.cleanedWifiSSID) {
        self.cleanedWifiSSID = [self cleanSSIDNames];
    }
    return self.cleanedWifiSSID.count;
}

- (NSArray *)ssidNames {
    if (!self.cleanedWifiSSID) {
        self.cleanedWifiSSID = [self cleanSSIDNames];
    }
    return self.cleanedWifiSSID;
}

- (NSArray *)cleanSSIDNames {
    NSArray *rawNames = [self.wifiSSID componentsSeparatedByString:@","];

    NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];

    // strip whitespace
    NSMutableArray *cleaned = [NSMutableArray arrayWithArray:rawNames];
    for (uint index = 0; index < cleaned.count; index++) {
        NSString *sid = cleaned[index];
        cleaned[index] = [sid stringByTrimmingCharactersInSet:charSet];;
    }

    return cleaned;
}

@end
