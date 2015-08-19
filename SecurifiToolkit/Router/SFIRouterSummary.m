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
#import "Base64.h"

@implementation SFIRouterSummary


- (NSString *)decryptPassword:(NSString*)almondMac {
    NSString *pwd = self.password;
    if (!pwd) {
        return nil;
    }

    const char *MAC = [almondMac cStringUsingEncoding:NSUTF8StringEncoding];
    const char *UPTIME = [self.uptime cStringUsingEncoding:NSUTF8StringEncoding];;

    int IV[kCCBlockSizeAES128];
    bzero(IV, sizeof(IV));

    NSString *out = @"";

    int i;
    for (i = 0; i < kCCBlockSizeAES128; i++) {
        IV[i] = ((MAC[i] + UPTIME[i]) % 94 + 33);

        out = [out stringByAppendingFormat:@"%x", IV[i]];
    }

    NSLog(@"payload: %@", pwd);
    NSLog(@"mac: %@", almondMac);
    NSLog(@"uptime: %@", self.uptime);
    NSLog(@"iv: %@", out);

    NSData *data = [[NSData alloc] initWithBase64EncodedString:pwd options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [self internalSecurifiAesOperation:kCCDecrypt payload:data iv:IV];
}

- (NSString *)internalSecurifiAesOperation:(CCOperation)op payload:(NSData *)payload iv:(int[])ivPtr {
    const CCAlgorithm algorithm = kCCAlgorithmAES128;

    const size_t key_size = kCCKeySizeAES128;
    const unichar keyPtr[] = {0x6e, 0xcc, 0x94, 0xed, 0x6a, 0x90, 1, 0x3d, 0x30, 0xaf, 0x52, 0xd, 0x18, 0x77, 0x44, 0x2f};

    const size_t payload_length = payload.length;
    unichar payload_in[payload_length];
    bzero(payload_in, sizeof(payload_in));

    [payload getBytes:payload_in length:payload_length];

//    NSString *dataStr = [NSString stringWithCharacters:payload.bytes length:payload_length];
//    NSString *dataStr = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
//    [dataStr getCharacters:payload_in range:NSMakeRange(0, payload_length)];

    const size_t buffer_size = 100;
    unichar buffer_out[buffer_size];
    bzero(buffer_out, sizeof(buffer_out));

    size_t numBytesEncrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(op,
            algorithm,
            0, //kCCOptionPKCS7Padding,
            keyPtr,
            key_size,
            ivPtr /* initialization vector (optional) */,
            payload.bytes,
            payload_length, /* input */
            &buffer_out,
            buffer_size, /* output */
            &numBytesEncrypted);

    NSString *resultString;
    if (cryptStatus == kCCSuccess) {
        resultString = [[NSString alloc] initWithCharacters:buffer_out length:numBytesEncrypted];
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
