//
//  dummyCloudEndpoint.m
//  SecurifiToolkit
//
//  Created by Masood on 10/08/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "dummyCloudEndpoint.h"


@interface dummyCloudEndpoint () <NSStreamDelegate>
@property(nonatomic, readonly) NSObject *syncLocker;
@property(nonatomic, readonly) NetworkConfig *networkConfig;

@property(nonatomic) SecCertificateRef certificate;
@property(nonatomic) BOOL certificateTrusted;

@property(nonatomic, readonly) NSMutableData *partialData;
@property(nonatomic) BOOL networkUpNoticePosted;

@property(nonatomic, readonly) dispatch_queue_t backgroundQueue;        // queue on which the streams are managed
@property(nonatomic) NSInputStream *inputStream;
@property(nonatomic) NSOutputStream *outputStream;

@property(nonatomic, readonly) int connectionState;

@end
	

@implementation dummyCloudEndpoint

// dummy implementation start

+ (instancetype)endpointWithConfig:(NetworkConfig *)config {
//    return [[self alloc] initWithConfig:config];
    return NULL;
}

- (instancetype)initWithConfig:(NetworkConfig *)config {
    self = [super init];
    if (self) {
        _networkConfig = config;
        
        [self markConnectionState:1];
        
        _syncLocker = [NSObject new];
        _backgroundQueue = dispatch_queue_create("socket_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void)markConnectionState:(int)status {
    _connectionState = status;
    
    switch (status) {
        case 1:
            NSLog(@"Connection State: uninitialized");
            break;
//        case CloudEndpointConnectionStatus_connecting:
//            NSLog(@"Connection State: connecting");
//            break;
//        case CloudEndpointConnectionStatus_established:
//            NSLog(@"Connection State: established");
//            break;
//        case CloudEndpointConnectionStatus_failed:
//            NSLog(@"Connection State: failed");
//            break;
//        case CloudEndpointConnectionStatus_shutting_down:
//            NSLog(@"Connection State: shutting_down");
//            break;
//        case CloudEndpointConnectionStatus_shutdown:
//            NSLog(@"Connection State: shutdown");
//            break;
    }
    
}


- (void)shutdown {
//    [self.socket close];
}

- (void)connect {
    
}

-(BOOL) sendCommand: (GenericCommand *) obj error:(NSError **) outError {
    
    return YES;
}

// dummy implementation end

- (void) callDummyCloud:(id)payload commandType:(enum CommandType)commandType{
    
    NSLog(@" inside dummy cloud end point - delegation ");
    [self.delegate networkEndpoint:self dispatchResponse:payload commandType:(CommandType) commandType];
    return;

}



@end
