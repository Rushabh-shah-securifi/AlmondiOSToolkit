#import <Foundation/Foundation.h>
#import "ConnectionStatus.h"
#import "AlmondplusSDKConstants.h"

@implementation ConnectionStatus
static ConnectionStatusType status = (ConnectionStatusType)NO_NETWORK_CONNECTION;

+(ConnectionStatusType) getConnectionStatus{
    return status;
}

+(void) setConnectionStatusTo:(ConnectionStatusType)statusValue{
    @synchronized(self)
    {
        //TODO: should handle the toggle synchronization issue.
        [self networkNotifier:statusValue];
    }
}

+(void) networkNotifier: (ConnectionStatusType)statusValue {
    if(status==statusValue)
        return;
    
    status = statusValue;
    NSLog(@"connection status is set to %d",statusValue);
    NSNumber *statusNSNumber = [NSNumber numberWithInt:status];
    [[NSNotificationCenter defaultCenter] postNotificationName:CONNECTION_STATUS_CHANGE_NOTIFIER object:statusNSNumber userInfo:nil];
}

+(BOOL)isStreamConnected{
    return (status==(ConnectionStatusType)CONNECTED_TO_NETWORK);
}

+ (BOOL)isCloudLoggedIn {
    return ([ConnectionStatus getConnectionStatus] == (ConnectionStatusType*)AUTHENTICATED);
}
@end
