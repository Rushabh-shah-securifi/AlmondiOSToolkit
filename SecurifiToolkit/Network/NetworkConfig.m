//
// Created by Matthew Sinclair-Day on 6/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NetworkConfig.h"
#import "SecurifiConfigurator.h"

@implementation NetworkConfig

+ (instancetype)cloudConfig:(SecurifiConfigurator *)configurator useProductionHost:(BOOL)useProductionHost {
    NetworkConfig *config = [NetworkConfig configWithMode:NetworkEndpointMode_cloud];
    config.certificateFileName = configurator.certificateFileName.copy;
    config.enableCertificateChainValidation = configurator.enableCertificateChainValidation;
    config.enableCertificateValidation = configurator.enableCertificateValidation;
    config.host = useProductionHost ? configurator.productionCloudHost : configurator.developmentCloudHost;
    config.port = configurator.cloudPort;
    return config;
}

+ (instancetype)webSocketConfig:(NSString *)almondMac {
    NetworkConfig *config = [NetworkConfig configWithMode:NetworkEndpointMode_web_socket];
    config.almondMac = almondMac;
    return config;
}

+ (instancetype)configWithMode:(enum NetworkEndpointMode)mode {
    return [[self alloc] initWithMode:mode];
}

- (instancetype)initWithMode:(enum NetworkEndpointMode)mode {
    self = [super init];
    if (self) {
        _mode = mode;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NetworkConfig *copy = (NetworkConfig *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy->_mode = _mode;
        copy.almondMac = self.almondMac;
        copy.host = self.host;
        copy.port = self.port;
        copy.login = self.login;
        copy.password = self.password;
        copy.enableCertificateValidation = self.enableCertificateValidation;
        copy.enableCertificateChainValidation = self.enableCertificateChainValidation;
        copy.certificateFileName = self.certificateFileName;
    }

    return copy;
}

@end