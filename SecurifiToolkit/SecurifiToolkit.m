//
//  SecurifiToolkit.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <SecurifiToolkit/SecurifiToolkit.h>
#import "Network.h"
#import "NetworkState.h"
#import "Login.h"
#import "LoginTempPass.h"
#import "LogoutAllRequest.h"
#import "KeyChainWrapper.h"
#import "ChangePasswordRequest.h"
#import "UnlinkAlmondRequest.h"
#import "UserInviteRequest.h"
#import "DeleteAccountRequest.h"
#import "DeleteSecondaryUserRequest.h"
#import "DeleteMeAsSecondaryUserRequest.h"
#import "MeAsSecondaryUserRequest.h"
#import "DynamicNotificationPreferenceList.h"
#import "SFIXmlWriter.h"
#import "SFINotificationUser.h"
#import "SFIOfflineDataManager.h"
#import "DatabaseStore.h"
#import "NotificationRegistration.h"
#import "NotificationDeleteRegistrationRequest.h"
#import "NotificationPreferenceListRequest.h"
#import "NotificationPreferenceListResponse.h"
#import "NotificationRegistrationResponse.h"
#import "NotificationDeleteRegistrationResponse.h"
#import "NotificationPreferences.h"
#import "DynamicAlmondModeChange.h"
#import "AlmondModeRequest.h"
#import "AlmondModeResponse.h"
#import "AlmondModeChangeResponse.h"
#import "NotificationPreferenceResponse.h"
#import "NotificationListRequest.h"
#import "NotificationListResponse.h"
#import "NotificationCountResponse.h"
#import "NotificationClearCountResponse.h"
#import "NotificationClearCountRequest.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "CommandTypeScoreboardEvent.h"
#import "RouterCommandParser.h"

#define kCURRENT_TEMPERATURE_FORMAT                         @"kCurrentThemperatureFormat"
#define kPREF_CURRENT_ALMOND                                @"kAlmondCurrent"
#define kPREF_USER_DEFAULT_LOGGED_IN_ONCE                   @"kLoggedInOnce"
#define kPREF_DEFAULT_CONNECTION_MODE                       @"kDefaultConnectionMode"

#define SEC_SERVICE_NAME                                    @"securifiy.login_service"
#define SEC_EMAIL                                           @"com.securifi.email"
#define SEC_PWD                                             @"com.securifi.pwd"
#define SEC_USER_ID                                         @"com.securifi.userid"
#define SEC_IS_ACCOUNT_ACTIVATED                            @"com.securifi.isActivated"
#define SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT          @"com.securifi.minsRemaining"
#define SEC_APN_TOKEN                                       @"com.securifi.apntoken"

#define GET_WIRELESS_SUMMARY_COMMAND @"<root><AlmondRouterSummary action=\"get\">1</AlmondRouterSummary></root>"
#define GET_WIRELESS_SETTINGS_COMMAND @"<root><AlmondWirelessSettings action=\"get\">1</AlmondWirelessSettings></root>"
#define GET_CONNECTED_DEVICE_COMMAND @"<root><AlmondConnectedDevices action=\"get\">1</AlmondConnectedDevices></root>"
#define GET_BLOCKED_DEVICE_COMMAND @"<root><AlmondBlockedMACs action=\"get\">1</AlmondBlockedMACs></root>"
#define APPLICATION_ID @"1001"


NSString *const kSFIDidCompleteLoginNotification = @"kSFIDidCompleteLoginNotification";
NSString *const kSFIDidLogoutNotification = @"kSFIDidLogoutNotification";
NSString *const kSFIDidLogoutAllNotification = @"kSFIDidLogoutAllNotification";
NSString *const kSFIDidChangeCurrentAlmond = @"kSFIDidChangeCurrentAlmond";
NSString *const kSFIDidUpdateAlmondList = @"kSFIDidUpdateAlmondList";
NSString *const kSFIDidChangeAlmondConnectionMode = @"kSFIDidChangeAlmondConnectionMode";
NSString *const kSFIDidChangeAlmondName = @"kSFIDidChangeAlmondName";
NSString *const kSFIDidCompleteAlmondModeChangeRequest = @"kSFIDidCompleteAlmondChangeRequest";
NSString *const kSFIAlmondModeDidChange = @"kSFIAlmondModeDidChange";
NSString *const kSFIDidReceiveGenericAlmondRouterResponse = @"kSFIDidReceiveGenericAlmondRouterResponse";
NSString *const kSFIDidChangeDeviceList = @"kSFIDidChangeDeviceData";
NSString *const kSFIDidChangeDeviceValueList = @"kSFIDidChangeDeviceValueList";
NSString *const kSFIDidCompleteMobileCommandRequest = @"kSFIDidCompleteMobileCommandRequest";
NSString *const kSFIDidRegisterForNotifications = @"kSFIDidRegisterForNotifications";
NSString *const kSFIDidFailToRegisterForNotifications = @"kSFIDidFailToRegisterForNotifications";
NSString *const kSFIDidDeregisterForNotifications = @"kSFIDidDeregisterForNotifications";
NSString *const kSFIDidFailToDeregisterForNotifications = @"kSFIDidFailToDeregisterForNotifications";
NSString *const kSFINotificationDidStore = @"kSFINotificationDidStore";
NSString *const kSFINotificationDidMarkViewed = @"kSFINotificationDidMarkViewed";
NSString *const kSFINotificationBadgeCountDidChange = @"kSFINotificationBadgeCountDidChange";
NSString *const kSFINotificationPreferencesDidChange = @"kSFINotificationPreferencesDidChange";

NSString *const kSFINotificationPreferenceChangeActionAdd = @"add";
NSString *const kSFINotificationPreferenceChangeActionDelete = @"delete";

// ===============================================================================================

@interface SecurifiToolkit () <SFIDeviceLogStoreDelegate, NetworkDelegate>
@property(atomic) BOOL isShutdown;

@property(nonatomic, readonly) SecurifiConfigurator *config;
@property(nonatomic, readonly) SFIReachabilityManager *cloudReachability;
@property(nonatomic, readonly) SFIOfflineDataManager *dataManager;
@property(nonatomic, readonly) DatabaseStore *notificationsDb;
@property(nonatomic, readonly) DatabaseStore *deviceLogsDb;
@property(nonatomic, readonly) id <SFINotificationStore> notificationsStore;
@property(nonatomic, readonly) Scoreboard *scoreboard;
@property(nonatomic, readonly) dispatch_queue_t networkCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t networkDynamicCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t commandDispatchQueue;
@property(nonatomic, strong) Network *cloudNetwork;
@property(nonatomic, strong) Network *localNetwork;

@end

@implementation SecurifiToolkit

#pragma mark - Lifecycle methods

static SecurifiToolkit *toolkit_singleton = nil;

+ (void)initialize:(SecurifiConfigurator *)config {
    static dispatch_once_t once_predicate;

    dispatch_once(&once_predicate, ^{
        toolkit_singleton = [[SecurifiToolkit alloc] initWithConfig:config];
    });
}

+ (BOOL)isInitialized {
    return toolkit_singleton != nil;
}

+ (instancetype)sharedInstance {
    return toolkit_singleton;
}

- (instancetype)initWithConfig:(SecurifiConfigurator *)config {
    self = [super init];
    if (self) {
        _config = [config copy];

        _scoreboard = [Scoreboard new];
        _dataManager = [SFIOfflineDataManager new];

        if (config.enableNotifications) {
            {
                DatabaseStore *store = [DatabaseStore notificationsDatabase];
                _notificationsDb = store;
                _notificationsStore = [_notificationsDb newNotificationStore];
            }

            {
                DatabaseStore *store = [DatabaseStore deviceLogsDatabase];
                _deviceLogsDb = store;
            }
        }

        // default; do not change
        [self setupReachability:config.productionCloudHost];
        self.useProductionCloud = YES;

        _networkCallbackQueue = dispatch_queue_create("socket_callback", DISPATCH_QUEUE_CONCURRENT);
        _networkDynamicCallbackQueue = dispatch_queue_create("socket_dynamic_callback", DISPATCH_QUEUE_CONCURRENT);
        _commandDispatchQueue = dispatch_queue_create("command_dispatch", DISPATCH_QUEUE_SERIAL);

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        [center addObserver:self selector:@selector(onReachabilityChanged:) name:kSFIReachabilityChangedNotification object:nil];

        [center addObserver:self selector:@selector(onLoginResponse:) name:LOGIN_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onLogoutResponse:) name:LOGOUT_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onLogoutAllResponse:) name:LOGOUT_ALL_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeleteAccountResponse:) name:DELETE_ACCOUNT_RESPONSE_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onDynamicAlmondListAdd:) name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDynamicAlmondListDelete:) name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDynamicAlmondNameChange:) name:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onAlmondRouterGenericNotification:) name:GENERIC_COMMAND_CLOUD_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onAlmondRouterGenericCommandResponse:) name:GENERIC_COMMAND_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:ALMOND_COMMAND_RESPONSE_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onDynamicDeviceListChange:) name:DYNAMIC_DEVICE_DATA_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceListResponse:) name:DEVICE_DATA_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onDynamicDeviceValueListChange:) name:DYNAMIC_DEVICE_VALUE_LIST_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceValueListChange:) name:DEVICE_VALUE_LIST_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onAlmondListResponse:) name:ALMOND_LIST_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceHashResponse:) name:DEVICEDATA_HASH_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onDeviceListAndValuesResponse:) name:DEVICE_LIST_AND_VALUES_NOTIFIER object:nil];

        if (config.enableNotifications) {
            [center addObserver:self selector:@selector(onNotificationRegistrationResponseCallback:) name:NOTIFICATION_REGISTRATION_NOTIFIER object:nil];
            [center addObserver:self selector:@selector(onNotificationDeregistrationResponseCallback:) name:NOTIFICATION_DEREGISTRATION_NOTIFIER object:nil];
            [center addObserver:self selector:@selector(onNotificationPrefListChange:) name:NOTIFICATION_PREFERENCE_LIST_RESPONSE_NOTIFIER object:nil];
            [center addObserver:self selector:@selector(onDynamicNotificationPrefListChange:) name:DYNAMIC_NOTIFICATION_PREFERENCE_LIST_NOTIFIER object:nil];

            [center addObserver:self selector:@selector(onDeviceNotificationPreferenceChangeResponseCallback:) name:NOTIFICATION_PREFERENCE_CHANGE_RESPONSE_NOTIFIER object:nil];

            [center addObserver:self selector:@selector(onAlmondModeChangeCompletion:) name:ALMOND_MODE_CHANGE_NOTIFIER object:nil];
            [center addObserver:self selector:@selector(onAlmondModeResponse:) name:ALMOND_MODE_RESPONSE_NOTIFIER object:nil];
            [center addObserver:self selector:@selector(onDynamicAlmondModeChange:) name:DYNAMIC_ALMOND_MODE_CHANGE_NOTIFIER object:nil];

            [center addObserver:self selector:@selector(onNotificationListSyncResponse:) name:NOTIFICATION_LIST_SYNC_RESPONSE_NOTIFIER object:nil];
            [center addObserver:self selector:@selector(onNotificationCountResponse:) name:NOTIFICATION_COUNT_RESPONSE_NOTIFIER object:nil];

            [center addObserver:self selector:@selector(onNotificationClearCountResponse:) name:NOTIFICATION_CLEAR_COUNT_RESPONSE_NOTIFIER object:nil];

            [center addObserver:self selector:@selector(onDeviceLogSyncResponse:) name:DEVICELOG_LIST_SYNC_RESPONSE_NOTIFIER object:nil];
        }
    }

    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma mark - Connection management

- (enum SFIAlmondConnectionMode)currentConnectionMode {
    return self.defaultConnectionMode;
/*
    SFIAlmondPlus *plus = self.currentAlmond;
    if (plus) {
        // account for when app is not yet logged into the cloud and does not have an almond list
        return [self connectionModeForAlmond:plus.almondplusMAC];
    }
    else {
        return self.defaultConnectionMode;
    }
*/
}

// tests that the system configuration and current almond's link type are compatible with the specified mode
- (BOOL)isCurrentConnectionModeCompatible:(enum SFIAlmondConnectionMode)mode {
    // if systems is not configured for cloud, then say NO
    enum SFIAlmondConnectionMode defaultMode = [self defaultConnectionMode];
    if (defaultMode != mode) {
        return NO;
    }

    // check current almond config
    SFIAlmondPlus *current = [self currentAlmond];
    if (current) {
        if (current.linkType == SFIAlmondPlusLinkType_local_only) {
            return mode == SFIAlmondConnectionMode_local;
        }
    }

    // if no current almond, then we allow cloud connection (consider "logging in scenario"
    return YES;
}

- (enum SFIAlmondConnectionMode)defaultConnectionMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    enum SFIAlmondConnectionMode mode = (enum SFIAlmondConnectionMode) [defaults integerForKey:kPREF_DEFAULT_CONNECTION_MODE];
    return mode;
}

- (void)setDefaultConnectionMode:(enum SFIAlmondConnectionMode)mode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:mode forKey:kPREF_DEFAULT_CONNECTION_MODE];
}

