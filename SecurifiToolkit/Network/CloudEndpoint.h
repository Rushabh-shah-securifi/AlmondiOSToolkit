//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkEndpoint.h"

@class SecurifiConfigurator;


@interface CloudEndpoint : NSObject <NetworkEndpoint>

@property(nonatomic, readonly) BOOL useProductionHost;
@property(nonatomic, weak) id <NetworkEndpointDelegate> delegate;

+ (instancetype)endpointWithConfig:(SecurifiConfigurator *)config useProductionHost:(BOOL)useProductionHost;

@end