//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NetworkState.h"


@interface NetworkState ()
@property(nonatomic, readonly) NSObject *almondTableSyncLocker;
@property(nonatomic, readonly) NSMutableSet *hashCheckedForAlmondTable;
@property(nonatomic, readonly) NSMutableSet *deviceValuesCheckedForAlmondTable;

@property(nonatomic, readonly) NSObject *willFetchDeviceListFlagSyncLocker;
@property(nonatomic, readonly) NSMutableSet *willFetchDeviceListFlag;

@property(nonatomic, readonly) NSObject *almondModeSynLocker;
@property(nonatomic, readonly) NSMutableDictionary *almondModeTable;
@end

@implementation NetworkState

- (instancetype)init {
    self = [super init];
    if (self) {
        _almondTableSyncLocker = [NSObject new];
        _hashCheckedForAlmondTable = [NSMutableSet new];
        _deviceValuesCheckedForAlmondTable = [NSMutableSet new];

        _willFetchDeviceListFlagSyncLocker = [NSObject new];
        _willFetchDeviceListFlag = [NSMutableSet new];

        _almondModeSynLocker = [NSObject new];
        _almondModeTable = [NSMutableDictionary new];
    }

    return self;
}

#pragma mark - Hash value management

- (void)markHashFetchedForAlmond:(NSString *)aAlmondMac {
    @synchronized (self.almondTableSyncLocker) {
        [self.hashCheckedForAlmondTable addObject:aAlmondMac];
    }
}

- (BOOL)wasHashFetchedForAlmond:(NSString *)aAlmondMac {
    @synchronized (self.almondTableSyncLocker) {
        return [self.hashCheckedForAlmondTable containsObject:aAlmondMac];
    }
}

- (void)markWillFetchDeviceListForAlmond:(NSString *)aAlmondMac {
    if (aAlmondMac.length == 0) {
        return;
    }
    @synchronized (self.willFetchDeviceListFlagSyncLocker) {
        [self.willFetchDeviceListFlag addObject:aAlmondMac];
    }
}

- (BOOL)willFetchDeviceListFetchedForAlmond:(NSString *)aAlmondMac {
    if (aAlmondMac.length == 0) {
        return NO;
    }
    @synchronized (self.willFetchDeviceListFlagSyncLocker) {
        return [self.willFetchDeviceListFlag containsObject:aAlmondMac];
    }
}

- (void)clearWillFetchDeviceListForAlmond:(NSString *)aAlmondMac {
    if (aAlmondMac.length == 0) {
        return;
    }
    @synchronized (self.willFetchDeviceListFlagSyncLocker) {
        [self.willFetchDeviceListFlag removeObject:aAlmondMac];
    }
}

- (void)markDeviceValuesFetchedForAlmond:(NSString *)aAlmondMac {
    @synchronized (self.almondTableSyncLocker) {
        [self.deviceValuesCheckedForAlmondTable addObject:aAlmondMac];
    }
}

- (BOOL)wasDeviceValuesFetchedForAlmond:(NSString *)aAlmondMac {
    @synchronized (self.almondTableSyncLocker) {
        return [self.deviceValuesCheckedForAlmondTable containsObject:aAlmondMac];
    }
}

- (void)markModeForAlmond:(NSString *)aAlmondMac mode:(SFIAlmondMode)mode {
    if (aAlmondMac == nil) {
        return;
    }

    NSNumber *num = @(mode);
    @synchronized (self.almondModeSynLocker) {
        self.almondModeTable[aAlmondMac] = num;
    }
}

- (SFIAlmondMode)almondMode:(NSString *)aAlmondMac {
    if (aAlmondMac == nil) {
        return SFIAlmondMode_unknown;
    }

    @synchronized (self.almondModeSynLocker) {
        NSNumber *num = self.almondModeTable[aAlmondMac];

        if (num == nil) {
            return SFIAlmondMode_unknown;
        }

        return (SFIAlmondMode) [num unsignedIntValue];
    }
}

- (void)clearAlmondMode:(NSString *)aAlmondMac {
    if (aAlmondMac == nil) {
        return;
    }

    @synchronized (self.almondModeSynLocker) {
        [self.almondModeTable removeObjectForKey:aAlmondMac];
    }
}


@end