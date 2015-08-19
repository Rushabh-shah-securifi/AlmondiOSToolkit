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

//    NSLog(@"payload: %@", pwd);
//    NSLog(@"mac: %@", almondMac);
//    NSLog(@"uptime: %@", self.uptime);
//    NSLog(@"iv: %@", [self toHexString:IV length:kCCBlockSizeAES128]);

//    NSData *payload = [self testData];
//    NSData *encrypted = [self internalAesOp:kCCEncrypt payload:payload iv:IV];
//    NSData *decrypted = [self internalAesOp:kCCDecrypt payload:encrypted iv:IV];

    // Base64 decode the password
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
    return data;
}

- (NSString *)toHexString:(int[])val length:(int)length {
    NSString *out = @"";
    for (int i = 0; i < length; i++) {
        out = [out stringByAppendingFormat:@"%x", val[i]];
    }
    return out;
}

- (NSData *)testData {
    unichar plainText[kCCBlockSizeAES128];
    bzero(plainText, kCCBlockSizeAES128);

    plainText[0] = [@"g" characterAtIndex:0];
    plainText[1] = [@"g" characterAtIndex:0];
    plainText[2] = [@"g" characterAtIndex:0];
    plainText[3] = [@"g" characterAtIndex:0];
    plainText[4] = [@"g" characterAtIndex:0];

    NSData *payload = [NSData dataWithBytes:plainText length:kCCBlockSizeAES128];
    return payload;
}

@end
