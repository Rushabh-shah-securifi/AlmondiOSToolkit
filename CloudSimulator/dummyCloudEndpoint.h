#import <Foundation/Foundation.h>
#import "NetworkEndpoint.h"

@class SecurifiConfigurator;
@class NetworkConfig;


@interface dummyCloudEndpoint : NSObject <NetworkEndpoint>

@property(nonatomic, weak) id <NetworkEndpointDelegate> delegate;

+ (instancetype)endpointWithConfig:(NetworkConfig *)config;

- (void) callDummyCloud:(id)payload commandType:(enum CommandType)commandType;


@end
