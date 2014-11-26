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

@property(nonatomic) NSString *productionCloudHost;
@property(nonatomic) NSString *developmentCloudHost;
@property(nonatomic) UInt32 cloudPort;
@property(nonatomic) BOOL enableCertificateValidation;
@property(nonatomic) NSString  *certificateFileName;

//+ (SecurifiConfigurator *)load:(NSString *)fileName;
//- (BOOL)store:(NSString*)filePath;

- (id)copyWithZone:(NSZone *)zone;

@end
