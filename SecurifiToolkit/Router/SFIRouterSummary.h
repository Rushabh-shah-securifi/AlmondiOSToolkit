//
//  SFIRouterSummary.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIRouterSummary : NSObject

@property(nonatomic) int wirelessSettingsCount;
@property(nonatomic) NSArray *wirelessSummaries; // SFIWirelessSummary
@property(nonatomic) int connectedDeviceCount;
@property(nonatomic) int blockedMACCount;
@property(nonatomic) int blockedContentCount;
@property(nonatomic) NSString *routerUptime;
@property(nonatomic) NSString *uptime;
@property(nonatomic) NSString *firmwareVersion;
@property(nonatomic) NSString *url;
@property(nonatomic) NSString *login;
@property(nonatomic) NSString *password;
@property(nonatomic) NSArray *almondsList;
@property (nonatomic) NSString *routerMode;
@property (nonatomic) NSString *location;
@property (nonatomic) NSInteger maxHopCount;

// passwords sent in summary information are encrypted
- (NSString *)decryptPassword:(NSString *)almondMac;

- (void)updateWirelessSummaryWithSettings:(NSArray *)wirelessSettings;

- (BOOL)hasSameAlmondLocation:(NSString *)location;
@end
