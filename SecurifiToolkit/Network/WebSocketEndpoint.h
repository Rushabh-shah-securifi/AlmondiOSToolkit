//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkEndpoint.h"

@protocol NetworkEndpointDelegate;
@class NetworkConfig;

@interface WebSocketEndpoint : NSObject <NetworkEndpoint>

@property(nonatomic, weak) id <NetworkEndpointDelegate> delegate;

+ (instancetype)endpointWithConfig:(NetworkConfig *)config;

@end