- (enum SFIAlmondConnectionMode)connectionModeForAlmond:(NSString *)almondMac {
    if (!self.config.enableLocalNetworking) {
        return SFIAlmondConnectionMode_cloud;
    }

    enum SFIAlmondConnectionMode defaultMode = [self defaultConnectionMode];

/*
    // Find the Almond; check current one first for "fail fast" scenario, as it is likely the one we want.
    // The scenario we need to avoid: returning Cloud mode for an Almond that is local only.
    // In effect, the logic will auto-switch the connection mode for local-only almonds; or otherwise,
    // honor the default mode.
    SFIAlmondPlus *current = [self currentAlmond];
    if (current && [current.almondplusMAC isEqualToString:almondMac]) {
        if (current.linkType == SFIAlmondPlusLinkType_local_only) {
            return SFIAlmondConnectionMode_local;
        }
    }
    else if ([self almondExists:almondMac]) {
        // check whether the almond exists in the cloud list
        return defaultMode; // any mode is OK for an almond affiliated with the cloud
    }
    else {
        SFIAlmondLocalNetworkSettings *settings = [self localNetworkSettingsForAlmond:almondMac];
        if (settings) {
            return SFIAlmondConnectionMode_local;
        }
    }
*/

    return defaultMode;
}

- (void)setConnectionMode:(enum SFIAlmondConnectionMode)mode forAlmond:(NSString *)almondMac {
    [self setDefaultConnectionMode:mode];
    [self tryShutdownAndStartNetworks:mode almondMac:almondMac];
    [self postNotification:kSFIDidChangeAlmondConnectionMode data:nil];
}

- (void)setLocalNetworkSettings:(SFIAlmondLocalNetworkSettings *)settings {
    if (![settings hasCompleteSettings]) {
        return;
    }

    NSString *almondMac = settings.almondplusMAC;
    enum SFIAlmondConnectionMode mode = [self connectionModeForAlmond:almondMac];

    [self storeLocalNetworkSettings:settings];
    [self tryShutdownAndStartNetworks:mode almondMac:almondMac];
}

- (enum SFIAlmondConnectionStatus)connectionStatusForAlmond:(NSString *)almondMac {
    enum NetworkConnectionStatus status = NetworkConnectionStatusUninitialized;

    if (self.config.enableLocalNetworking) {
        enum SFIAlmondConnectionMode mode = [self connectionModeForAlmond:almondMac];

        if (![self isCurrentConnectionModeCompatible:mode]) {
            return SFIAlmondConnectionStatus_error_mode;
        }

        switch (mode) {
            case SFIAlmondConnectionMode_cloud: {
                status = [self cloudNetworkStatus];
                break;
            }
            case SFIAlmondConnectionMode_local: {
                SFIAlmondLocalNetworkSettings *settings = [self localNetworkSettingsForAlmond:almondMac];
                if (settings) {
                    Network *network = self.localNetwork;
                    if (network) {
                        status = network.connectionState;
                    }
                }
                break;
            }
        }
    }
    else {
        status = [self cloudNetworkStatus];
    }

    return [self connectionStatusFromNetworkState:status];
}

- (SFIAlmondLocalNetworkSettings *)localNetworkSettingsForAlmond:(NSString *)almondMac {
    return [self.dataManager readAlmondLocalNetworkSettings:almondMac];
}

- (void)removeLocalNetworkSettingsForAlmond:(NSString *)almondMac {
    if (!almondMac) {
        return;
    }

    [self.dataManager deleteLocalNetworkSettingsForAlmond:almondMac];

    SFIAlmondPlus *currentAlmond = self.currentAlmond;
    if (currentAlmond) {
        if ([currentAlmond.almondplusMAC isEqualToString:almondMac]) {
            [self removeCurrentAlmond];
        }
    }

    [self postNotification:kSFIDidUpdateAlmondList data:nil];
}

- (void)storeLocalNetworkSettings:(SFIAlmondLocalNetworkSettings *)settings {
    // guard against bad data
    if (![settings hasCompleteSettings]) {
        return;
    }

    [self.dataManager writeAlmondLocalNetworkSettings:settings];
}

- (void)tryUpdateLocalNetworkSettingsForAlmond:(NSString *)almondMac withRouterSummary:(const SFIRouterSummary *)summary {
    SFIAlmondLocalNetworkSettings *settings = [self localNetworkSettingsForAlmond:almondMac];
    if (!settings) {
        settings = [SFIAlmondLocalNetworkSettings new];
        settings.almondplusMAC = almondMac;

        // very important: copy name to settings, if possible
        SFIAlmondPlus *plus = [self cloudAlmond:almondMac];
        if (plus) {
            settings.almondplusName = plus.almondplusName;
        }
    }

    if (summary.login) {
        settings.login = summary.login;
    }
    if (summary.password) {
        NSString *decrypted = [summary decryptPassword:almondMac];
        if (decrypted) {
            settings.password = decrypted;
        }
    }
    if (summary.url) {
        settings.host = summary.url;
    }

    [self setLocalNetworkSettings:settings];
}

// for changing network settings
// ensures a local connection for the specified almond is shutdown and, if needed, restarted
- (void)tryShutdownAndStartNetworks:(enum SFIAlmondConnectionMode)mode almondMac:(NSString *)almondMac {
    if (!self.config.enableLocalNetworking) {
        return;
    }

    __weak SecurifiToolkit *block_self = self;

    dispatch_async(self.commandDispatchQueue, ^() {
        if (mode == SFIAlmondConnectionMode_local) {
            [block_self _asyncInitLocal:almondMac];
            [block_self tearDownCloudNetwork];
        }
        else {
            [block_self _asyncInitCloud];
            [block_self tearDownLocalNetwork];
        }
    });
}

#pragma mark - Connection and Network state reporting

- (BOOL)isNetworkOnline {
    if ([self currentConnectionMode] == SFIAlmondConnectionMode_cloud) {
        return [self isCloudOnline];
    }
    else {
        return self.localNetwork.isStreamConnected;
    }
}

- (BOOL)isCloudOnline {
    BOOL reachable = [self isCloudReachable];
    if (!reachable) {
        return NO;
    }

    NetworkConnectionStatus state = [self cloudNetworkStatus];

    enum SFIAlmondConnectionStatus status = [self connectionStatusFromNetworkState:state];
    return status == SFIAlmondConnectionStatus_connected;
}

- (BOOL)isCloudReachable {
    return [self.cloudReachability isReachable];
}

- (BOOL)isCloudLoggedIn {
    Network *network = self.cloudNetwork;
    return network && network.loginStatus == NetworkLoginStatusLoggedIn;
}

- (BOOL)isAccountActivated {
    return [self secIsAccountActivated];
}

- (int)minsRemainingForUnactivatedAccount {
    return (int) [self secMinsRemainingForUnactivatedAccount];
}

- (enum SFIAlmondConnectionStatus)connectionStatusFromNetworkState:(enum NetworkConnectionStatus)status {
    switch (status) {
        case NetworkConnectionStatusUninitialized:
            return SFIAlmondConnectionStatus_disconnected;
        case NetworkConnectionStatusInitializing:
            return SFIAlmondConnectionStatus_connecting;
        case NetworkConnectionStatusInitialized:
            return SFIAlmondConnectionStatus_connected;
        case NetworkConnectionStatusShutdown:
            return SFIAlmondConnectionStatus_disconnected;
        default:
            return SFIAlmondConnectionStatus_disconnected;
    }
}

- (NetworkConnectionStatus)cloudNetworkStatus {
    return [self networkStatus:self.cloudNetwork];
}

- (NetworkConnectionStatus)networkStatus:(Network *)network {
    if (network) {
        return network.connectionState;
    }
    else {
        return NetworkConnectionStatusUninitialized;
    }
}

- (void)setupReachability:(NSString *)hostname {
    [_cloudReachability shutdown];
    _cloudReachability = [[SFIReachabilityManager alloc] initWithHost:hostname];
}

- (void)onReachabilityChanged:(id)notice {
    self.scoreboard.reachabilityChangedCount++;
}

#pragma mark - SDK Initialization

- (SecurifiConfigurator *)configuration {
    return [self.config copy];
}

// Initialize the SDK. Can be called repeatedly to ensure the SDK is set-up.
- (void)initToolkit {
    [self _asyncInitCloud];

    SFIAlmondPlus *plus = self.currentAlmond;
    if (plus) {
        [self _asyncInitLocal:plus.almondplusMAC];
    }
}

- (void)_asyncInitCloud {
    if (self.isShutdown) {
        DLog(@"guard: INIT SDK. Already shutdown. Returning.");
        return;
    }

    __weak SecurifiToolkit *block_self = self;

    dispatch_async(self.commandDispatchQueue, ^() {
        if (block_self.isShutdown) {
            DLog(@"INIT SDK. SDK is already shutdown. Returning.");
            return;
        }

        // fail fast if mode is set for Local
        //
        if (![block_self isCurrentConnectionModeCompatible:SFIAlmondConnectionMode_cloud]) {
            return;
        }

        NetworkConnectionStatus state = [block_self cloudNetworkStatus];
        switch (state) {
            case NetworkConnectionStatusInitialized: {
                DLog(@"INIT SDK. Cloud connection established already. Returning.");
                return;
            };

            case NetworkConnectionStatusInitializing: {
                DLog(@"INIT SDK. Cloud connection already initializing. Returning.");
                return;
            };

            case NetworkConnectionStatusUninitialized:
            case NetworkConnectionStatusShutdown:
            default: {
                DLog(@"INIT SDK. Cloud connection needs establishment. Passing thru");
            };
        }

        NSLog(@"INIT SDK");

        Network *network = [block_self setupCloudNetwork];

        // After setting up the network, we need to do some basic things
        // 1. send sanity cmd to test the socket
        // 2. logon
        // 3. update the devices list
        // 4. check hashes etc.

        GenericCommand *cmd;
        BOOL cmdSendSuccess;

        // Send sanity command testing network connection
        cmd = [block_self makeCloudSanityCommand];
        cmdSendSuccess = [block_self internalInitializeCloud:network command:cmd];
        if (!cmdSendSuccess) {
            NSLog(@"%s: init SDK: send sanity failed:", __PRETTY_FUNCTION__);
            return;
        }

        DLog(@"%s: init SDK: send sanity successful", __PRETTY_FUNCTION__);
        DLog(@"%s: session started: %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());

        // If no logon credentials, then initialization is completed.
        if (![block_self hasLoginCredentials]) {
            DLog(@"%s: no logon credentials", __PRETTY_FUNCTION__);
            network.loginStatus = NetworkLoginStatusNotLoggedIn;
            [network markCloudInitialized]; //todo fix me: this is fouling up the Network control logic, but removing it then prevents normal commands from being sent...

            // This event is very important because it will prompt the UI not to wait for events and immediately show a logon screen
            // We probably should track things down and find a way to remove a dependency on this event in the UI.
            [block_self postNotification:kSFIDidLogoutNotification data:nil];
            return;
        }

        // Send logon credentials
        network.loginStatus = NetworkLoginStatusInProcess;

        DLog(@"%s: sending temp pass credentials", __PRETTY_FUNCTION__);
        cmd = [block_self makeTempPassLoginCommand];
        cmdSendSuccess = [block_self internalInitializeCloud:network command:cmd];
        if (!cmdSendSuccess) {
            DLog(@"%s: failed on sending login command", __PRETTY_FUNCTION__);
        }

        // Request updates to the almond; See onLoginResponse handler for logic handling first-time login and follow-on requests.
        [block_self asyncInitializeConnection1:network];
    });
}

- (void)_asyncInitLocal:(NSString *)almondMac {
    if (self.isShutdown) {
        DLog(@"guard: INIT SDK. Already shutdown. Returning.");
        return;
    }

    __weak SecurifiToolkit *block_self = self;

    dispatch_async(self.commandDispatchQueue, ^() {
        if (block_self.isShutdown) {
            DLog(@"INIT SDK. SDK is already shutdown. Returning.");
            return;
        }

        // fail fast if mode is set for Local
        //
        if (![block_self isCurrentConnectionModeCompatible:SFIAlmondConnectionMode_local]) {
            return;
        }

        if ([block_self isCurrentLocalNetworkForAlmond:almondMac]) {
            NetworkConnectionStatus state = [block_self networkStatus:block_self.localNetwork];
            switch (state) {
                case NetworkConnectionStatusInitialized: {
                    DLog(@"INIT SDK. Local connection established already. Returning.");
                    return;
                };

                case NetworkConnectionStatusInitializing: {
                    DLog(@"INIT SDK. Local connection already initializing. Returning.");
                    return;
                };

                case NetworkConnectionStatusUninitialized:
                case NetworkConnectionStatusShutdown:
                default: {
                    DLog(@"INIT SDK. Local connection needs establishment. Passing thru");
                };
            }
        }

        [block_self setupLocalNetworkForAlmond:almondMac];
        [block_self asyncRequestDeviceList:almondMac];
    });
}

// Shutdown the SDK. No further work may be done after this method has been invoked.
- (void)shutdownToolkit {
    if (self.isShutdown) {
        return;
    }
    self.isShutdown = YES;
    NSLog(@"Shutdown SDK");

    SecurifiToolkit __weak *block_self = self;

    dispatch_async(self.networkCallbackQueue, ^(void) {
        [block_self tearDownCloudNetwork];
        [block_self tearDownLocalNetwork];
    });
}

- (void)debugUpdateConfiguration:(SecurifiConfigurator *)configurator {
    _config = configurator.copy;
}

// Invokes post-connection set-up and login to request updates that had been made while the connection was down
- (void)asyncInitializeConnection1:(Network *)network {
    // After successful login, refresh the Almond list and hash values.
    // This routine is important because the UI will listen for outcomes to these requests.
    // Specifically, the event kSFIDidUpdateAlmondList.

    __weak SecurifiToolkit *block_self = self;
    dispatch_async(self.commandDispatchQueue, ^() {
        DLog(@"%s: requesting almond list", __PRETTY_FUNCTION__);
        GenericCommand *cmd = [block_self makeAlmondListCommand];
        [block_self internalInitializeCloud:network command:cmd];
    });
}

// Invokes post-connection set-up and login to request updates that had been made while the connection was down
- (void)asyncInitializeConnection2:(Network *)network {
    // After successful login, refresh the Almond list and hash values.
    // This routine is important because the UI will listen for outcomes to these requests.
    // Specifically, the event kSFIDidUpdateAlmondList.

    __weak SecurifiToolkit *block_self = self;
    dispatch_async(self.commandDispatchQueue, ^() {
        SFIAlmondPlus *plus = [block_self currentAlmond];
        if (plus != nil) {
            NSString *mac = plus.almondplusMAC;

            NetworkState *state = network.networkState;
            if (![state wasHashFetchedForAlmond:mac]) {
                [state markHashFetchedForAlmond:mac];

                DLog(@"%s: requesting hash for current almond: %@", __PRETTY_FUNCTION__, mac);
                GenericCommand *cmd = [block_self makeDeviceHashCommand:mac];
                [block_self internalInitializeCloud:network command:cmd];
            }

            [block_self tryRequestAlmondMode:mac];
        }

        [block_self tryRefreshNotifications];

        [network markCloudInitialized];
    });
}

#pragma mark - Command dispatch

// 1. open connection
// 2. send cloud sanity command
//      a. wait for response
//      b. if no response or bad response, kill connection and mark network as dead
//      c. if good response, then process next command
// 3. (optional) send logon (temp pass)
//      a. wait for response
//      b. if no response or bad response, kill connection and mark network as dead
//      c. if good response, then process next command

- (void)closeConnection {
    [self tearDownCloudNetwork];
}

- (void)asyncSendToCloud:(GenericCommand *)command {
    if (self.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }

    if (![self isCurrentConnectionModeCompatible:SFIAlmondConnectionMode_cloud]) {
        return;
    }

    // Initialize network if need be
    Network *network = self.cloudNetwork;
    if (network == nil || (!network.isStreamConnected && network.connectionState != NetworkConnectionStatusInitializing)) {
        // Set up network and wait
        //
        NSLog(@"Waiting to initialize socket");
        [self _asyncInitCloud];
    }

    __weak SecurifiToolkit *block_self = self;
    dispatch_async(self.commandDispatchQueue, ^() {
        BOOL success = [block_self.cloudNetwork submitCommand:command];
        if (success) {
            DLog(@"[Generic cmd: %d] send success", command.commandType);
        }
        else {
            DLog(@"[Generic cmd: %d] send error", command.commandType);
        }
    });
}

- (void)asyncSendToLocal:(GenericCommand *)command almondMac:(NSString *)almondMac {
    if (self.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }

    if (![self isCurrentConnectionModeCompatible:SFIAlmondConnectionMode_local]) {
        return;
    }

    __weak SecurifiToolkit *block_self = self;
    dispatch_async(self.commandDispatchQueue, ^() {
        Network *network = [block_self setupLocalNetworkForAlmond:almondMac];
        BOOL success = [network submitCommand:command];

        if (success) {
            DLog(@"[Generic cmd: %d] send success", command.commandType);
        }
        else {
            DLog(@"[Generic cmd: %d] send error", command.commandType);
        }
    });
}

- (sfi_id)asyncSendAlmondAffiliationRequest:(NSString *)linkCode {
    if (!linkCode) {
        return 0;
    }

    // ensure we are in the correct connection mode
    [self setDefaultConnectionMode:SFIAlmondConnectionMode_cloud];

    AffiliationUserRequest *request = [[AffiliationUserRequest alloc] init];
    request.Code = linkCode;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_AFFILIATION_CODE_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];

    return request.correlationId;
}

