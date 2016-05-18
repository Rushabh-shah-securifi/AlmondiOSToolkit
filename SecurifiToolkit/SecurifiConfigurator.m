//
//  SecurifiConfigurator.m
//  SecurifiToolkit
//
//  Created by Matthew Sinclair-Day on 11/26/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SecurifiConfigurator.h"

#define CLOUD_PROD_SERVER   @"54.226.113.110" //@"cloud.securifi.com"
//#define CLOUD_DEV_SERVER    @"ec2-54-226-113-110.compute-1.amazonaws.com"
#define CLOUD_DEV_SERVER    @"clouddev.securifi.com" //can you connect to the 54.226.113.110
#define CLOUD_SERVER_PORT   1028
#define CLOUD_CERT_FILENAME @"cert"

@implementation SecurifiConfigurator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.enableScoreboard = NO;
        self.productionCloudHost = CLOUD_PROD_SERVER;
        self.developmentCloudHost = CLOUD_DEV_SERVER;
        self.cloudPort = CLOUD_SERVER_PORT;
        self.enableCertificateValidation = NO;
        self.enableCertificateChainValidation = NO;
        self.certificateFileName = CLOUD_CERT_FILENAME; // file must be named "cert.der". But leave off the file extension in the config.
        self.enableNotifications = NO;
        self.enableNotificationsHomeAwayMode = NO;
        self.enableNotificationsDebugMode = NO;
        self.enableNotificationsDebugLogging = NO;
        self.enableRouterWirelessControl = YES;
        self.enableLocalNetworking = NO;
        self.enableScenes = NO;
        self.enableWifiClients = NO;
        self.enableAlmondVersionRemoteUpdate = NO;
        self.enableSensorTileDebugInfo = NO;
        self.isSimulator = NO;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SecurifiConfigurator *copy = (SecurifiConfigurator *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.enableScoreboard = self.enableScoreboard;
        copy.productionCloudHost = self.productionCloudHost;
        copy.developmentCloudHost = self.developmentCloudHost;
        copy.cloudPort = self.cloudPort;
        copy.enableCertificateValidation = self.enableCertificateValidation;
        copy.enableCertificateChainValidation = self.enableCertificateChainValidation;
        copy.certificateFileName = self.certificateFileName;
        copy.enableNotifications = self.enableNotifications;
        copy.enableNotificationsHomeAwayMode = self.enableNotificationsHomeAwayMode;
        copy.enableNotificationsDebugMode = self.enableNotificationsDebugMode;
        copy.enableNotificationsDebugLogging = self.enableNotificationsDebugLogging;
        copy.enableRouterWirelessControl = self.enableRouterWirelessControl;
        copy.enableLocalNetworking = self.enableLocalNetworking;
        copy.enableScenes = self.enableScenes;
        copy.enableWifiClients = self.enableWifiClients;
        copy.enableAlmondVersionRemoteUpdate = self.enableAlmondVersionRemoteUpdate;
        copy.enableSensorTileDebugInfo = self.enableSensorTileDebugInfo;
        copy.isSimulator = self.isSimulator;
    }

    return copy;
}

@end
