//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandTypes.h"

@class GenericCommand;
@protocol NetworkEndpoint;

@protocol NetworkEndpointDelegate

- (void)networkEndpointWillStartConnecting:(id <NetworkEndpoint>)endpoint;

- (void)networkEndpointDidConnect:(id <NetworkEndpoint>)endpoint;

- (void)networkEndpointDidDisconnect:(id <NetworkEndpoint>)endpoint;

- (void)networkEndpoint:(id <NetworkEndpoint>)endpoint dispatchResponse:(id)payload commandType:(enum CommandType)commandType;

@end


@protocol NetworkEndpoint <NSObject>

@property(nonatomic, weak) id <NetworkEndpointDelegate> delegate;

- (void)connect;
- (void)connectMesh;

- (void)shutdown;
- (void)shutdownMesh;
// Send the specified command to the cloud
// Returns YES on successful submission
// Returns NO on failure to send
- (BOOL)sendCommand:(GenericCommand *)command error:(NSError **)error;

@end