- (sfi_id)asyncChangeAlmond:(SFIAlmondPlus *)almond device:(SFIDevice *)device value:(SFIDeviceKnownValues *)newValue {
    NSString *almondMac = almond.almondplusMAC;
    BOOL local = [self useLocalNetwork:almondMac];

    if (local) {
        GenericCommand *cmd = [GenericCommand websocketSetSensorDevice:device value:newValue];
        [self asyncSendToLocal:cmd almondMac:almondMac];

        return cmd.correlationId;
    }
    else {
        GenericCommand *cmd = [GenericCommand cloudSetSensorDevice:device value:newValue almondMac:almondMac];
        [self asyncSendToCloud:cmd];

        return cmd.correlationId;
    }
}

- (sfi_id)asyncChangeAlmond:(SFIAlmondPlus *)almond device:(SFIDevice *)device name:(NSString *)deviceName location:(NSString *)deviceLocation {
    NSString *almondMac = almond.almondplusMAC;

    BOOL local = [self useLocalNetwork:almondMac];
    if (local) {
        GenericCommand *cmd = [GenericCommand websocketSensorDevice:device name:deviceName location:deviceLocation almondMac:almondMac];
        [self asyncSendToLocal:cmd almondMac:almondMac];

        return cmd.correlationId;
    }
    else {
        GenericCommand *cmd = [GenericCommand cloudSensorDevice:device name:deviceName location:deviceLocation almondMac:almondMac];
        [self asyncSendToCloud:cmd];

        return cmd.correlationId;
    }
}

#pragma mark - Cloud Logon

- (void)asyncSendLoginWithEmail:(NSString *)email password:(NSString *)password {
    if (self.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }

    self.scoreboard.loginCount++;

    [self tearDownLoginSession];
    [self setSecEmail:email];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kPREF_USER_DEFAULT_LOGGED_IN_ONCE];

    Login *loginCommand = [Login new];
    loginCommand.UserID = email;
    loginCommand.Password = password;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_LOGIN_COMMAND;
    cmd.command = loginCommand;

    [self asyncSendToCloud:cmd];
}

- (NSString *)loginEmail {
    return [self secEmail];
}

- (void)asyncSendLogout {
    if (self.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }

    if (self.isCloudOnline) {
        [self asyncRequestDeregisterForNotification];

        GenericCommand *cmd = [GenericCommand new];
        cmd.commandType = CommandType_LOGOUT_COMMAND;
        cmd.command = nil;

        [self asyncSendToCloud:cmd];
    }
    else {
        // Not connected, so just purge on-device credentials and cache
        [self onLogoutResponse:nil];
    }
}

- (void)asyncSendLogoutAllWithEmail:(NSString *)email password:(NSString *)password {
    LogoutAllRequest *request = [LogoutAllRequest new];
    request.UserID = [NSString stringWithString:email];
    request.Password = [NSString stringWithString:password];

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_LOGOUT_ALL_COMMAND;
    cmd.command = request;

    [self asyncSendToCloud:cmd];
}

- (void)storeLoginCredentials:(LoginResponse *)response {
    NSString *tempPass = response.tempPass;
    NSString *userId = response.userID;

    [self setSecPassword:tempPass];
    [self setSecUserId:userId];

    [self storeAccountActivationCredentials:response];
}

- (void)storeAccountActivationCredentials:(LoginResponse *)response {
    //PY: 101014 - Not activated accounts can be accessed for 7 days
    BOOL activated = response.isAccountActivated;
    NSUInteger remaining = response.minsRemainingForUnactivatedAccount;

    [self setSecAccountActivationStatus:activated];
    [self setSecMinsRemainingForUnactivatedAccount:remaining];
}

- (void)tearDownLoginSession {
    [self clearSecCredentials];
    [self purgeStoredData];
}

- (void)purgeStoredData {
    [self setDefaultConnectionMode:SFIAlmondConnectionMode_cloud];
    [self removeCurrentAlmond];
    [self.dataManager purgeAll]; // local connection information is not purged
    if (self.configuration.enableNotifications) {
        [self.notificationsDb purgeAll];
        [self.deviceLogsDb purgeAll];
    }
}

- (void)onLoginResponse:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    LoginResponse *res = info[@"data"];

    if (res.isSuccessful) {
        // Password is always cleared prior to submitting a fresh login from the UI.
        if (![self hasSecPassword]) {
            // So, if no password is in the keychain, then we know the temp pass needs to be stored on successful login response.
            // The response will contain the TempPass token, which we store in the keychain. The original password is not stored.
            [self storeLoginCredentials:res];
        }

        //PY 141014: Store account activation information every time the user logs in
        [self storeAccountActivationCredentials:res];

        // Request updates: normally, once a logon token has been retrieved, we just issue these commands as part of SDK initialization.
        // But the client was not logged in. Send them now...
        [self asyncInitializeConnection1:self.cloudNetwork];
    }
    else {
        // Logon failed:
        // Ensure all credentials are cleared
        [self tearDownLoginSession];
        [self tearDownCloudNetwork];
    }

    // In any case, notify the UI about the login result
    [self postNotification:kSFIDidCompleteLoginNotification data:res];
}

- (void)onLogoutResponse:(NSNotification *)notification {
    [self tearDownLoginSession];
    [self tearDownCloudNetwork];
    [self resetCurrentAlmond];
    [self postNotification:kSFIDidLogoutNotification data:nil];
}

- (void)onLogoutAllResponse:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    LoginResponse *res = info[@"data"];

    if (res.isSuccessful) {
        DLog(@"SDK received success on Logout All");
        [self tearDownLoginSession];
        [self tearDownCloudNetwork];
        [self resetCurrentAlmond];
    }

    [self postNotification:kSFIDidLogoutAllNotification data:res];
}

- (void)onDeleteAccountResponse:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    DeleteAccountResponse *res = info[@"data"];
    if (res.isSuccessful) {
        DLog(@"SDK received success on Delete Account");
        // treat it like a logout; clean up and tear down state
        [self onLogoutResponse:notification];
    }
}

// pre-populates the current almond setting based with the first local almond it finds.
// called after login session has been purged
- (void)resetCurrentAlmond {
    NSArray *local = self.localLinkedAlmondList;
    if (local.count == 0) {
        // notification will also be called below when setting current one;
        // we post it here to ensure that UI is aware the current one was reset
        [self postNotification:kSFIDidChangeCurrentAlmond data:nil];
    }
    else {
        SFIAlmondPlus *plus = local.firstObject;
        [self setCurrentAlmond:plus];
    }
}

#pragma mark - Almond Management

- (void)removeCurrentAlmond {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kPREF_CURRENT_ALMOND];
    [prefs synchronize];
}

- (void)setCurrentAlmond:(SFIAlmondPlus *)almond {
    if (!almond) {
        return;
    }

    [self writeCurrentAlmond:almond];
    [self manageCurrentAlmondChange:almond];

    [self postNotification:kSFIDidChangeCurrentAlmond data:almond];
}

- (void)writeCurrentAlmond:(SFIAlmondPlus *)almond {
    if (!almond) {
        return;
    }

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:almond];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:kPREF_CURRENT_ALMOND];
    [defaults synchronize];
}

- (void)manageCurrentAlmondChange:(SFIAlmondPlus *)almond {
    if (!almond) {
        return;
    }

    NSString *mac = almond.almondplusMAC;

    // reset connections
    [self tryShutdownAndStartNetworks:self.defaultConnectionMode almondMac:mac];

    NSArray *devices = [self deviceList:mac];
    if (devices.count == 0) {
        DLog(@"%s: devices empty: requesting device list for current almond: %@", __PRETTY_FUNCTION__, mac);
        [self asyncRequestDeviceList:mac];
    }

    if (almond.linkType == SFIAlmondPlusLinkType_cloud_local) {
        // If the network is down, then do not send Hash request:
        // 1. it's not needed
        // 2. it will be sent automatically when the connection comes up
        // 3. sending it now will stimulate connection establishment and sending the command prior to other normal-bring up
        // commands will cause the connection to fail IF the currently selected almond is no longer linked to the account.
        Network *network = self.cloudNetwork;

        if (network == nil) {
            DLog(@"%s: network is down; not sending request for hash or mode: %@", __PRETTY_FUNCTION__, mac);
            return;
        }

        NetworkState *state = network.networkState;
        if (![state wasHashFetchedForAlmond:mac]) {
            [state markHashFetchedForAlmond:mac];

            DLog(@"%s: hash not checked on this connection: requesting hash for current almond: %@", __PRETTY_FUNCTION__, mac);
            GenericCommand *cmd = [self makeDeviceHashCommand:mac];
            [self asyncSendToCloud:cmd];
        }
        else {
            DLog(@"%s: hash already checked on this connection for current almond: %@", __PRETTY_FUNCTION__, mac);
        }
    }

    // Fetch the Almond Mode
    [self tryRequestAlmondMode:mac];

    // refresh notification preferences; currently, we cannot rely on receiving dynamic updates for these values and so always refresh.
    [self asyncRequestNotificationPreferenceList:mac];
}

