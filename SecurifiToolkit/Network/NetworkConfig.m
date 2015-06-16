//
// Created by Matthew Sinclair-Day on 6/16/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import "NetworkConfig.h"
#import "SecurifiConfigurator.h"


@implementation NetworkConfig

- (void)copyFrom:(SecurifiConfigurator *)configurator {
    self.certificateFileName = configurator.certificateFileName.copy;
    self.enableCertificateChainValidation = configurator.enableCertificateChainValidation;
    self.enableCertificateValidation = configurator.enableCertificateValidation;
}

@end