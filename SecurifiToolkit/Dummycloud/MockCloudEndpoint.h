//
//  MockCloudEndpoint.h
//  SecurifiApp
//
//  Created by Masood on 10/08/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GenericCommand;
@protocol MyNetworkEndpoint;

@protocol MyNetworkEndpointDelegate

//- (void)networkEndpointWillStartConnecting:(id <MyNetworkEndpoint>)endpoint;
//
//- (void)networkEndpointDidConnect:(id <MyNetworkEndpoint>)endpoint;
//
//- (void)networkEndpointDidDisconnect:(id <MyNetworkEndpoint>)endpoint;

- (void)networkEndpoint:(id <MyNetworkEndpoint>)endpoint dispatchResponse:(id)payload commandType:(enum CommandType)commandType;

@end

@protocol MyNetworkEndpoint <NSObject>

@property(nonatomic, weak) id <MyNetworkEndpointDelegate> delegate;

- (void)connect;

- (void)shutdown;

// Send the specified command to the cloud
// Returns YES on successful submission
// Returns NO on failure to send
- (BOOL)sendCommand:(GenericCommand *)command error:(NSError **)error;

@end


@interface MockCloudEndpoint : NSObject

@end
