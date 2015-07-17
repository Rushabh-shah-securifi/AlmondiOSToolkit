//
// Created by Matthew Sinclair-Day on 6/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// Represents the settings used for connecting directly to an Almond over a web socket
@interface SFIAlmondLocalNetworkSettings : NSObject <NSCopying, NSCoding>

// indicates whether this local connection setting should be used or not
// used as a master switch for toggling between Cloud and Local mode; that is, when disabled, the Cloud mode is indicated.
@property(nonatomic) BOOL enabled;

// name for SSID 2.5ghz
@property(nonatomic, copy) NSString *ssid2;

// name for SSID 5ghz
@property(nonatomic, copy) NSString *ssid5;

// almond MAC id
@property(nonatomic, copy) NSString *almondplusMAC;

// IP address for almond
@property(nonatomic, copy) NSString *host;

// optional; port to connect on
@property(nonatomic) NSUInteger port;

// optional; login name
@property(nonatomic, copy) NSString *login;

// password for login
@property(nonatomic, copy) NSString *password;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (id)copyWithZone:(NSZone *)zone;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToSettings:(SFIAlmondLocalNetworkSettings *)settings;

- (NSUInteger)hash;

@end