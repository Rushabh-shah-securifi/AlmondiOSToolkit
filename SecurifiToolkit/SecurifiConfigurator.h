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

@property(nonatomic, copy) NSString *productionCloudHost;
@property(nonatomic, copy) NSString *developmentCloudHost;
@property(nonatomic) UInt32 cloudPort;
@property(nonatomic) BOOL enableCertificateValidation;
@property(nonatomic, copy) NSString *certificateFileName;

- (id)copyWithZone:(NSZone *)zone;

@end
