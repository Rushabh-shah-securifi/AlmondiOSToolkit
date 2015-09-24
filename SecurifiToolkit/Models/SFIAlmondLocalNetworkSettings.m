//
// Created by Matthew Sinclair-Day on 6/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIAlmondLocalNetworkSettings.h"
#import "WebSocketEndpoint.h"
#import "NetworkConfig.h"
#import "GenericCommand.h"
#import "SFIAlmondPlus.h"
#import "KeyChainWrapper.h"

#define SEC_PASSWORD @"password"

@interface SFIAlmondLocalNetworkSettings () <NetworkEndpointDelegate>
@property(nonatomic, readonly) dispatch_semaphore_t test_connection_latch;
@property(nonatomic, readonly) dispatch_semaphore_t test_command_latch;
@property(nonatomic) enum TestConnectionResult testResult;
@end

@implementation SFIAlmondLocalNetworkSettings

- (instancetype)init {
    self = [super init];
    if (self) {
        self.almondplusName = @"Unknown"; // name is not provided in the summary (why not!!!) so we make sure it is not null, but expect it to be properly set
        self.port = 7681; // default web socket port
    }

    return self;
}

- (enum TestConnectionResult)testConnection {
    NSString *mac = @"test_almond";

    NetworkConfig *config = [NetworkConfig webSocketConfig:mac];
    config.host = self.host;
    config.port = self.port;
    config.password = self.password;

    self.testResult = TestConnectionResult_unknown;
    _test_connection_latch = dispatch_semaphore_create(0);

    WebSocketEndpoint *endpoint = [WebSocketEndpoint endpointWithConfig:config];
    endpoint.delegate = self;

    [endpoint connect];
    [self waitOnLatch:self.test_connection_latch timeout:3 logMsg:@"Failed to connect to web socket"];

    BOOL success = (self.testResult == TestConnectionResult_success);
    if (success) {
        self.testResult = TestConnectionResult_unknown;
        _test_command_latch = dispatch_semaphore_create(0);

        NSTimeInterval cid = [NSDate date].timeIntervalSince1970;
        NSDictionary *payload = @{
                @"MobileInternalIndex" : @(cid),
                @"CommandType" : @"GetAlmondNameAndMAC",
        };

        GenericCommand *cmd = [GenericCommand jsonPayloadCommand:payload commandType:CommandType_ALMOND_NAME_AND_MAC_REQUEST];
        NSError *error = nil;
        if ([endpoint sendCommand:cmd error:&error]) {
            [self waitOnLatch:self.test_command_latch timeout:3 logMsg:@"Failed to send GetAlmondNameandMAC to web socket"];
        }
    }

    // clean up
    endpoint.delegate = nil;
    [endpoint shutdown];
    //
    _test_connection_latch = nil;
    _test_command_latch = nil;

    return self.testResult;
}

- (void)processTestConnectionResponsePayload:(NSDictionary *)payload {
    NSString *str = payload[@"Success"];

    BOOL success = [str isEqualToString:@"true"];
    self.testResult = success ? TestConnectionResult_success : TestConnectionResult_unknownError;

    if (!success) {
        return;
    }

    NSString *mac_hex = payload[@"MAC"];
    if (![self validMac:mac_hex]) {
        self.testResult = TestConnectionResult_macMissing;
        return;
    }

    NSString *mac = [SFIAlmondPlus convertMacHexToDecimal:mac_hex];

    if (self.almondplusMAC) {
        // if a MAC is specified then let's compare and make sure the almond to which we connected is the same one specified
        // in these settings.

        if (![self.almondplusMAC isEqualToString:mac]) {
            // not the same
            self.testResult = TestConnectionResult_macMismatch;
            return;
        }
    }

    // update the almond plus mac with this one
    self.almondplusMAC = mac;
    self.almondplusName = payload[@"Name"];
}

- (SFIAlmondPlus *)asLocalLinkAlmondPlus {
    SFIAlmondPlus *plus = SFIAlmondPlus.new;
    plus.almondplusName = self.almondplusName;
    plus.almondplusMAC = self.almondplusMAC;
    plus.linkType = SFIAlmondPlusLinkType_local_only;
    return plus;
}


#pragma mark - NetworkEndpointDelegate methods

- (void)networkEndpointWillStartConnecting:(id <NetworkEndpoint>)endpoint {

}

- (void)networkEndpointDidConnect:(id <NetworkEndpoint>)endpoint {
    dispatch_semaphore_t latch = self.test_connection_latch;
    if (latch) {
        self.testResult = TestConnectionResult_success;
        dispatch_semaphore_signal(latch);
    }
}

- (void)networkEndpointDidDisconnect:(id <NetworkEndpoint>)endpoint {

}

- (void)networkEndpoint:(id <NetworkEndpoint>)endpoint dispatchResponse:(id)payload commandType:(enum CommandType)commandType {
    if (commandType == CommandType_ALMOND_NAME_AND_MAC_RESPONSE) {
        dispatch_semaphore_t latch = self.test_command_latch;
        [self processTestConnectionResponsePayload:payload];
        dispatch_semaphore_signal(latch);
    }
}

