//
//  AffiliationResponse.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "AffiliationUserComplete.h"

@implementation AffiliationUserComplete

- (NSString *)formattedAlmondPlusMac {
    return [self convertDecimalToMAC:self.almondplusMAC];
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
