//
//  AffiliationResponse.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "AffiliationUserComplete.h"

@interface AffiliationUserComplete ()
@property(nonatomic) NSArray *cleanedWifiSSID;
@end

@implementation AffiliationUserComplete

- (NSString *)formattedAlmondPlusMac {
    return [self convertDecimalToMAC:self.almondplusMAC];
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

- (NSString *)convertDecimalToMAC:(NSString *)decimalString {
    //Step 1: Conversion from decimal to hexadecimal
    DLog(@"%llu", (unsigned long long) [decimalString longLongValue]);
    NSString *hexIP = [NSString stringWithFormat:@"%llX", (unsigned long long) [decimalString longLongValue]];

    NSMutableString *wifiMAC = [[NSMutableString alloc] init];
    //Step 2: Divide in pairs of 2 hex
    for (NSUInteger i = 0; i < [hexIP length]; i = i + 2) {
        NSString *ichar = [NSString stringWithFormat:@"%c%c:", [hexIP characterAtIndex:i], [hexIP characterAtIndex:i + 1]];
        [wifiMAC appendString:ichar];
    }

    [wifiMAC deleteCharactersInRange:NSMakeRange([wifiMAC length] - 1, 1)];

    DLog(@"WifiMAC: %@", wifiMAC);
    return wifiMAC;
}

@end