// Waits up to the specified number of seconds for the semaphore to be signalled.
// Returns YES on timeout waiting on the latch.
// Returns NO when the signal has been received before the timeout.
- (BOOL)waitOnLatch:(dispatch_semaphore_t)latch timeout:(int)numSecsToWait logMsg:(NSString *)msg {
    dispatch_time_t max_time = dispatch_time(DISPATCH_TIME_NOW, numSecsToWait * NSEC_PER_SEC);

    BOOL timedOut;

    dispatch_time_t blockingSleepSecondsIfNotDone;
    do {
        const int waitMs = 5;
        blockingSleepSecondsIfNotDone = dispatch_time(DISPATCH_TIME_NOW, waitMs * NSEC_PER_MSEC);

        timedOut = blockingSleepSecondsIfNotDone > max_time;
        if (timedOut) {
            NSLog(@"%@. Timeout reached.", msg);
            break;
        }
    }
    while (0 != dispatch_semaphore_wait(latch, blockingSleepSecondsIfNotDone));

    // make sure...
    dispatch_semaphore_signal(latch);

    return timedOut;
}

- (BOOL)hasBasicCompleteSettings {
    return self.host.length > 0 &&
            self.port > 0 &&
            self.login.length > 0 &&
            self.password.length > 0;
}

- (BOOL)hasCompleteSettings {
    return self.almondplusName.length > 0 &&
            [self validMac:self.almondplusMAC] &&
            self.hasBasicCompleteSettings;
}

- (BOOL)validMac:(NSString *)mac {
    return mac.length > 0 && ![mac isEqualToString:@"<no_mac>"];
}

- (void)purgePassword {
    NSString *serviceName = [self makeKeychainServiceName];
    [KeyChainWrapper removeEntryForUserEmail:SEC_PASSWORD forService:serviceName];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.enabled = [coder decodeBoolForKey:@"self.enabled"];
        self.almondplusName = [coder decodeObjectForKey:@"self.almondplusName"];
        self.almondplusMAC = [coder decodeObjectForKey:@"self.almondplusMAC"];
        self.host = [coder decodeObjectForKey:@"self.host"];
        self.port = (NSUInteger) [coder decodeInt64ForKey:@"self.port"];
        self.login = [coder decodeObjectForKey:@"self.login"];

        NSString *serviceName = [self makeKeychainServiceName];
        self.password = [KeyChainWrapper retrieveEntryForUser:SEC_PASSWORD forService:serviceName];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt32:1 forKey:@"self.schemaVersion"]; // for future use/expansion; version this schema

    [coder encodeBool:self.enabled forKey:@"self.enabled"];
    [coder encodeObject:self.almondplusName forKey:@"self.almondplusName"];
    [coder encodeObject:self.almondplusMAC forKey:@"self.almondplusMAC"];
    [coder encodeObject:self.host forKey:@"self.host"];
    [coder encodeInt64:self.port forKey:@"self.port"];
    [coder encodeObject:self.login forKey:@"self.login"];

    NSString *password = self.password;
    if (password.length > 0) {
        NSString *serviceName = [self makeKeychainServiceName];
        [KeyChainWrapper createEntryForUser:SEC_PASSWORD entryValue:password forService:serviceName];
    }
}

- (NSString *)makeKeychainServiceName {
    NSString *mac = self.almondplusMAC;

    if (mac.length == 0) {
        NSLog(@"makeKeychainServiceName: local settings mac is nil");
    }

    return [NSString stringWithFormat:@"almond_local_settings:%@", mac];
}

- (id)copyWithZone:(NSZone *)zone {
    SFIAlmondLocalNetworkSettings *copy = (SFIAlmondLocalNetworkSettings *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.enabled = self.enabled;
        copy.almondplusName = self.almondplusName;
        copy.almondplusMAC = self.almondplusMAC;
        copy.host = self.host;
        copy.port = self.port;
        copy.login = self.login;
        copy.password = self.password;
    }

    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToSettings:other];
}

- (BOOL)isEqualToSettings:(SFIAlmondLocalNetworkSettings *)settings {
    if (self == settings)
        return YES;
    if (settings == nil)
        return NO;
    if (self.enabled != settings.enabled)
        return NO;
    if (self.almondplusName != settings.almondplusName && ![self.almondplusName isEqualToString:settings.almondplusName])
        return NO;
    if (self.almondplusMAC != settings.almondplusMAC && ![self.almondplusMAC isEqualToString:settings.almondplusMAC])
        return NO;
    if (self.host != settings.host && ![self.host isEqualToString:settings.host])
        return NO;
    if (self.port != settings.port)
        return NO;
    if (self.login != settings.login && ![self.login isEqualToString:settings.login])
        return NO;
    if (self.password != settings.password && ![self.password isEqualToString:settings.password])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = (NSUInteger) self.enabled;
    hash = hash * 31u + [self.almondplusName hash];
    hash = hash * 31u + [self.almondplusMAC hash];
    hash = hash * 31u + [self.host hash];
    hash = hash * 31u + self.port;
    hash = hash * 31u + [self.login hash];
    hash = hash * 31u + [self.password hash];
    return hash;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.enabled=%d", self.enabled];
    [description appendFormat:@", self.almondplusName=%@", self.almondplusName];
    [description appendFormat:@", self.almondplusMAC=%@", self.almondplusMAC];
    [description appendFormat:@", self.host=%@", self.host];
    [description appendFormat:@", self.port=%lu", (unsigned long) self.port];
    [description appendFormat:@", self.login=%@", self.login];
    [description appendFormat:@", self.password=%@", self.password];
    [description appendString:@">"];
    return description;
}


@end