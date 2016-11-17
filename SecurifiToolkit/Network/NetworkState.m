//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NetworkState.h"
#import "GenericCommand.h"


@interface NetworkState ()
@property(nonatomic, readonly) NSObject *almondTableSyncLocker;
@property(nonatomic, readonly) NSMutableSet *hashCheckedForAlmondTable;
@property(nonatomic, readonly) NSMutableSet *deviceValuesCheckedForAlmondTable;

@property(nonatomic, readonly) NSObject *willFetchDeviceListFlagSyncLocker;
@property(nonatomic, readonly) NSMutableSet *willFetchDeviceListFlag;

@property(nonatomic, readonly) NSObject *almondModeSynLocker;
@property(nonatomic, readonly) NSMutableDictionary *almondModeTable;
@property(nonatomic) NSDictionary *pendingModeTable;

@property(nonatomic, readonly) NSObject *expirableCommandsLocker;
@property(nonatomic, readonly) NSMutableDictionary *expirableCommands;
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

        _expirableCommandsLocker = [NSObject new];
        _expirableCommands = [NSMutableDictionary new];
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

- (void)markPendingModeForAlmond:(NSString *)aAlmondMac mode:(SFIAlmondMode)mode {
    @synchronized (self.almondModeSynLocker) {
        self.pendingModeTable = @{
                @"mac" : aAlmondMac,
                @"mode" : @(mode),
        };
    }
}

- (void)confirmPendingModeForAlmond {
    @synchronized (self.almondModeSynLocker) {
        NSDictionary *table = self.pendingModeTable;
        if (table) {
            self.pendingModeTable = nil;

            NSString *almondMac = table[@"mac"];
            NSNumber *modeNum = table[@"mode"];
            SFIAlmondMode mode = (SFIAlmondMode) modeNum.intValue;

            [self markModeForAlmond:almondMac mode:mode];
        }
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

- (void)markExpirableRequest:(enum ExpirableCommandType)type namespace:(NSString *)namespace genericCommand:(GenericCommand *)cmd {
    if (!namespace) {
        return;
    }
    @synchronized (self.expirableCommandsLocker) {
        NSNumber *key = @(type);
        NSMutableDictionary *dict = self.expirableCommands[key];
        if (!dict) {
            dict = [NSMutableDictionary dictionary];
            self.expirableCommands[key] = dict;
        }
        dict[namespace] = cmd;
    }
}

- (GenericCommand *)expirableRequest:(enum ExpirableCommandType)type namespace:(NSString *)namespace {
    if (!namespace) {
        return nil;
    }
    @synchronized (self.expirableCommandsLocker) {
        NSNumber *key = @(type);

        NSMutableDictionary *dict = self.expirableCommands[key];
        if (!dict) {
            return nil;
        }

        return dict[namespace];
    }
}

- (void)clearExpirableRequest:(enum ExpirableCommandType)type namespace:(NSString *)namespace {
    if (!namespace) {
        return;
    }
    @synchronized (self.expirableCommandsLocker) {
        NSNumber *key = @(type);
        NSMutableDictionary *dict = self.expirableCommands[key];
        if (dict) {
            [dict removeObjectForKey:namespace];
        }
    }
}


@end