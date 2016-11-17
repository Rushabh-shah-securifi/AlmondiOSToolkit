//
// Created by Matthew Sinclair-Day on 8/20/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Securifi)

// Encapsulates the procedure for decrypting the Almond admin password that is sent in an AlmondRouterSummary response payload.
// Returns nil on failure to decrypt
- (NSString *)securifiDecryptPasswordForAlmond:(NSString *)almondMac almondUptime:(NSString *)almondUptimeInt;

@end