- (BOOL)isCurrentTemperatureFormatFahrenheit {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [defaults boolForKey:kCURRENT_TEMPERATURE_FORMAT];
    return value;
}

- (void)setCurrentTemperatureFormatFahrenheit:(BOOL)format {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:format forKey:kCURRENT_TEMPERATURE_FORMAT];
    [defaults synchronize];
}

- (int)convertTemperatureToCurrentFormat:(int)temperature {
    if ([self isCurrentTemperatureFormatFahrenheit]) {
        return temperature;
    } else {
        return (int) lround((temperature - 32) / 1.8);
    }
}

- (NSString *)getTemperatureWithCurrentFormat:(int)temperature {
    if ([self isCurrentTemperatureFormatFahrenheit]) {
        return [NSString stringWithFormat:@"%d °F", temperature];
    } else {
        return [NSString stringWithFormat:@"%d °C", (int) lround((temperature - 32) / 1.8)];
    }
}

- (SFIAlmondPlus *)currentAlmond {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kPREF_CURRENT_ALMOND];
    if (data) {
        SFIAlmondPlus *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return object;
    }
    else {
        return nil;
    }
}

- (SFIAlmondPlus *)cloudAlmond:(NSString *)almondMac {
    return [self.dataManager readAlmond:almondMac];
}


- (NSArray *)almondList {
    return [self.dataManager readAlmondList];
}

- (BOOL)almondExists:(NSString *)almondMac {
    NSArray *list = [self almondList];
    for (SFIAlmondPlus *almond in list) {
        if ([almond.almondplusMAC isEqualToString:almondMac]) {
            return YES;
        }
    }

    return NO;
}

- (NSArray *)localLinkedAlmondList {
    if (!self.config.enableLocalNetworking) {
        return nil;
    }

    // Below is an important filtering process:
    // in effect, we choose to use the Cloud Almond representation for matching
    // local network configs, because the Almond#linkType property will indicate
    // the almond supports both local and cloud network connections. This will ensure the
    // UI can do the right thing and show the right message to the user when connection modes
    // are switched.
    //
    // Note for large lists of almonds, the way the data manger internally manages cloud almond lists
    // is inefficient for these sorts of operations, and a dictionary data structure would allow for
    // fast look up, instead of iteration.
    NSMutableSet *cloud_set = [NSMutableSet setWithArray:[self almondList]];

    NSDictionary *local_settings = [self.dataManager readAllAlmondLocalNetworkSettings];
    NSMutableArray *local_almonds = [NSMutableArray array];

    for (NSString *mac in local_settings.allKeys) {
        SFIAlmondPlus *localAlmond;

        for (SFIAlmondPlus *cloud in cloud_set) {
            if ([cloud.almondplusMAC isEqualToString:mac]) {
                localAlmond = cloud;
                [cloud_set removeObject:cloud];
                break;
            }
        }

        if (!localAlmond) {
            SFIAlmondLocalNetworkSettings *setting = local_settings[mac];
            localAlmond = setting.asLocalLinkAlmondPlus;
        }

        if (localAlmond) {
            [local_almonds addObject:localAlmond];
        }
    }

    if (local_almonds.count == 0) {
        return nil;
    }

    // Sort the local Almonds alphabetically
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"almondplusName" ascending:YES];
    [local_almonds sortUsingDescriptors:@[sort]];

    return local_almonds;
}

- (NSArray *)deviceList:(NSString *)almondMac {
    return [self.dataManager readDeviceList:almondMac];
}

- (NSArray *)deviceValuesList:(NSString *)almondMac {
    return [self.dataManager readDeviceValueList:almondMac];
}

- (NSArray *)notificationPrefList:(NSString *)almondMac {
    return [self.dataManager readNotificationPreferenceList:almondMac];
}

#pragma mark - Device and Device Value Management

- (void)asyncRequestDeviceList:(NSString *)almondMac {
    BOOL local = [self useLocalNetwork:almondMac];
    Network *network = local ? [self setupLocalNetworkForAlmond:almondMac] : self.cloudNetwork;

    NetworkState *state = network.networkState;
    if ([state willFetchDeviceListFetchedForAlmond:almondMac]) {
        return;
    }
    [state markWillFetchDeviceListForAlmond:almondMac];

    if (local) {
        GenericCommand *cmd = [GenericCommand websocketSensorDeviceListCommand];
        [network submitCommand:cmd];
    }
    else {
        GenericCommand *cmd = [GenericCommand cloudSensorDeviceListCommand:almondMac];
        [self asyncSendToCloud:cmd];
    }
}

- (void)asyncRequestDeviceValueList:(NSString *)almondMac {
    BOOL local = [self useLocalNetwork:almondMac];
    Network *network = local ? [self setupLocalNetworkForAlmond:almondMac] : self.cloudNetwork;

    NetworkState *state = network.networkState;
    [state markDeviceValuesFetchedForAlmond:almondMac];

    if (local) {
        GenericCommand *cmd = [GenericCommand websocketSensorDeviceValueListCommand];
        [network submitCommand:cmd];
    }
    else {
        GenericCommand *cmd = [GenericCommand cloudSensorDeviceValueListCommand:almondMac];
        [self asyncSendToCloud:cmd];
        [self asyncRequestNotificationPreferenceList:almondMac];
    }
}

- (BOOL)tryRequestDeviceValueList:(NSString *)almondMac {
    BOOL local = [self useLocalNetwork:almondMac];
    Network *network = local ? [self setupLocalNetworkForAlmond:almondMac] : self.cloudNetwork;

    NetworkState *state = network.networkState;
    if ([state wasDeviceValuesFetchedForAlmond:almondMac]) {
        return NO;
    }
    [state markDeviceValuesFetchedForAlmond:almondMac];

    [self asyncRequestDeviceValueList:almondMac];
    [self asyncRequestNotificationPreferenceList:almondMac];

    return YES;
}


#pragma mark - Scoreboard management

- (Scoreboard *)scoreboardSnapshot {
    return [self.scoreboard copy];
}

- (void)markCommandEvent:(CommandType)commandType {
    if (self.config.enableScoreboard) {
        CommandTypeScoreboardEvent *event = [[CommandTypeScoreboardEvent alloc] initWithCommandType:commandType];
        [self.scoreboard markEvent:event];
    }
}

#pragma mark - Almond commands

/*
 <root>
 <GenericCommandRequest>
 <AlmondplusMAC>251176214925585</AlmondplusMAC>
 <ApplicationID>1001</ApplicationID>
 <MobileInternalIndex>1</MobileInternalIndex>
 <Data>
 [Base64Encoded]
 <root><FirmwareUpdate Available="1/0"><Version>AP2-R070-L009-W016-ZW016-ZB005</Version></FirmwareUpdate></root>[Base64Encoded]
 </Data>
 </GenericCommandRequest>
 </root>
 */

- (sfi_id)asyncUpdateAlmondFirmware:(NSString *)almondMAC firmwareVersion:(NSString *)firmwareVersion {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    [writer startElement:@"root"];
    [writer startElement:@"FirmwareUpdate"];
    [writer addAttribute:@"Available" value:@"1"];
    [writer addElement:@"Version" text:firmwareVersion];
    [writer endElement];;
    [writer endElement];;

    GenericCommandRequest *request = [GenericCommandRequest new];
    request.almondMAC = almondMAC;
    request.data = [writer toString];

    GenericCommand *cmd = [[GenericCommand alloc] init];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];

    return request.correlationId;
}

- (sfi_id)asyncRebootAlmond:(NSString *)almondMAC {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    [writer startElement:@"root"];
    [writer addElement:@"Reboot" text:@"1"];
    [writer endElement];;

    GenericCommandRequest *request = [GenericCommandRequest new];
    request.almondMAC = almondMAC;
    request.data = [writer toString];

    GenericCommand *cmd = [[GenericCommand alloc] init];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];

    return request.correlationId;
}

/*
 <root>
	<GenericCommandRequest>
 <AlmondplusMAC>251176214925585</AlmondplusMAC>
 <ApplicationID>1001</ApplicationID>
 <MobileInternalIndex>1</MobileInternalIndex>
 <Data>
 [Base64Encoded]
 <root><SendLogs><Reason>Unable to get notification</Reason></SendLogs></root>[Base64Encoded]
 </Data>
	</GenericCommandRequest>
 </root>
 */
- (sfi_id)asyncSendAlmondLogs:(NSString *)almondMAC problemDescription:(NSString *)description {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    [writer startElement:@"root"];
    [writer startElement:@"SendLogs"];
    [writer addElement:@"Reason" text:description];
    [writer endElement];;
    [writer endElement];;

    GenericCommandRequest *request = [GenericCommandRequest new];
    request.almondMAC = almondMAC;
    request.data = [writer toString];

    GenericCommand *cmd = [[GenericCommand alloc] init];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];

    return request.correlationId;
}

#pragma mark - Account related commands

