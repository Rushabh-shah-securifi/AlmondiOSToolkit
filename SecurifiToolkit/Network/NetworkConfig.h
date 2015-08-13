//
// Created by Matthew Sinclair-Day on 6/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SecurifiConfigurator;
@class SFIAlmondPlus;

typedef NS_ENUM(NSUInteger, NetworkEndpointMode) {
    NetworkEndpointMode_cloud,
    NetworkEndpointMode_web_socket,
};

// Represents the configuration for a Network endpoint
@interface NetworkConfig : NSObject <NSCopying>

// Factory for making a Network configuration based on the main configurator settings
+ (instancetype)cloudConfig:(SecurifiConfigurator *)configurator useProductionHost:(BOOL)useProductionHost;

// Factory for making a Network configuration for connecting to the web socket server on an Almond
+ (instancetype)webSocketConfig:(NSString *)almondMac;

- (id)copyWithZone:(NSZone *)zone;

// Indicates whether the config is for a Cloud connection or web socket connection
@property(readonly) enum NetworkEndpointMode mode;

// Optional value: used for web socket mode to inform the socket/callbacks about the Almond
@property(nonatomic, copy) NSString *almondMac;

// IP address or hostname of the endpoint
@property(nonatomic, copy) NSString *host;

// TCP port
@property(nonatomic) NSUInteger port;

// Password used for authenticating with the web socket connection
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