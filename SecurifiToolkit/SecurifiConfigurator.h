//
//  SecurifiConfigurator.h
//  SecurifiToolkit
//
//  Created by Matthew Sinclair-Day on 11/26/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
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

@property(nonatomic) NSUInteger cloudPort;

// defaults to NO; when YES, the remote SSL certificate is validated against one stored in the app's bundle
@property(nonatomic) BOOL enableCertificateValidation;

// controls whether the remote SSL cert is validated against its signing chain.
// defaults to YES; should only be set to NO for internal testing when using self-signed certs
// when NO, security is greatly compromised and open to man-in-the-middle attacks.
@property(nonatomic) BOOL enableCertificateChainValidation;

// Name of the certificate file containing the cert that will be compared with the remote SSL cert, when
// enableCertificateValidation is YES
@property(nonatomic, copy) NSString *certificateFileName;

// Controls whether the app is configured for push and cloud notifications. Default is NO.
// When YES, APN registration and UI support is activated, and the toolkit will process on-demand and dynamic
// updates to fetch notification logs
@property(nonatomic) BOOL enableNotifications;

// Controls whether the app allows the user to set Home or Away mode
@property(nonatomic) BOOL enableNotificationsHomeAwayMode;

// Controls the notification text is adorned with debug information in the UI
@property(nonatomic) BOOL enableNotificationsDebugMode;

@property(nonatomic) BOOL enableNotificationsDebugLogging;

// Controls whether the app allows the user to enable/disable a SSID on the router tab
@property(nonatomic) BOOL enableRouterWirelessControl;

// Controls whether the app allows for local LAN connections to an Almond; when NO, all connections are routed
// through the Securifi cloud.
// Defaults to NO
@property(nonatomic) BOOL enableLocalNetworking;

// Controls whether the app shows the Scenes tab and functions
@property(nonatomic) BOOL enableScenes;

// Controls whether the app uses the new WifiClients UI; when NO, then the legacy UI is used.
@property(nonatomic) BOOL enableWifiClients;

- (id)copyWithZone:(NSZone *)zone;

@end