- (void)asyncRequestChangeCloudPassword:(NSString *)currentPwd changedPwd:(NSString *)changedPwd {
    ChangePasswordRequest *request = [ChangePasswordRequest new];
    request.emailID = [self loginEmail];
    request.currentPassword = currentPwd;
    request.changedPassword = changedPwd;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_CHANGE_PASSWORD_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeleteCloudAccount:(NSString *)password {
    DeleteAccountRequest *request = [DeleteAccountRequest new];
    request.emailID = [self loginEmail];
    request.password = password;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DELETE_ACCOUNT_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestUnlinkAlmond:(NSString *)almondMAC password:(NSString *)password {
    UnlinkAlmondRequest *request = [UnlinkAlmondRequest new];
    request.almondMAC = almondMAC;
    request.password = password;
    request.emailID = [self loginEmail];

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_UNLINK_ALMOND_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestInviteForSharingAlmond:(NSString *)almondMAC inviteEmail:(NSString *)inviteEmailID {
    UserInviteRequest *request = [UserInviteRequest new];
    request.almondMAC = almondMAC;
    request.emailID = inviteEmailID;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_USER_INVITE_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeleteSecondaryUser:(NSString *)almondMAC email:(NSString *)emailID {
    DeleteSecondaryUserRequest *request = [DeleteSecondaryUserRequest new];
    request.almondMAC = almondMAC;
    request.emailID = emailID;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DELETE_SECONDARY_USER_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeleteMeAsSecondaryUser:(NSString *)almondMAC {
    DeleteMeAsSecondaryUserRequest *request = [DeleteMeAsSecondaryUserRequest new];
    request.almondMAC = almondMAC;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DELETE_ME_AS_SECONDARY_USER_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestChangeAlmondName:(NSString *)changedAlmondName almondMAC:(NSString *)almondMAC {
    AlmondNameChange *request = [AlmondNameChange new];
    request.almondMAC = almondMAC;
    request.changedAlmondName = changedAlmondName;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ALMOND_NAME_CHANGE_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestMeAsSecondaryUser {
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ME_AS_SECONDARY_USER_REQUEST;
    cmd.command = [MeAsSecondaryUserRequest new];

    [self asyncSendToCloud:cmd];
}

#pragma mark - Almond and router settings

- (void)asyncAlmondStatusAndSettingsRequest:(NSString *)almondMac request:(enum SecurifiToolkitAlmondRouterRequest)requestType {
    if (almondMac.length == 0) {
        return;
    }

    [self internalRequestAlmondStatusAndSettings:almondMac command:requestType commandPrecondition:nil];
}

- (void)asyncAlmondSummaryInfoRequest:(NSString *)almondMac {
    if (almondMac.length == 0) {
        return;
    }

    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        GenericCommand *storedCmd = [aNetwork.networkState expirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:almondMac];
        if (!storedCmd) {
            [aNetwork.networkState markExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:almondMac genericCommand:aCmd];
            return YES;
        }
        return !storedCmd.isExpired;
    };

    // sends a series of requests to fetch all the information at once.
    // note ordering might be important to the UI layer, which for now receives the response payloads directly
    [self internalRequestAlmondStatusAndSettings:almondMac command:SecurifiToolkitAlmondRouterRequest_summary commandPrecondition:precondition];
}

- (void)internalJSONRequestAlmondWifiClients:(NSString *)almondMac {
    GenericCommand *cmd = [GenericCommand cloudRequestAlmondWifiClients:almondMac];
    [self asyncSendToCloud:cmd];
}

- (void)internalRequestAlmondStatusAndSettings:(NSString *)almondMac command:(enum SecurifiToolkitAlmondRouterRequest)type commandPrecondition:(NetworkPrecondition)precondition {
    if (self.config.enableLocalNetworking && type == SecurifiToolkitAlmondRouterRequest_wifi_clients) {
        BOOL local = [self useLocalNetwork:almondMac];

        if (local) {
            GenericCommand *cmd = [GenericCommand websocketRequestAlmondWifiClients];
            cmd.networkPrecondition = precondition;

            [self asyncSendToLocal:cmd almondMac:almondMac];

            return;
        }

        // else pass through
    }

    NSString *data;
    switch (type) {
        case SecurifiToolkitAlmondRouterRequest_summary:
            data = GET_WIRELESS_SUMMARY_COMMAND;
            break;
        case SecurifiToolkitAlmondRouterRequest_settings:
            data = GET_WIRELESS_SETTINGS_COMMAND;
            break;
        case SecurifiToolkitAlmondRouterRequest_connected_device:
            data = GET_CONNECTED_DEVICE_COMMAND;
            break;
        case SecurifiToolkitAlmondRouterRequest_blocked_device:
            data = GET_BLOCKED_DEVICE_COMMAND;
            break;
        case SecurifiToolkitAlmondRouterRequest_wifi_clients:
            // special case
            [self internalJSONRequestAlmondWifiClients:almondMac];
            return;
    }

    GenericCommandRequest *request = [GenericCommandRequest new];
    request.almondMAC = almondMac;
    request.applicationID = APPLICATION_ID;
    request.data = data;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = request;
    cmd.networkPrecondition = precondition;

    [self asyncSendToCloud:cmd];
}

- (sfi_id)asyncUpdateAlmondWirelessSettings:(NSString *)almondMAC wirelessSettings:(SFIWirelessSetting *)settings {
    GenericCommand *cmd = [GenericCommand cloudUpdateWirelessSettings:settings almondMac:almondMAC];
    [self asyncSendToCloud:cmd];

    return cmd.correlationId;
}

#pragma mark - Notification Preferences and Almond mode changes

- (void)asyncRequestRegisterForNotification:(NSString *)deviceToken {
    if (deviceToken == nil) {
        SLog(@"asyncRequestRegisterForNotification : device toke is nil");
        return;
    }

    if ([self isSecApnTokenRegistered]) {
        NSString *oldToken = [self secRegisteredApnToken];
        if ([deviceToken isEqualToString:oldToken]) {
            // already registered
            return;
        }
    }
    [self setSecRegisteredApnToken:deviceToken];

    NotificationRegistration *req = [NotificationRegistration new];
    req.regID = deviceToken;
    req.platform = @"iOS";

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_REGISTRATION;
    cmd.command = req;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeregisterForNotification {
    if (![self isSecApnTokenRegistered]) {
        SLog(@"asyncRequestRegisterForNotification : no device token to deregister");
        return;
    }

    NSString *deviceToken = [self secRegisteredApnToken];
    if (deviceToken == nil) {
        SLog(@"asyncRequestRegisterForNotification : device toke is nil");
        return;
    }

    NotificationDeleteRegistrationRequest *req = [NotificationDeleteRegistrationRequest new];
    req.regID = deviceToken;
    req.platform = @"iOS";

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_DEREGISTRATION;
    cmd.command = req;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestNotificationPreferenceList:(NSString *)almondMAC {
    if (almondMAC == nil) {
        SLog(@"asyncRequestRegisterForNotification : almond MAC is nil");
        return;
    }

    NotificationPreferenceListRequest *req = [NotificationPreferenceListRequest new];
    req.almondplusMAC = almondMAC;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST;
    cmd.command = req;

    [self asyncSendToCloud:cmd];
}

- (sfi_id)asyncRequestAlmondModeChange:(NSString *)almondMac mode:(SFIAlmondMode)newMode {
    if (almondMac == nil) {
        SLog(@"asyncRequestAlmondModeChange : almond MAC is nil");
        return 0;
    }

    NSString *userId = [self loginEmail];

    // A closure that will be invoked whne the command is submitted for processing and that
    // will store the requested almond mode for future reference. When a positive response is
    // received, the new mode will be confirmed and locked in.
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        [aNetwork.networkState markPendingModeForAlmond:almondMac mode:newMode];
        return YES;
    };

    BOOL local = [self useLocalNetwork:almondMac];
    if (local) {
        GenericCommand *cmd = [GenericCommand websocketChangeAlmondMode:newMode userId:userId almondMac:almondMac];
        cmd.networkPrecondition = precondition;

        [self asyncSendToLocal:cmd almondMac:almondMac];

        return cmd.correlationId;
    }
    else {
        GenericCommand *cmd = [GenericCommand cloudChangeAlmondMode:newMode userId:userId almondMac:almondMac];
        cmd.networkPrecondition = precondition;

        [self asyncSendToCloud:cmd];

        return cmd.correlationId;
    }
}

- (SFIAlmondMode)modeForAlmond:(NSString *)almondMac {
    return [self tryCachedAlmondModeValue:almondMac];
}

- (SFIAlmondMode)tryCachedAlmondModeValue:(NSString *)almondMac {
    Network *network = self.cloudNetwork ? self.cloudNetwork : self.localNetwork;
    if (network) {
        return [network.networkState almondMode:almondMac];
    }

    return SFIAlmondMode_unknown;
}

// Checks whether a Mode has already been fetched for the almond, and if so, fails quietly.
// Otherwise, it requests the mode information.
- (void)tryRequestAlmondMode:(NSString *)almondMac {
    if (almondMac == nil) {
        return;
    }

    SFIAlmondMode mode = [self tryCachedAlmondModeValue:almondMac];
    if (mode != SFIAlmondMode_unknown) {
        // a valid value already exists
        return;
    }

    AlmondModeRequest *req = [AlmondModeRequest new];
    req.almondMAC = almondMac;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ALMOND_MODE_REQUEST;
    cmd.command = req;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestNotificationPreferenceChange:(NSString *)almondMAC deviceList:(NSArray *)deviceList forAction:(NSString *)action {
    if (almondMAC == nil) {
        SLog(@"asyncRequestRegisterForNotification : almond MAC is nil");
        return;
    }

    NotificationPreferences *req = [NotificationPreferences new];
    req.action = action;
    req.almondMAC = almondMAC;
    req.userID = [self loginEmail];
    req.preferenceCount = (int) [deviceList count];
    req.notificationDeviceList = deviceList;

    // Use this as a state holder so we can get access to the actual NotificationPreferences when processing the response.
    // This is a work-around measure until cloud dynamic updates are working; we keep track of the last mode change request and
    // update internal state on receipt of a confirmation from the cloud; normally, we would rely on the
    // dynamic update to inform us of actual new state.
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        [aNetwork.networkState markExpirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification" genericCommand:aCmd];
        return YES;
    };

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_PREF_CHANGE_REQUEST;
    cmd.command = req;
    cmd.networkPrecondition = precondition;

    [self asyncSendToCloud:cmd];
}

#pragma mark - Command constructors

- (GenericCommand *)makeCloudSanityCommand {
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_CLOUD_SANITY;
    cmd.command = nil;
    return cmd;
}

- (GenericCommand *)makeTempPassLoginCommand {
    LoginTempPass *req = [LoginTempPass new];
    req.UserID = [self secUserId];
    req.TempPass = [self secPassword];

    GenericCommand *command = [GenericCommand new];
    command.commandType = CommandType_LOGIN_COMMAND; // use Login command type
    command.command = req;

    return command;
}

- (GenericCommand *)makeAlmondListCommand {
    GenericCommand *command = [GenericCommand new];
    command.commandType = CommandType_ALMOND_LIST;
    command.command = [AlmondListRequest new];
    return command;
}

- (GenericCommand *)makeDeviceHashCommand:(NSString *)almondMac {
    DeviceDataHashRequest *req = [DeviceDataHashRequest new];
    req.almondMAC = almondMac;

    GenericCommand *command = [GenericCommand new];
    command.commandType = CommandType_DEVICE_DATA_HASH;
    command.command = req;

    return command;
}

#pragma mark - Keychain Access

- (BOOL)hasLoginCredentials {
    // Keychains persist after an app is deleted. Therefore, to ensure credentials are "wiped out",
    // we keep track of whether this is a new install by storing a value in user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL logged_in_once = [defaults boolForKey:kPREF_USER_DEFAULT_LOGGED_IN_ONCE];

    return logged_in_once && [self hasSecEmail] && [self hasSecPassword];
}

- (void)clearSecCredentials {
    [KeyChainWrapper removeEntryForUserEmail:SEC_EMAIL forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_PWD forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_USER_ID forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_APN_TOKEN forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_IS_ACCOUNT_ACTIVATED forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT forService:SEC_SERVICE_NAME];
}

- (BOOL)hasSecPassword {
    return [KeyChainWrapper isEntryStoredForUserEmail:SEC_PWD forService:SEC_SERVICE_NAME];
}

- (BOOL)hasSecEmail {
    return [KeyChainWrapper isEntryStoredForUserEmail:SEC_EMAIL forService:SEC_SERVICE_NAME];
}

- (NSString *)secEmail {
    if (![self hasSecEmail]) {
        return nil;
    }
    return [KeyChainWrapper retrieveEntryForUser:SEC_EMAIL forService:SEC_SERVICE_NAME];
}

- (void)setSecEmail:(NSString *)email {
    [KeyChainWrapper createEntryForUser:SEC_EMAIL entryValue:email forService:SEC_SERVICE_NAME];
}

- (NSString *)secPassword {
    if (![self hasSecPassword]) {
        return nil;
    }
    return [KeyChainWrapper retrieveEntryForUser:SEC_PWD forService:SEC_SERVICE_NAME];
}

- (void)setSecPassword:(NSString *)pwd {
    [KeyChainWrapper createEntryForUser:SEC_PWD entryValue:pwd forService:SEC_SERVICE_NAME];
}

- (NSString *)secUserId {
    return [KeyChainWrapper retrieveEntryForUser:SEC_USER_ID forService:SEC_SERVICE_NAME];
}

- (void)setSecUserId:(NSString *)userId {
    [KeyChainWrapper createEntryForUser:SEC_USER_ID entryValue:userId forService:SEC_SERVICE_NAME];
}

//PY: 101014 - Not activated accounts can be accessed for 7 days
- (BOOL)secIsAccountActivated {
    NSString *value = [KeyChainWrapper retrieveEntryForUser:SEC_IS_ACCOUNT_ACTIVATED forService:SEC_SERVICE_NAME];
    if (value == nil) {
        return YES;
    }
    return [value boolValue];
}

- (void)setSecAccountActivationStatus:(BOOL)isActivated {
    NSNumber *num = @(isActivated);
    [KeyChainWrapper createEntryForUser:SEC_IS_ACCOUNT_ACTIVATED entryValue:[num stringValue] forService:SEC_SERVICE_NAME];
}

- (NSUInteger)secMinsRemainingForUnactivatedAccount {
    NSString *value = [KeyChainWrapper retrieveEntryForUser:SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT forService:SEC_SERVICE_NAME];
    if (value.length == 0) {
        return 0;
    }

    NSInteger mins = value.integerValue;
    return (NSUInteger) mins;
}

- (void)setSecMinsRemainingForUnactivatedAccount:(NSUInteger)minsRemaining {
    NSNumber *num = @(minsRemaining);
    [KeyChainWrapper createEntryForUser:SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT entryValue:[num stringValue] forService:SEC_SERVICE_NAME];
}

- (BOOL)isSecApnTokenRegistered {
    return [KeyChainWrapper isEntryStoredForUserEmail:SEC_APN_TOKEN forService:SEC_SERVICE_NAME];
}

- (NSString *)secRegisteredApnToken {
    return [KeyChainWrapper retrieveEntryForUser:SEC_APN_TOKEN forService:SEC_SERVICE_NAME];
}

- (void)setSecRegisteredApnToken:(NSString *)token {
    if (token == nil) {
        return;
    }
    [KeyChainWrapper createEntryForUser:SEC_APN_TOKEN entryValue:token forService:SEC_SERVICE_NAME];
}

#pragma mark - Network management

- (Network *)setupCloudNetwork {
    NSLog(@"Setting up cloud network");

    [self tearDownCloudNetwork];

    NetworkConfig *networkConfig = [NetworkConfig cloudConfig:self.config useProductionHost:self.useProductionCloud];

    Network *network = [Network networkWithNetworkConfig:networkConfig callbackQueue:self.networkCallbackQueue dynamicCallbackQueue:self.networkDynamicCallbackQueue];
    network.delegate = self;

    _cloudNetwork = network;

    [network connect];

    return network;
}

- (Network *)setupLocalNetworkForAlmond:(NSString *)almondMac {
    Network *network = self.localNetwork;

    if ([self isCurrentLocalNetworkForAlmond:almondMac]) {
        NetworkConnectionStatus state = [self networkStatus:network];
        switch (state) {
            case NetworkConnectionStatusInitializing:
            case NetworkConnectionStatusInitialized:
                return network;
            case NetworkConnectionStatusUninitialized:
            case NetworkConnectionStatusShutdown:
                // pass through and set up connection
                break;
        }
    }

    [self tearDownLocalNetwork];

    SFIAlmondLocalNetworkSettings *settings = [self localNetworkSettingsForAlmond:almondMac];

    NetworkConfig *config = [NetworkConfig webSocketConfig:almondMac];
    config.host = settings.host;
    config.port = settings.port;
    config.password = settings.password;

    network = [Network networkWithNetworkConfig:config callbackQueue:self.networkCallbackQueue dynamicCallbackQueue:self.networkDynamicCallbackQueue];
    network.delegate = self;

    _localNetwork = network;

    [network connect];

    return network;
}

- (void)tearDownCloudNetwork {
    Network *old = self.cloudNetwork;

    if (old) {
        NSLog(@"Starting tear down of cloud network");

        old.delegate = nil; // no longer interested in callbacks from this instance
        [old shutdown];

        self.cloudNetwork = nil;

        NSLog(@"Finished tear down of cloud network");
    }
}

- (void)tearDownLocalNetwork {
    Network *old = self.localNetwork;

    if (old) {
        NSLog(@"Starting tear down of local network");

        old.delegate = nil; // no longer interested in callbacks from this instance
        [old shutdown];

        self.localNetwork = nil;

        NSLog(@"Finished tear down of local network");
    }
}

// internal function used by high-level command dispatch methods for branching on local or cloud command queue
- (BOOL)useLocalNetwork:(NSString *)almondMac {
    if (!self.config.enableLocalNetworking) {
        return NO;
    }

    // if in cloud mode, then fail fast
    if (![self isCurrentConnectionModeCompatible:SFIAlmondConnectionMode_local]) {
        return NO;
    }

    // if network is set up, make sure it is for the specified almond
    Network *local = self.localNetwork;
    if (local) {
        NSString *mac = local.config.almondMac;
        return mac && [mac isEqualToString:almondMac];
    }

    // if network not set up then check that settings are complete; the network will be set up on calling
    // asyncSubmitLocal command.
    //todo need a fast cache for this; very expensive to hit the file system constantly
    SFIAlmondLocalNetworkSettings *settings = [self localNetworkSettingsForAlmond:almondMac];
    return settings.hasCompleteSettings;
}

- (BOOL)isCurrentLocalNetworkForAlmond:(NSString *)almondMac {
    if (!self.config.enableLocalNetworking) {
        return NO;
    }

    Network *network = self.localNetwork;
    if (!network) {
        return NO;
    }

    NetworkConfig *config = network.config;
    return [config.almondMac isEqualToString:almondMac];
}

#pragma mark - NetworkDelegate methods

- (void)networkConnectionDidEstablish:(Network *)network {
    if (network == self.cloudNetwork) {
        self.scoreboard.connectionCount++;
    }
}

- (void)networkConnectionDidClose:(Network *)network {
    if (network == self.cloudNetwork) {
        self.cloudNetwork = nil;
        DLog(@"%s: posting NETWORK_DOWN_NOTIFIER on closing cloud connection", __PRETTY_FUNCTION__);
    }
    else if (network == self.localNetwork) {
        self.localNetwork = nil;
        DLog(@"%s: posting NETWORK_DOWN_NOTIFIER on closing local connection", __PRETTY_FUNCTION__);
    }

    [self postNotification:NETWORK_DOWN_NOTIFIER data:nil];
}

- (void)networkDidSendCommand:(Network *)network command:(GenericCommand *)command {
    if (network == self.cloudNetwork) {
        self.scoreboard.commandRequestCount++;
        [self markCommandEvent:command.commandType];
    }
}

- (void)networkDidReceiveDynamicUpdate:(Network *)network commandType:(enum CommandType)commandType {
    if (network == self.cloudNetwork) {
        self.scoreboard.dynamicUpdateCount++;
        [self markCommandEvent:commandType];
    }
}

- (void)networkDidReceiveCommandResponse:(Network *)network command:(GenericCommand *)cmd timeToCompletion:(NSTimeInterval)roundTripTime responseType:(enum CommandType)commandType {
    if (network == self.cloudNetwork) {
        self.scoreboard.commandResponseCount++;
        [self markCommandEvent:commandType];
    }

    id p_cmd = cmd.command;
    if ([p_cmd isKindOfClass:[MobileCommandRequest class]]) {
        NSDictionary *payload = @{
                @"command" : p_cmd,
                @"timing" : @(roundTripTime)
        };
        [self postNotification:kSFIDidCompleteMobileCommandRequest data:payload];
    }

    DLog(@"Command completion: cmd:%@, %0.3f secs", cmd, roundTripTime);
}

#pragma mark - Internal Command Dispatch and Notification

- (BOOL)internalInitializeCloud:(Network *)network command:(GenericCommand *)command {
    return [network submitCloudInitializationCommand:command];
}

- (void)postNotification:(NSString *)notificationName data:(id)payload {
    // An interesting behavior: notifications are posted mainly to the UI. There is an assumption built into the system that
    // the notifications are posted synchronously from the SDK. Change the dispatch queue to async, and the
    // UI can easily become confused. This needs to be sorted out.

    __weak id block_payload = payload;

    dispatch_sync(self.networkCallbackQueue, ^() {
        NSDictionary *data = nil;
        if (payload) {
            data = @{@"data" : block_payload};
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:data];
    });
}

#pragma mark - Almond Updates

- (void)onAlmondListResponse:(id)sender {
    NSLog(@"Received Almond list response");

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        [self.cloudNetwork markCloudInitialized];
        return;
    }

    AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        [self.cloudNetwork markCloudInitialized];
        return;
    }

    NSArray *almondList = obj.almondPlusMACList;

    // Store the new list
    [self.dataManager writeAlmondList:almondList];

    // Ensure Current Almond is consistent with new list
    SFIAlmondPlus *plus = [self manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];

    // After requesting the Almond list, we then want to get additional info
    [self asyncInitializeConnection2:self.cloudNetwork];

    // Tell the world
    [self postNotification:kSFIDidUpdateAlmondList data:plus];
}

- (void)onDynamicAlmondListAdd:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        return;
    }

    NSArray *almondList = obj.almondPlusMACList;

    // Store the new list
    [self.dataManager writeAlmondList:almondList];

    // Ensure Current Almond is consistent with new list
    SFIAlmondPlus *plus = [self manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:YES];

    // Tell the world that this happened
    [self postNotification:kSFIDidUpdateAlmondList data:plus];
}

- (void)onDynamicAlmondListDelete:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        return;
    }

    NSArray *newAlmondList = @[];
    for (SFIAlmondPlus *deleted in obj.almondPlusMACList) {
        // remove cached data about the Almond and sensors
        newAlmondList = [self.dataManager deleteAlmond:deleted];

        if (self.config.enableNotifications) {
            // clear out Notification settings
            Network *network = self.cloudNetwork;
            if (network) {
                [self.cloudNetwork.networkState clearAlmondMode:deleted.almondplusMAC];
            }

            [self.notificationsDb deleteNotificationsForAlmond:deleted.almondplusMAC];
        }
    }

    // Ensure Current Almond is consistent with new list
    SFIAlmondPlus *plus = [self manageCurrentAlmondOnAlmondListUpdate:newAlmondList manageCurrentAlmondChange:YES];

    [self postNotification:kSFIDidUpdateAlmondList data:plus];
}

- (void)onDynamicAlmondNameChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DynamicAlmondNameChangeResponse *obj = (DynamicAlmondNameChangeResponse *) [data valueForKey:@"data"];
    if (obj == nil) {
        return;
    }

    NSString *almondName = obj.almondplusName;
    if (almondName.length == 0) {
        return;
    }

    SFIAlmondPlus *changed = [self.dataManager changeAlmondName:almondName almondMac:obj.almondplusMAC];
    if (changed) {
        SFIAlmondPlus *current = [self currentAlmond];
        if ([current isEqualAlmondPlus:changed]) {
            changed.colorCodeIndex = current.colorCodeIndex;
            [self setCurrentAlmond:changed];
        }

        // Tell the world so they can update their view
        [self postNotification:kSFIDidChangeAlmondName data:changed];
    }
}

// When the cloud almond list is changed, ensure the Current Almond setting is consistent with the list.
// This method has side-effects and can change settings.
// Returns the current Almond, which might or might not be the same as the old one. May return nil.
- (SFIAlmondPlus *)manageCurrentAlmondOnAlmondListUpdate:(NSArray *)almondList manageCurrentAlmondChange:(BOOL)doManage {
    // if current is "local only" then no need to inspect the almond list; just return the current one.
    SFIAlmondPlus *current = [self currentAlmond];
    if (current.linkType == SFIAlmondPlusLinkType_local_only) {
        return current;
    }

    // Manage the "Current selected Almond" value
    if (almondList.count == 0) {
        [self purgeStoredData];
        return nil;
    }
    else if (almondList.count == 1) {
        SFIAlmondPlus *currentAlmond = almondList[0];
        if (doManage) {
            [self setCurrentAlmond:currentAlmond];
        }
        else {
            [self writeCurrentAlmond:currentAlmond];
        }
        return currentAlmond;
    }
    else {
        if (current) {
            for (SFIAlmondPlus *almond in almondList) {
                if ([almond.almondplusMAC isEqualToString:current.almondplusMAC]) {
                    // Current one is still in list, so leave it as current.
                    return almond;
                }
            }
        }

        // Current one is not in new list.
        // Just pick the first one in this case
        SFIAlmondPlus *currentAlmond = almondList[0];
        if (doManage) {
            [self setCurrentAlmond:currentAlmond];
        }
        else {
            [self writeCurrentAlmond:currentAlmond];
        }
        return currentAlmond;
    }
}

#pragma mark - Generic Almond Router commmand callbacks

- (void)onAlmondRouterGenericNotification:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    GenericCommandResponse *response = (GenericCommandResponse *) [data valueForKey:@"data"];
    NSString *mac = response.almondMAC;

    Network *network = [data valueForKey:@"network"];
    [network.networkState clearExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:mac];

    if (!response.isSuccessful) {
        SFIGenericRouterCommand *routerCommand = [SFIGenericRouterCommand new];
        routerCommand.almondMAC = mac;
        routerCommand.commandSuccess = NO;
        routerCommand.responseMessage = response.reason;

        [self postNotification:kSFIDidReceiveGenericAlmondRouterResponse data:routerCommand];
    }
    else {
        SFIGenericRouterCommand *routerCommand = [RouterCommandParser parseRouterResponse:response];
        routerCommand.almondMAC = mac;

        [self internalOnGenericRouterCommandResponse:routerCommand];
    }
}

- (void)onAlmondRouterGenericCommandResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    GenericCommandResponse *response = (GenericCommandResponse *) [data valueForKey:@"data"];
    NSString *mac = response.almondMAC;

    Network *network = [data valueForKey:@"network"];
    [network.networkState clearExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:mac];

    SFIGenericRouterCommand *routerCommand = [RouterCommandParser parseRouterResponse:response];
    routerCommand.almondMAC = mac;

    [self internalOnGenericRouterCommandResponse:routerCommand];
}

- (void)onAlmondRouterCommandResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    SFIGenericRouterCommand *response = (SFIGenericRouterCommand *) [data valueForKey:@"data"];
    NSString *mac = response.almondMAC;

    Network *network = [data valueForKey:@"network"];
    [network.networkState clearExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:mac];

    [self internalOnGenericRouterCommandResponse:response];
}

- (void)internalOnGenericRouterCommandResponse:(SFIGenericRouterCommand *)routerCommand {
    if (routerCommand == nil) {
        return;
    }

    if (routerCommand.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
        // after receiving summary, we update the local wireless connection settings with the current login/password
        SFIRouterSummary *summary = (SFIRouterSummary *) routerCommand.command;
        [self tryUpdateLocalNetworkSettingsForAlmond:routerCommand.almondMAC withRouterSummary:summary];
    }

    [self postNotification:kSFIDidReceiveGenericAlmondRouterResponse data:routerCommand];
}

#pragma mark - Device List Update callbacks

- (void)onDeviceHashResponse:(id)sender {
    NSLog(@"Received Almond hash response");

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceDataHashResponse *response = (DeviceDataHashResponse *) [data valueForKey:@"data"];
    NSString *reportedHash = response.almondHash;
    if (!response.isSuccessful) {
        // We assume, on failure, the Almond is no longer associated with this account and
        // our list of Almonds is out of date. Therefore, issue a request for the Almond list.
        NSLog(@"Device hash response failed; requesting Almond list");

        SFIAlmondPlus *currentAlmond = [self currentAlmond];
        if (currentAlmond.linkType == SFIAlmondPlusLinkType_cloud_local) {
            [self removeCurrentAlmond];

            GenericCommand *cmd = [self makeAlmondListCommand];
            [self asyncSendToCloud:cmd];
        }

        return;
    }

    SFIAlmondPlus *currentAlmond = [self currentAlmond];
    if (currentAlmond == nil) {
        NSLog(@"Device Hash Response failed: No current Almond");
        return;
    }

    NSString *currentMac = currentAlmond.almondplusMAC;
    NSString *storedHash = [self.dataManager readHashList:currentMac];

    if (reportedHash.length == 0 || [reportedHash isEqualToString:@"null"]) {
        //Hash sent by cloud as null - No Device
        NSLog(@"Device Hash Response: null; request devices");
        [self asyncRequestDeviceList:currentMac];
    }
    else if (storedHash.length > 0 && currentMac.length > 0 && [storedHash isEqualToString:reportedHash]) {
        // Devices list is fresh. Update the device values.
        NSLog(@"Device Hash Response: matched; request values");
        [self tryRequestDeviceValueList:currentMac];
    }
    else {
        //Save hash in file for each almond
        NSLog(@"Device Hash Response: mismatch; requesting devices; mac:%@, current:%@, stored:%@", currentMac, reportedHash, storedHash);
        [self.dataManager writeHashList:reportedHash almondMac:currentMac];
        // and update the device list -- on receipt of the device list, then the values will be updated
        [self asyncRequestDeviceList:currentMac];
    }
}

