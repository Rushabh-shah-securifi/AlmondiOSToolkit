//
//  SecurifiConfigurator.m
//  SecurifiToolkit
//
//  Created by Matthew Sinclair-Day on 11/26/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "SecurifiConfigurator.h"

#define CLOUD_PROD_SERVER   @"cloud.securifi.com"
#define CLOUD_DEV_SERVER    @"clouddev.securifi.com"
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
        self.certificateFileName = CLOUD_CERT_FILENAME; // file must be named "cert.der". But leave off the file extension in the config.
        self.enableNotifications = NO;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SecurifiConfigurator *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.enableScoreboard = self.enableScoreboard;
        copy.productionCloudHost = self.productionCloudHost;
        copy.developmentCloudHost = self.developmentCloudHost;
        copy.cloudPort = self.cloudPort;
        copy.enableCertificateValidation = self.enableCertificateValidation;
        copy.certificateFileName = self.certificateFileName;
        copy.enableNotifications = self.enableNotifications;
    }

    return copy;
}

@end
