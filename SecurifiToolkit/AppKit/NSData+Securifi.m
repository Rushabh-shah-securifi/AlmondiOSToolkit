//
// Created by Matthew Sinclair-Day on 8/20/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <CommonCrypto/CommonCryptoError.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+Securifi.h"


@implementation NSData (Securifi)

- (NSString *)securifiDecryptPasswordForAlmond:(NSString *)almondMac almondUptime:(NSString *)almondUptimeInt {
    if (!almondMac) {
        return nil;
    }
    if (!almondUptimeInt) {
        return nil;
    }
    
    // Compute the IV
    const char *MAC = [almondMac cStringUsingEncoding:NSUTF8StringEncoding];
    const char *UPTIME = [almondUptimeInt cStringUsingEncoding:NSUTF8StringEncoding];
    
    const size_t blockSize = kCCBlockSizeAES128;
    
    char IV[blockSize + 1];
    bzero(IV, sizeof(IV));
    
    for (int i = 0; i < blockSize; i++) {
        IV[i] = (char) ((MAC[i] + UPTIME[i]) % 94 + 33);
    }
    char KEY[] = {0x6e, (char) 0xcc, (char) 0x94, (char) 0xed, 0x6a, (char) 0x90, 1, 0x3d, 0x30, (char) 0xaf, 0x52, 0xd, 0x18, 0x77, 0x44, 0x2f};
    
    // Decrypt
    NSData *decrypted = [self securifiInternalAesOp:kCCDecrypt payload:self key:KEY iv:IV];
    // Convert back to string; we expect the plain text password to be UTF-8 encoded
    NSString *decrypted_str = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    return decrypted_str;
}

- (NSData *)securifiInternalAesOp:(const CCOperation)op payload:(const NSData *)payload key:(const char[])key iv:(const char[])iv {
    //quickfix:: could be wrong way of handling
    size_t pay_len = payload.length;
    if((payload.length % 16) != 0){
        pay_len = payload.length-1;
    }
    const size_t payload_length = pay_len;
    
    // See the doc: For block ciphers, the output size will always be less than or
    // equal to the input size plus the size of one block.
    // That's why we need to add the size of one block here
    unichar buffer_out[kCCBlockSizeAES128 + 1];
    const size_t buffer_size = sizeof(buffer_out);
    bzero(buffer_out, buffer_size);
    
    const CCOptions options = ccNoPadding;  // defaults to CBC without padding
    
    size_t numBytesProcessed = 0;
    CCCryptorStatus cryptStatus = CCCrypt(op, kCCAlgorithmAES128, options, key, kCCKeySizeAES128, iv, payload.bytes, payload_length, buffer_out, buffer_size, &numBytesProcessed);
    if (cryptStatus != kCCSuccess) {
        NSLog(@"CCCrypt Failed! - Status: %d", cryptStatus);
        return nil;
    }
    
    NSData *data = [NSData dataWithBytes:buffer_out length:numBytesProcessed];
    return [self securifiTrimToNull:data];
}

- (NSData *)securifiTrimToNull:(NSData *)payload {
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