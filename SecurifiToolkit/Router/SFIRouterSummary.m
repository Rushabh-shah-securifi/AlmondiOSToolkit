//
//  SFIRouterSummary.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <CommonCrypto/CommonCryptoError.h>
#import <CommonCrypto/CommonCryptor.h>
#import "SFIRouterSummary.h"
#import "SFIWirelessSetting.h"
#import "SFIWirelessSummary.h"

@implementation SFIRouterSummary

- (NSString *)toHexString:(int[])val length:(int)length {
    NSString *out = @"";
    for (int i = 0; i < length; i++) {
        out = [out stringByAppendingFormat:@"%x", val[i]];
    }
    return out;
}

- (NSString *)decryptPassword:(NSString*)almondMac {
    NSString *pwd = self.password;
    if (!pwd) {
        return nil;
    }

    // Compute the IV
    const char *MAC = [almondMac cStringUsingEncoding:NSUTF8StringEncoding];
    const char *UPTIME = [self.uptime cStringUsingEncoding:NSUTF8StringEncoding];;

    int IV[kCCBlockSizeAES128];
    bzero(IV, sizeof(IV));

    for (int i = 0; i < kCCBlockSizeAES128; i++) {
        IV[i] = ((MAC[i] + UPTIME[i]) % 94 + 33);
    }

    NSLog(@"payload: %@", pwd);
    NSLog(@"mac: %@", almondMac);
    NSLog(@"uptime: %@", self.uptime);
    NSLog(@"iv: %@", [self toHexString:IV length:kCCBlockSizeAES128]);

    // Base64 decode the password
    NSData *data = [[NSData alloc] initWithBase64EncodedString:pwd options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [self internalAesDecrypt:data iv:IV];
}

- (NSString *)internalAesDecrypt:(NSData *)payload iv:(int[])iv {
    const size_t payload_length = payload.length;

    // See the doc: For block ciphers, the output size will always be less than or
    // equal to the input size plus the size of one block.
    // That's why we need to add the size of one block here
    const size_t buffer_size = payload_length + kCCBlockSizeAES128;
    unsigned int buffer_out[buffer_size];

    const CCOptions options = 0;  // defaults to CBC without padding
    const unsigned int key[] = {0x6e, 0xcc, 0x94, 0xed, 0x6a, 0x90, 1, 0x3d, 0x30, 0xaf, 0x52, 0xd, 0x18, 0x77, 0x44, 0x2f};

    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, options, key, kCCKeySizeAES128, iv, payload.bytes, payload_length, buffer_out, buffer_size, &numBytesDecrypted);

    NSString *resultString;
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer_out length:numBytesDecrypted];
        resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    return resultString;
}

- (void)updateWirelessSummaryWithSettings:(NSArray*)wirelessSettings {
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
