//
//  SFIReachabilityManager.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIReachabilityManager.h"
#import "Reachability.h"
#import "AlmondPlusSDKConstants.h"


NSString *const kSFIReachabilityChangedNotification = @"kReachabilityChangedNotification"; // clone the constant from Reachability.h

@interface SFIReachabilityManager ()
@property(strong, nonatomic, readonly) Reachability *reachability;
@end

@implementation SFIReachabilityManager

#pragma mark -
#pragma mark Initialization

- (instancetype)initWithHost:(NSString*)host {
    self = [super init];
    if (self) {
        host = @"www.google.com";
        _reachability = [Reachability reachabilityWithHostname:host];

        // Start Monitoring
        [self.reachability startNotifier];
    }
    return self;
}

- (void)dealloc {
    [self shutdown];
}

#pragma mark -
#pragma mark Public methods

- (void)shutdown {
    // Stop Notifier
    if (_reachability) {
        [_reachability stopNotifier];
        _reachability = nil;
    }
}

- (BOOL)isReachable {
   
    return self.reachability.isReachable;
}

- (BOOL)isUnreachable {
    return !self.reachability.isReachable;
}

- (BOOL)isReachableViaWWAN {
    return self.reachability.isReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.reachability.isReachableViaWiFi;
}

@end
