//
//  SecurifiConfigurator.h
//  SecurifiToolkit
//
//  Created by Matthew Sinclair-Day on 11/26/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

// Specifies a configuration for the SecurifiToolkit
@interface SecurifiConfigurator : NSObject <NSCopying>

// When YES the Scorecard will collect events for reporting and tracking commands, responses,
// dynamic updates, and other significant actions taken in the toolkit. The events can be retrieved
// from the Scorecard. This is a debug facility and should not be run in production due to potential
// performance and memory costs.
// When YES it is assumed the UI will show the debug Scoreboard view controller.
@property(nonatomic) BOOL enableScoreboard;

@property(nonatomic, copy) NSString *productionCloudHost;
@property(nonatomic, copy) NSString *developmentCloudHost;
@property(nonatomic) UInt32 cloudPort;
@property(nonatomic) BOOL enableCertificateValidation;
@property(nonatomic, copy) NSString *certificateFileName;

// Controls whether the app is configured for push and cloud notifications. Default is NO.
@property(nonatomic) BOOL enableNotifications;

@property(nonatomic) BOOL enableNotificationsDebugLogging;

// Controls whether the app allows the user to enable/disable a SSID on the router tab
@property(nonatomic) BOOL enableRouterWirelessControl;

- (id)copyWithZone:(NSZone *)zone;

@end
