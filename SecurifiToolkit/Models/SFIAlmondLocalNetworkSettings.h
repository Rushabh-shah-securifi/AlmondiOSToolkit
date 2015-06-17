//
// Created by Matthew Sinclair-Day on 6/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// Represents the connection settings used for connecting directly to an Almond on the local LAN.
@interface SFIAlmondLocalNetworkSettings : NSObject <NSCopying, NSCoding>

@property(nonatomic) BOOL enabled;

@property(nonatomic, copy) NSString *almondplusMAC;

@property(nonatomic, copy) NSString *host;

@property(nonatomic) NSUInteger port;

@property(nonatomic, copy) NSString *password;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (id)copyWithZone:(NSZone *)zone;

@end