//
//  SecurifiConfigurator.m
//  SecurifiToolkit
//
//  Created by Matthew Sinclair-Day on 11/26/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SecurifiConfigurator.h"

#define CLOUD_PROD_SERVER   @"cloud.securifi.com"
#define CLOUD_DEV_SERVER    @"ec2-23-20-197-230.compute-1.amazonaws.com"
//#define CLOUD_DEV_SERVER    @"clouddev.securifi.com"
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
        self.enableCertificateChainValidation = YES;
        self.certificateFileName = CLOUD_CERT_FILENAME; // file must be named "cert.der". But leave off the file extension in the config.
        self.enableNotifications = NO;
        self.enableNotificationsHomeAwayMode = NO;
        self.enableNotificationsDebugLogging = NO;
        self.enableRouterWirelessControl = YES;
        self.enableLocalNetworking = NO;
        self.enableScenes = NO;
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
        copy.enableNotificationsDebugLogging = self.enableNotificationsDebugLogging;
        copy.enableRouterWirelessControl = self.enableRouterWirelessControl;
        copy.enableLocalNetworking = self.enableLocalNetworking;
        copy.enableScenes = self.enableScenes;
    }

    return copy;
}

@end