- (void)onDynamicDeviceListChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceListResponse *obj = (DeviceListResponse *) [data valueForKey:@"data"];

    [self.cloudNetwork.networkState clearWillFetchDeviceListForAlmond:obj.almondMAC];

    if (!obj.isSuccessful) {
        return;
    }

    NSString *almondMAC = obj.almondMAC;
    NSMutableArray *newDeviceList = obj.deviceList;

    [self processDeviceListChange:newDeviceList mac:almondMAC requestValues:YES partialList:NO];
    [self postNotification:kSFIDidChangeDeviceList data:almondMAC];
}

- (void)onDeviceListResponse:(id)sender {
    NSLog(@"Received device list response");

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceListResponse *obj = (DeviceListResponse *) [data valueForKey:@"data"];

    NSString *mac = obj.almondMAC;

    [self.cloudNetwork.networkState clearWillFetchDeviceListForAlmond:mac];

    if (!obj.isSuccessful) {
        NSLog(@"Device list response was not successful; stopping");
        return;
    }

    NSArray *newDevices = obj.deviceList;

    // values not included in response, so request them
    BOOL requestValues = (obj.deviceValueList == nil);
    [self processDeviceListChange:newDevices mac:mac requestValues:requestValues partialList:NO];
    [self postNotification:kSFIDidChangeDeviceList data:mac];
}

- (void)onDeviceListAndValuesResponse:(id)sender {
    NSLog(@"Received device list response");

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceListResponse *res = (DeviceListResponse *) [data valueForKey:@"data"];

    [self.cloudNetwork.networkState clearWillFetchDeviceListForAlmond:res.almondMAC];

    if (!res.isSuccessful) {
        NSLog(@"Device list response was not successful; stopping");
        return;
    }

    NSString *mac = res.almondMAC;

    const BOOL partialList = res.updatedDevicesOnly;

    switch (res.type) {
        case DeviceListResponseType_updated: {
            NSArray *deviceList = res.deviceList;
            NSArray *valueList = res.deviceValueList;

            if (valueList) {
                [self processDeviceListChange:deviceList mac:mac requestValues:NO partialList:partialList];
                [self processDeviceValueList:valueList mac:mac];
                [self postNotification:kSFIDidChangeDeviceList data:mac];
            }
            else {
                // values not included in response, so request them
                [self processDeviceListChange:deviceList mac:mac requestValues:YES partialList:partialList];
                [self postNotification:kSFIDidChangeDeviceList data:mac];
            }

            break;
        };
        case DeviceListResponseType_added: {
            NSArray *current = [self.dataManager readDeviceList:mac];
            for (SFIDevice *device in res.deviceList) {
                current = [SFIDevice addDevice:device list:current];
            }

            [self processDeviceListChange:current mac:mac requestValues:YES partialList:NO];
            [self postNotification:kSFIDidChangeDeviceList data:mac];

            break;
        };
        case DeviceListResponseType_removed: {
            NSArray *current = [self.dataManager readDeviceList:mac];
            for (SFIDevice *device in res.deviceList) {
                current = [SFIDevice removeDevice:device list:current];
            }

            [self processDeviceListChange:current mac:mac requestValues:YES partialList:NO];
            [self postNotification:kSFIDidChangeDeviceList data:mac];

            break;
        };
        case DeviceListResponseType_removed_all: {
            [self.dataManager removeAllDevices:mac];
            [self postNotification:kSFIDidChangeDeviceList data:mac];
            break;
        }
    }
}

// Processes device lists received in dynamic and on-demand updates.
// After storing the new list, a notification is posted and an updated values list is requested
- (void)processDeviceListChange:(NSArray *)changedDevices mac:(NSString *)mac requestValues:(BOOL)requestValues partialList:(BOOL)partialList {
    if (partialList) {
        // mix in the devices with the new ones
        NSArray *devices = [self.dataManager readDeviceList:mac];

        if (devices) {
            NSMutableArray *new_list = [NSMutableArray array];
            for (SFIDevice *device in devices) {
                BOOL foundDevice = NO;

                for (SFIDevice *newDevice in changedDevices) {
                    if (device.deviceID == newDevice.deviceID) {
                        // then update
                        foundDevice = YES;
                        [new_list addObject:newDevice];
                        break;
                    }
                }

                if (!foundDevice) {
                    [new_list addObject:device];
                }
            }

            changedDevices = new_list;
        }
    }

    [self.dataManager writeDeviceList:changedDevices almondMac:mac];

    if (requestValues) {
        // Request values for devices
        [self asyncRequestDeviceValueList:mac];
    }
}

#pragma mark - Device Value Update callbacks

- (void)onDynamicDeviceValueListChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceValueResponse *obj = (DeviceValueResponse *) [data valueForKey:@"data"];
    NSString *almondMac = obj.almondMAC;

    [self processDeviceValueList:obj.deviceValueList mac:almondMac];
}

- (void)onDeviceValueListChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceValueResponse *obj = (DeviceValueResponse *) [data valueForKey:@"data"];
    NSString *almondMac = obj.almondMAC;

    if (almondMac.length == 0) {
        return;
    }

    // Update offline storage
    [self.dataManager writeDeviceValueList:obj.deviceValueList almondMac:almondMac];

    [self postNotification:kSFIDidChangeDeviceValueList data:almondMac];
}

// Processes a dynamic change to a device value
- (void)processDeviceValueList:(NSArray *)newDeviceValues mac:(NSString *)currentMAC {
    if (currentMAC.length == 0) {
        return;
    }

    NSArray *currentDeviceValueList = [self.dataManager readDeviceValueList:currentMAC];

    NSMutableArray *newDeviceValueList;
    if (currentDeviceValueList != nil) {
        for (SFIDeviceValue *currentValue in currentDeviceValueList) {
            for (SFIDeviceValue *cloudValue in newDeviceValues) {
                if (currentValue.deviceID == cloudValue.deviceID) {
                    cloudValue.isPresent = YES;

                    NSArray *currentValues = [currentValue knownDevicesValues];
                    NSArray *cloudValues = [cloudValue knownDevicesValues];

                    for (SFIDeviceKnownValues *currentMobileKnownValue in currentValues) {
                        for (SFIDeviceKnownValues *currentCloudKnownValue in cloudValues) {
                            if (currentMobileKnownValue.index == currentCloudKnownValue.index) {
                                currentMobileKnownValue.value = currentCloudKnownValue.value;
                                break;
                            }
                        }
                    }

                    [currentValue replaceKnownDeviceValues:currentValues];
                }
            }
        }

        newDeviceValueList = [NSMutableArray arrayWithArray:currentDeviceValueList];

        // Traverse the list and add the new value to offline list
        // If there are new values without corresponding devices, we know to request the device list.
        BOOL isDeviceMissing = NO;
        if (newDeviceValues.count > 0 && currentDeviceValueList.count == 0) {
            isDeviceMissing = YES;
        }
        else {
            for (SFIDeviceValue *currentCloudValue in newDeviceValues) {
                if (!currentCloudValue.isPresent) {
                    [newDeviceValueList addObject:currentCloudValue];
                    isDeviceMissing = YES;
                }
            }
        }

        if (isDeviceMissing) {
            NSLog(@"Missing devices for values. Requesting device hash for %@", currentMAC);
            GenericCommand *command = [self makeDeviceHashCommand:currentMAC];
            [self asyncSendToCloud:command];
        }

        // replace the list given to us with the combined new list
        newDeviceValues = newDeviceValueList;
    }

    // Update offline storage
    [self.dataManager writeDeviceValueList:newDeviceValues almondMac:currentMAC];

    [self postNotification:kSFIDidChangeDeviceValueList data:currentMAC];
}


#pragma mark - Notification Preference List callbacks

- (void)onDeviceNotificationPreferenceChangeResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NotificationPreferenceResponse *res = data[@"data"];
    if (!res.isSuccessful) {
        return;
    }

    Network *network = data[@"network"];
    GenericCommand *cmd = [network.networkState expirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification"];
    NotificationPreferences *req = cmd.command;
    if (!req) {
        return;
    }

    int res_correlationId = res.internalIndex.intValue;
    if (res_correlationId != req.correlationId) {
        NSLog(@"Unable to process NotificationPreferenceResponse: correlation IDs do not match, expected:'%u', received:'%@'", req.correlationId, res.internalIndex);
        return;
    }

    NSString *almondMac = req.almondMAC;
    NSArray *currentPrefs = [self notificationPrefList:almondMac];

    NSArray *newPrefs;
    if ([req.action isEqualToString:kSFINotificationPreferenceChangeActionAdd]) {
        newPrefs = [SFINotificationDevice addNotificationDevices:req.notificationDeviceList to:currentPrefs];
    }
    else if ([req.action isEqualToString:kSFINotificationPreferenceChangeActionDelete]) {
        newPrefs = [SFINotificationDevice removeNotificationDevices:req.notificationDeviceList from:currentPrefs];
    }
    else {
        NSLog(@"Unable to process NotificationPreferenceResponse: action is not recognized, action:'%@'", req.action);
        [network.networkState clearExpirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification"];
        return;
    }

    [self.dataManager writeNotificationPreferenceList:newPrefs almondMac:almondMac];

    [network.networkState clearExpirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification"];
    [self postNotification:kSFINotificationPreferencesDidChange data:almondMac];
}

- (void)onNotificationRegistrationResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NotificationRegistrationResponse *obj = (NotificationRegistrationResponse *) [data valueForKey:@"data"];

    NSString *notification;
    switch (obj.responseType) {
        case NotificationRegistrationResponseType_success:
            notification = kSFIDidRegisterForNotifications;
            break;
        case NotificationRegistrationResponseType_alreadyRegistered:
            notification = kSFIDidRegisterForNotifications;
            break;
        case NotificationRegistrationResponseType_failedToRegister:
        default:
            notification = kSFIDidFailToRegisterForNotifications;
            break;
    }

    [self postNotification:notification data:nil];
}

- (void)onNotificationDeregistrationResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NotificationDeleteRegistrationResponse *obj = (NotificationDeleteRegistrationResponse *) [data valueForKey:@"data"];
    NSString *notification = obj.isSuccessful ? kSFIDidDeregisterForNotifications : kSFIDidFailToDeregisterForNotifications;
    [self postNotification:notification data:nil];
}

- (void)onNotificationPrefListChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NotificationPreferenceListResponse *obj = (NotificationPreferenceListResponse *) [data valueForKey:@"data"];
    NSString *currentMAC = obj.almondMAC;

    if (currentMAC.length == 0) {
        return;
    }

    if ([obj.notificationDeviceList count] != 0) {
        // Update offline storage
        [self.dataManager writeNotificationPreferenceList:obj.notificationDeviceList almondMac:currentMAC];
        [self postNotification:kSFINotificationPreferencesDidChange data:currentMAC];
    }
}

- (void)onDynamicNotificationPrefListChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DynamicNotificationPreferenceList *obj = (DynamicNotificationPreferenceList *) [data valueForKey:@"data"];
    NSString *currentMAC = obj.almondMAC;

    if (currentMAC.length == 0) {
        return;
    }

    // Get the email id of current user
    NSString *loggedInUser = [self loginEmail];

    // Get the notification list of that current user from offline storage
    NSMutableArray *notificationPrefUserList = obj.notificationUserList;

    NSArray *notificationList = obj.notificationUserList;
    for (SFINotificationUser *currentUser in notificationPrefUserList) {
        if ([currentUser.userID isEqualToString:loggedInUser]) {
            notificationList = currentUser.notificationDeviceList;
            break;
        }
    }

    // Update offline storage
    [self.dataManager writeNotificationPreferenceList:notificationList almondMac:currentMAC];
    [self postNotification:kSFINotificationPreferencesDidChange data:currentMAC];
}

