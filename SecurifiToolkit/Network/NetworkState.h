//
// Created by Matthew Sinclair-Day on 6/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

@class GenericCommand;

typedef NS_ENUM(unsigned int, ExpirableCommandType) {
    ExpirableCommandType_almondStateAndSettingsRequest,
    ExpirableCommandType_deviceLogRequest,
    ExpirableCommandType_notificationListRequest,
    ExpirableCommandType_notificationClearCountRequest,
    ExpirableCommandType_notificationPreferencesChangesRequest,
};

// A value holder for tracking per-connection session state. Every instance of a Network has its own NetworkState,
// and therefore when the Network is disposed we are also assured states stored in this helper are also disposed and
// no special work is needed to clean them up.
@interface NetworkState : NSObject

// Provides a per-connection ledger for tracking Device Hash requests.
// A Hash is requested for a current Almond on each connection because
// the state could have changed while the app was not connected to the cloud.
- (void)markHashFetchedForAlmond:(NSString *)aAlmondMac;

// Tests whether a Hash was requested already.
// TRUE if requested. FALSE otherwise.
- (BOOL)wasHashFetchedForAlmond:(NSString *)aAlmondMac;

// Provides a way to flag that a Device List is being fetched.
// Used to prevent sending multiple same requests.
// Caller should call clearWillFetchDeviceListForAlmond: on receiving a reply
- (void)markWillFetchDeviceListForAlmond:(NSString *)aAlmondMac;

// Tests whether a Device List has been requested already.
// TRUE if requested. FALSE otherwise.
- (BOOL)willFetchDeviceListFetchedForAlmond:(NSString *)aAlmondMac;

// Clears the flag indicating that a Device List is being fetched
- (void)clearWillFetchDeviceListForAlmond:(NSString *)aAlmondMac;

// Provides a per-connection ledger for tracking Device Value List requests.
// A list is should be requested at least once per each connection, but it
// should not be requested repeatedly. This ledger helps manage the process.
- (void)markDeviceValuesFetchedForAlmond:(NSString *)aAlmondMac;

// Tests whether a Device Values List was requested already.
// TRUE if requested. FALSE otherwise.
- (BOOL)wasDeviceValuesFetchedForAlmond:(NSString *)aAlmondMac;

// stores the currently known almond mode state
- (void)markModeForAlmond:(NSString*)aAlmondMac mode:(SFIAlmondMode)mode;

// set prior to sending out a change-mode request; the mode is retained and on receipt of a
// successful change, the pending mode can be "confirmed" via confirmPendingModeForAlmond
- (void)markPendingModeForAlmond:(NSString*)aAlmondMac mode:(SFIAlmondMode)mode;

// called to confirm that a pending Almond mode; in effect, calls markModeForAlmond:mode:
- (void)confirmPendingModeForAlmond;

- (SFIAlmondMode)almondMode:(NSString*)aAlmondMac;

- (void)clearAlmondMode:(NSString*)aAlmondMac;

- (void)markExpirableRequest:(enum ExpirableCommandType)type namespace:(NSString*)namespace genericCommand:(GenericCommand *)cmd;

- (GenericCommand *)expirableRequest:(enum ExpirableCommandType)type namespace:(NSString *)namespace;

- (void)clearExpirableRequest:(enum ExpirableCommandType)type namespace:(NSString *)namespace;

@end