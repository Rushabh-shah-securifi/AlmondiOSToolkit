#ifndef ConnectionStatus_h
#define ConnectionStatus_h


#endif /* ConnectionStatus_h */

#import <SystemConfiguration/SCNetworkReachability.h>


typedef NS_ENUM(NSInteger, ConnectionStatusType){
    NO_NETWORK_CONNECTION,
    IS_CONNECTING_TO_NETWORK,
    CONNECTED_TO_NETWORK,
    AUTHENTICATED,
    DISCONNECTING_NETWORK,
};

@interface ConnectionStatus : NSObject

+(ConnectionStatusType) getConnectionStatus;

+(bool)isNetworkAvailable;

+(void) setConnectionStatusTo: (ConnectionStatusType)statusValue;

+(BOOL) isStreamConnected;

+ (BOOL)isCloudLoggedIn;

@end
