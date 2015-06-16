//
// Created by Matthew Sinclair-Day on 6/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NetworkConfig.h"
#import "SecurifiConfigurator.h"


@implementation NetworkConfig

+ (instancetype)cloudConfig:(SecurifiConfigurator *)configurator useProductionHost:(BOOL)useProductionHost {
    NetworkConfig *config = [NetworkConfig new];
    config.certificateFileName = configurator.certificateFileName.copy;
    config.enableCertificateChainValidation = configurator.enableCertificateChainValidation;
    config.enableCertificateValidation = configurator.enableCertificateValidation;
    config.host = useProductionHost ? configurator.productionCloudHost : configurator.developmentCloudHost;
    config.port = configurator.cloudPort;
    return config;
}

@end