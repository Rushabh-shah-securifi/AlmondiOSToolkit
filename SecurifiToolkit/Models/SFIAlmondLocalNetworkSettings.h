//
// Created by Matthew Sinclair-Day on 6/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFIAlmondPlus;

typedef NS_ENUM(unsigned int, TestConnectionResult) {
    TestConnectionResult_unknown,           // result is not obtained
    TestConnectionResult_success,           // all is good
    TestConnectionResult_macMismatch,       // the mac specified in the settings do not match the mac on the remote host
    TestConnectionResult_unknownError,      // some error here or there prevented the test from completing
};


// Represents the settings used for connecting directly to an Almond over a web socket.
// The settings can also be converted into SFIAlmondPlus for presentation in the UI and management in the toolkit.
//
// Note method testConnection. It will attempt to connect to the specified host and interrogate it for the Almond's
// MAC address and name. This is considered and essential and required step when filling out the settings. If the
// test should not succeed, the settings should not be saved.
//
// Note when encoding/persisting a settings, the password property is persisted in the system's keychain and is not
// encoded in the archive.
@interface SFIAlmondLocalNetworkSettings : NSObject <NSCopying, NSCoding>

// indicates whether this local connection setting should be used or not
// used as a master switch for toggling between Cloud and Local mode; that is, when disabled, the Cloud mode is indicated.
@property(nonatomic) BOOL enabled;

// name for SSID 2.5ghz
@property(nonatomic, copy) NSString *ssid2;

// name for SSID 5ghz
@property(nonatomic, copy) NSString *ssid5;

// almond MAC id
@property(nonatomic, copy) NSString *almondplusName; // null unless testConnection succeeds;

// almond MAC id
@property(nonatomic, copy) NSString *almondplusMAC; // null unless testConnection succeeds; mac decimal value

// IP address for almond
@property(nonatomic, copy) NSString *host;

// optional; port to connect on
@property(nonatomic) NSUInteger port;

// optional; login name
@property(nonatomic, copy) NSString *login;

// password for login
@property(nonatomic, copy) NSString *password;

- (enum TestConnectionResult)testConnection;

// makes an SFIAlmondPlus representation
- (SFIAlmondPlus *)asAlmondPlus;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (id)copyWithZone:(NSZone *)zone;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToSettings:(SFIAlmondLocalNetworkSettings *)settings;

- (NSUInteger)hash;

- (NSString *)description;

@end