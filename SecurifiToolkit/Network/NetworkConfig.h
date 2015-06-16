//
// Created by Matthew Sinclair-Day on 6/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SecurifiConfigurator;

typedef NS_ENUM(NSUInteger, NetworkEndpointMode) {
    NetworkEndpointMode_cloud,
    NetworkEndpointMode_web_socket,
};

@interface NetworkConfig : NSObject

+ (instancetype)cloudConfig:(SecurifiConfigurator *)configurator useProductionHost:(BOOL)useProductionHost;

+ (instancetype)configWithMode:(enum NetworkEndpointMode)mode;

@property(readonly) enum NetworkEndpointMode mode;

@property(nonatomic, copy) NSString *host;

@property(nonatomic) UInt32 port;

@property(nonatomic, copy) NSString *password;

// defaults to NO; when YES, the remote SSL certificate is validated against one stored in the app's bundle
@property(nonatomic) BOOL enableCertificateValidation;

// controls whether the remote SSL cert is validated against its signing chain.
// defaults to YES; should only be set to NO for internal testing when using self-signed certs
// when NO, security is greatly compromised and open to man-in-the-middle attacks.
@property(nonatomic) BOOL enableCertificateChainValidation;

// Name of the certificate file containing the cert that will be compared with the remote SSL cert, when
// enableCertificateValidation is YES
@property(nonatomic, copy) NSString *certificateFileName;

@end