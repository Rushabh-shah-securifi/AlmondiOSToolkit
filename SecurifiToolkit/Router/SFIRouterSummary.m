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

- (NSString *)decryptPassword:(NSString *)almondMac {
    NSString *pwd = self.password;
    if (!pwd) {
        return nil;
    }

    // Compute the IV
    const char *MAC = [almondMac cStringUsingEncoding:NSUTF8StringEncoding];
    const char *UPTIME = [self.uptime cStringUsingEncoding:NSUTF8StringEncoding];;

    char IV[kCCBlockSizeAES128 + 1];
    bzero(IV, sizeof(IV));

    for (int i = 0; i < kCCBlockSizeAES128; i++) {
        IV[i] = (char) ((MAC[i] + UPTIME[i]) % 94 + 33);
    }

    // Base64 decode the password and then decrypt
    NSData *payload = [[NSData alloc] initWithBase64EncodedString:pwd options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decrypted = [self internalAesOp:kCCDecrypt payload:payload iv:IV];

    NSString *decrypted_str = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    return [decrypted_str copy];
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

- (NSData *)internalAesOp:(CCOperation)op payload:(NSData *)payload iv:(char[])iv {
    const size_t payload_length = payload.length;

    // See the doc: For block ciphers, the output size will always be less than or
    // equal to the input size plus the size of one block.
    // That's why we need to add the size of one block here
    unichar buffer_out[kCCBlockSizeAES128 + 1];
    const size_t buffer_size = sizeof(buffer_out);
    bzero(buffer_out, buffer_size);

    const CCOptions options = ccNoPadding;  // defaults to CBC without padding
    const char key[] = {0x6e, (char) 0xcc, (char) 0x94, (char) 0xed, 0x6a, (char) 0x90, 1, 0x3d, 0x30, (char) 0xaf, 0x52, 0xd, 0x18, 0x77, 0x44, 0x2f};

    size_t numBytesProcessed = 0;
    CCCryptorStatus cryptStatus = CCCrypt(op, kCCAlgorithmAES128, options, key, kCCKeySizeAES128, iv, payload.bytes, payload_length, buffer_out, buffer_size, &numBytesProcessed);
    if (cryptStatus != kCCSuccess) {
        return nil;
    }

    NSData *data = [NSData dataWithBytes:buffer_out length:numBytesProcessed];
    return [self trimToNull:data];
}

- (NSData *)trimToNull:(NSData *)payload {
    NSUInteger nullIndex = 0;
    for (nullIndex = 0; nullIndex < payload.length; nullIndex++) {
        unichar val;
        [payload getBytes:&val range:NSMakeRange(nullIndex, 1)];
        if (val == 0) {
            payload = [payload subdataWithRange:NSMakeRange(0, nullIndex)];
            break;
        }
    }
    return payload;
}

@end