- (void)onNotificationListSyncResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NotificationListResponse *res = data[@"data"];
    NSString *requestId = res.requestId;

    Network *network = data[@"network"];

    DLog(@"asyncRefreshNotifications: recevied request id:'%@'", requestId);

    // Remove the guard preventing more refresh notifications
    if (requestId.length == 0) {
        // note: we are only tracking "refresh" requests to prevent more than one of them to be processed at a time.
        // these requests are not the same as "catch up" requests for older sync points that were queued for fetching
        // but not downloaded; see internalTryProcessNotificationSyncPoints.
        NSLog(@"asyncRefreshNotifications: clearing refresh request tracking");
        [network.networkState clearExpirableRequest:ExpirableCommandType_notificationListRequest namespace:@"notification"];
    }

    // Store the notifications and stop tracking the pageState that they were associated with
    //
    // As implemented, iteration will continue until a duplicate notification is detected. This procedure
    // ensures that if the system is missing some notifications, it will catch up eventually.
    // Notifications are delivered newest to oldest, making it likely all new ones are fetched in the first call.
    DatabaseStore *store = self.notificationsDb;

    NSUInteger newCount = res.newCount;
    NSArray *notificationsToStore = res.notifications;
    NSUInteger totalCount = notificationsToStore.count;

    // Set viewed state:
    // for new notifications...
    NSUInteger rangeEnd = newCount > totalCount ? totalCount : newCount;
    NSRange newNotificationRange = NSMakeRange(0, rangeEnd);
    for (SFINotification *notification in [notificationsToStore subarrayWithRange:newNotificationRange]) {
        notification.viewed = NO;
    }
    // for old notifications...
    NSUInteger rangeEnd_final = totalCount - rangeEnd;
    NSRange oldNotificationRange = NSMakeRange(rangeEnd, rangeEnd_final);
    for (SFINotification *notification in [notificationsToStore subarrayWithRange:oldNotificationRange]) {
        notification.viewed = YES;
    }

    NSInteger storedCount = [store storeNotifications:notificationsToStore syncPoint:requestId];
    BOOL allStored = (storedCount == totalCount);

    if (allStored) {
        DLog(@"asyncRefreshNotifications: stored:%li", (long) totalCount);
    }
    else {
        DLog(@"asyncRefreshNotifications: stored partial notifications:%li of %li", (long) storedCount, (long) totalCount);
    }

    if (storedCount == 0) {
        [self setNotificationsBadgeCount:newCount];

        // check whether there is queued work to be done
        [self internalTryProcessNotificationSyncPoints];

        // if nothing stored, then no need to tell the world
        return;
    }

    if (!allStored) {
        // stopped early
        // nothing more to do
        [self setNotificationsBadgeCount:newCount];

        // Let the world know there are new notifications
        [self postNotification:kSFINotificationDidStore data:nil];

        // check whether there is queued work to be done
        [self internalTryProcessNotificationSyncPoints];

        return;
    }

    // Let the world know there are new notifications
    [self postNotification:kSFINotificationDidStore data:nil];

    // Keep syncing until page state is no longer provided
    if (res.isPageStateDefined) {
        // There are more pages to fetch
        NSString *nextPageState = res.pageState;

        // Guard against bug in Cloud sending back same page state, causing us to go into infinite loop
        // requesting the same page over and over.
        BOOL alreadyTracked = [store isTrackedSyncPoint:nextPageState];
        if (alreadyTracked) {
            // remove the state and halt further processing
            [store removeSyncPoint:nextPageState];

            NSLog(@"Already tracking sync point; halting further processing: %@", nextPageState);
        }
        else {
            // Keep track of this page state until the response has been processed
            [store trackSyncPoint:nextPageState];

            // and try to download it now
            [self internalAsyncFetchNotifications:nextPageState];
        }
    }
    else {
        [self setNotificationsBadgeCount:newCount];

        // check whether there is queued work to be done
        [self internalTryProcessNotificationSyncPoints];
    }
}

// Check whether there are page states in the data store that need to be fetched.
// This could happen when the app is halted or connections break before a previous
// run completed fetching all pages.
- (void)internalTryProcessNotificationSyncPoints {
    DatabaseStore *store = self.notificationsDb;

    NSInteger count = store.countTrackedSyncPoints;
    if (count == 0) {
        return;
    }

    DLog(@"internalTryProcessNotificationSyncPoints: queued sync points: %li", (long) count);

    NSString *nextPageState = [store nextTrackedSyncPoint];
    if (nextPageState.length > 0) {
        DLog(@"internalTryProcessNotificationSyncPoints: fetching sync point: %@", nextPageState);
        [self internalAsyncFetchNotifications:nextPageState];
    }
}

- (void)onNotificationCountResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NSLog(@"onNotificationCountResponse: clearing request tracking");

    NotificationCountResponse *res = data[@"data"];
    if (res.error) {
        NSLog(@"onNotificationCountResponse: error response");
        return;
    }

    // Store the notifications and stop tracking the pageState that they were associated with
    [self setNotificationsBadgeCount:res.badgeCount];

    if (res.badgeCount > 0) {
        [self tryRefreshNotifications];
    }
}

- (void)onNotificationClearCountResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NSLog(@"onNotificationClearCountResponse: clearing request tracking");

    NotificationClearCountResponse *res = data[@"data"];
    if (res.error) {
        NSLog(@"onNotificationClearCountResponse: error response");
    }
    else {
        DLog(@"onNotificationClearCountResponse: success");
    }
}

#pragma mark - Notification access and refresh commands

- (NSInteger)countUnviewedNotifications {
    if (!self.config.enableNotifications) {
        return 0;
    }
    return [self.notificationsStore countUnviewedNotifications];
}

- (id <SFINotificationStore>)newNotificationStore {
    return [self.notificationsDb newNotificationStore];
}

- (BOOL)copyNotificationStoreTo:(NSString *)filePath {
    if (!self.config.enableNotifications) {
        return NO;
    }
    return [self.notificationsDb copyDatabaseTo:filePath];
}

// this method sends a request to fetch the latest notifications;
// it does not handle the case of fetching older ones
- (void)tryRefreshNotifications {
    if (!self.config.enableNotifications) {
        return;
    }

    if (!self.isCloudLoggedIn) {
        return;
    }

    [self internalAsyncFetchNotifications:nil];
}

// sends a command to clear the notification count
- (void)tryClearNotificationCount {
    if (!self.config.enableNotifications) {
        return;
    }

    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        enum ExpirableCommandType type = ExpirableCommandType_notificationClearCountRequest;
        NSString *aNamespace = @"notification";

        GenericCommand *storedCmd = [aNetwork.networkState expirableRequest:type namespace:aNamespace];
        if (storedCmd) {
            // clear the lock after execution; next command invocation will be allowed
            [aNetwork.networkState clearExpirableRequest:type namespace:aNamespace];
            // give the request 5 seconds to complete
            return !storedCmd.isExpired;
        }
        else {
            [aNetwork.networkState markExpirableRequest:type namespace:aNamespace genericCommand:aCmd];
            return YES;
        }
    };

    // reset count internally
    [self setNotificationsBadgeCount:0];

    // send the command to the cloud
    NotificationClearCountRequest *req = [NotificationClearCountRequest new];

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = req.commandType;
    cmd.command = req;
    cmd.networkPrecondition = precondition;

    [self asyncSendToCloud:cmd];
}

- (NSInteger)notificationsBadgeCount {
    if (!self.config.enableNotifications) {
        return 0;
    }

    return self.notificationsDb.badgeCount;
}

- (void)setNotificationsBadgeCount:(NSInteger)count {
    if (!self.config.enableNotifications) {
        return;
    }

    if (!self.isCloudLoggedIn) {
        return;
    }

    [self.notificationsDb storeBadgeCount:count];
    [self postNotification:kSFINotificationBadgeCountDidChange data:nil];
}

// Sends a request for notifications
// pagestate can be nil or a defined page state. The page state also becomes an correlation ID that is parroted back in the
// response. This allows the system to track responses and ensure page states are always serviced, even across app sessions.
- (void)internalAsyncFetchNotifications:(NSString *)pageState {
    if (!self.config.enableNotifications) {
        return;
    }

    NotificationListRequest *req = [NotificationListRequest new];
    req.pageState = pageState;
    req.requestId = pageState;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATIONS_SYNC_REQUEST;
    cmd.command = req;

    // nil indicates request is for "refresh; get latest" request
    if (pageState == nil) {
        cmd.networkPrecondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
            GenericCommand *storedCmd = [aNetwork.networkState expirableRequest:ExpirableCommandType_notificationListRequest namespace:@"notification"];
            if (!storedCmd) {
                [aNetwork.networkState markExpirableRequest:ExpirableCommandType_notificationListRequest namespace:@"notification" genericCommand:aCmd];
                return YES;
            }
            // give the request 5 seconds to complete
            return !storedCmd.isExpired;
        };

        NSLog(@"asyncRefreshNotifications: tracking refresh request");
    }

    [self asyncSendToCloud:cmd];
}

#pragma mark - Almond Mode change callbacks

- (void)onAlmondModeChangeCompletion:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    AlmondModeChangeResponse *res = [data valueForKey:@"data"];
    if (!res.success) {
        return;
    }

    Network *network = [data valueForKey:@"network"];
    [network.networkState confirmPendingModeForAlmond];

    NSString *notification = kSFIDidCompleteAlmondModeChangeRequest;
    [self postNotification:notification data:nil];
}

- (void)onAlmondModeResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    AlmondModeResponse *res = [data valueForKey:@"data"];
    if (res == nil) {
        return;
    }

    if (!res.success) {
        return;
    }

    [self.cloudNetwork.networkState markModeForAlmond:res.almondMAC mode:res.mode];
    [self postNotification:kSFIAlmondModeDidChange data:res];
}

- (void)onDynamicAlmondModeChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DynamicAlmondModeChange *res = [data valueForKey:@"data"];
    if (res == nil) {
        return;
    }

    if (!res.success) {
        return;
    }

    Network *network = [data valueForKey:@"network"];

    [network.networkState markModeForAlmond:res.almondMAC mode:res.mode];
    [self postNotification:kSFIAlmondModeDidChange data:res];
}

#pragma mark - Device Log processing and SFIDeviceLogStoreDelegate methods

- (id <SFINotificationStore>)newDeviceLogStore:(NSString *)almondMac deviceId:(sfi_id)deviceId {
    DatabaseStore *db = self.deviceLogsDb;
    [db purgeAll];

    id <SFIDeviceLogStore> store = [db newDeviceLogStore:almondMac deviceId:deviceId delegate:self];
    [store ensureFetchNotifications]; // will callback to self (registered as delegate) to load notifications

    [self.cloudNetwork.networkState clearExpirableRequest:ExpirableCommandType_deviceLogRequest namespace:almondMac];

    return store;
}

- (void)tryRefreshDeviceLog:(NSString *)almondMac deviceId:(sfi_id)deviceId {
    /*
     Mobile +++++++++>>>>  Cloud 804
     [For the first time send for first logs]
     <root>
     {mac:201243434454, device_id:19, requestId:”dajdasj”’}
     </root>
     [subsequent command]
     <root>
     {mac:201243434454, device_id:19, requestId:”dajdasj”, pageState:”12aaa12eee2eeffb1024”}
     </root>
     */

    // track timeouts/guard against multiple requests being sent for device logs
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        GenericCommand *storedCmd = [aNetwork.networkState expirableRequest:ExpirableCommandType_deviceLogRequest namespace:almondMac];
        if (!storedCmd) {
            [aNetwork.networkState markExpirableRequest:ExpirableCommandType_deviceLogRequest namespace:almondMac genericCommand:aCmd];
            return YES;
        }
        // give the request 5 seconds to complete
        return !storedCmd.isExpired;
    };

    DatabaseStore *store = self.deviceLogsDb;
    NSString *pageState = [store nextTrackedSyncPoint];

    NSDictionary *payload = pageState ? @{
            @"mac" : almondMac,
            @"device_id" : @(deviceId),
            @"requestId" : pageState,
            @"pageState" : pageState,
    } : @{
            @"mac" : almondMac,
            @"device_id" : @(deviceId),
            @"requestId" : almondMac,
    };

    [self internalSendJsonCommandToCloud:payload commandType:CommandType_DEVICELOG_REQUEST precondition:precondition];
}

- (void)deviceLogStoreTryFetchRecords:(id <SFIDeviceLogStore>)deviceLogStore {
    [self tryRefreshDeviceLog:deviceLogStore.almondMac deviceId:deviceLogStore.deviceID];
}

- (void)onDeviceLogSyncResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NotificationListResponse *res = data[@"data"];
    NSString *requestId = res.requestId;

    // Store the notifications and stop tracking the pageState that they were associated with
    DatabaseStore *store = self.deviceLogsDb;

    NSArray *notificationsToStore = res.notifications;
    for (SFINotification *n in notificationsToStore) {
        n.viewed = YES;
    }

    [store storeNotifications:notificationsToStore syncPoint:requestId];

    // Let the world know there are new notifications
    [self postNotification:kSFINotificationDidStore data:nil];

    // Keep syncing until page state is no longer provided
    if (res.isPageStateDefined) {
        // There are more pages to fetch
        NSString *nextPageState = res.pageState;

        // Guard against bug in Cloud sending back same page state, causing us to go into infinite loop
        // requesting the same page over and over.
        BOOL alreadyTracked = [store isTrackedSyncPoint:nextPageState];
        if (alreadyTracked) {
            // remove the state and halt further processing
            [store removeSyncPoint:nextPageState];

            DLog(@"Already tracking sync point; halting further processing: %@", nextPageState);
        }
        else {
            // Keep track of this page state until the response has been processed
            [store trackSyncPoint:nextPageState];
        }
    }
}

#pragma mark - JSON command helper

- (void)internalSendJsonCommandToCloud:(NSDictionary *)payload commandType:(enum CommandType)commandType precondition:(NetworkPrecondition)precondition {
    GenericCommand *cmd = [GenericCommand jsonPayloadCommand:payload commandType:commandType];
    cmd.networkPrecondition = precondition;

    if (cmd) {
        [self asyncSendToCloud:cmd];
    }
}

@end

