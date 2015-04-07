//
//  SecurifiToolkit.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SingleTon.h"
#import "LoginTempPass.h"
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
#import "AlmondModeChangeRequest.h"
#import "DynamicAlmondModeChange.h"
#import "AlmondModeRequest.h"
#import "AlmondModeResponse.h"
#import "AlmondModeChangeResponse.h"
#import "NotificationPreferenceResponse.h"
#import "NotificationListRequest.h"
#import "NotificationListResponse.h"
#import "NotificationCountRequest.h"
#import "NotificationCountResponse.h"


#define kPREF_CURRENT_ALMOND                                @"kAlmondCurrent"
#define kPREF_USER_DEFAULT_LOGGED_IN_ONCE                   @"kLoggedInOnce"

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
NSString *const kSFIDidChangeAlmondName = @"kSFIDidChangeAlmondName";
NSString *const kSFIDidCompleteAlmondModeChangeRequest = @"kSFIDidCompleteAlmondChangeRequest";
NSString *const kSFIAlmondModeDidChange = @"kSFIAlmondModeDidChange";
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

@interface CommandTypeEvent : NSObject <ScoreboardEvent>
@property(readonly) CommandType commandType;

- (instancetype)initWithCommandType:(CommandType)commandType;
@end

@implementation CommandTypeEvent

- (instancetype)initWithCommandType:(CommandType)commandType {
    self = [super init];
    if (self) {
        _commandType = commandType;
    }

    return self;
}

- (NSString *)label {
    return [CommandTypeEvent nameForType:self.commandType];
}

+ (NSString *)nameForType:(CommandType)type {
    switch (type) {
        case CommandType_LOGIN_COMMAND:
            return [NSString stringWithFormat:@"LOGIN_COMMAND_%d", type];
        case CommandType_LOGIN_RESPONSE:
            return [NSString stringWithFormat:@"LOGIN_RESPONSE_%d", type];
        case CommandType_LOGOUT_COMMAND:
            return [NSString stringWithFormat:@"LOGOUT_COMMAND_%d", type];
        case CommandType_LOGOUT_ALL_COMMAND:
            return [NSString stringWithFormat:@"LOGOUT_ALL_COMMAND_%d", type];
        case CommandType_LOGOUT_ALL_RESPONSE:
            return [NSString stringWithFormat:@"LOGOUT_ALL_RESPONSE_%d", type];
        case CommandType_SIGNUP_COMMAND:
            return [NSString stringWithFormat:@"SIGNUP_COMMAND_%d", type];
        case CommandType_SIGNUP_RESPONSE:
            return [NSString stringWithFormat:@"SIGNUP_RESPONSE_%d", type];
        case CommandType_VALIDATE_REQUEST:
            return [NSString stringWithFormat:@"VALIDATE_REQUEST_%d", type];
        case CommandType_VALIDATE_RESPONSE:
            return [NSString stringWithFormat:@"VALIDATE_RESPONSE_%d", type];
        case CommandType_RESET_PASSWORD_REQUEST:
            return [NSString stringWithFormat:@"RESET_PASSWORD_REQUEST_%d", type];
        case CommandType_RESET_PASSWORD_RESPONSE:
            return [NSString stringWithFormat:@"RESET_PASSWORD_RESPONSE_%d", type];
        case CommandType_LOGOUT_RESPONSE:
            return [NSString stringWithFormat:@"LOGOUT_RESPONSE_%d", type];
        case CommandType_AFFILIATION_CODE_REQUEST:
            return [NSString stringWithFormat:@"AFFILIATION_CODE_REQUEST_%d", type];
        case CommandType_AFFILIATION_USER_COMPLETE:
            return [NSString stringWithFormat:@"AFFILIATION_USER_COMPLETE_%d", type];
        case CommandType_ALMOND_LIST:
            return [NSString stringWithFormat:@"ALMOND_LIST_%d", type];
        case CommandType_ALMOND_LIST_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_LIST_RESPONSE_%d", type];
        case CommandType_DEVICE_DATA_HASH:
            return [NSString stringWithFormat:@"DEVICE_DATA_HASH_%d", type];
        case CommandType_DEVICE_DATA_HASH_RESPONSE:
            return [NSString stringWithFormat:@"DEVICE_DATA_HASH_RESPONSE_%d", type];
        case CommandType_DEVICE_DATA:
            return [NSString stringWithFormat:@"DEVICE_DATA_%d", type];
        case CommandType_DEVICE_DATA_RESPONSE:
            return [NSString stringWithFormat:@"DEVICE_DATA_RESPONSE_%d", type];
        case CommandType_DEVICE_VALUE:
            return [NSString stringWithFormat:@"DEVICE_VALUE_%d", type];
        case CommandType_DEVICE_VALUE_LIST_RESPONSE:
            return [NSString stringWithFormat:@"DEVICE_VALUE_LIST_RESPONSE_%d", type];
        case CommandType_MOBILE_COMMAND:
            return [NSString stringWithFormat:@"MOBILE_COMMAND_%d", type];
        case CommandType_MOBILE_COMMAND_RESPONSE:
            return [NSString stringWithFormat:@"MOBILE_COMMAND_RESPONSE_%d", type];
        case CommandType_DYNAMIC_DEVICE_DATA:
            return [NSString stringWithFormat:@"DYNAMIC_DEVICE_DATA_%d", type];
        case CommandType_DYNAMIC_DEVICE_VALUE_LIST:
            return [NSString stringWithFormat:@"DYNAMIC_DEVICE_VALUE_LIST_%d", type];
        case CommandType_DYNAMIC_ALMOND_ADD:
            return [NSString stringWithFormat:@"DYNAMIC_ALMOND_ADD_%d", type];
        case CommandType_DYNAMIC_ALMOND_DELETE:
            return [NSString stringWithFormat:@"DYNAMIC_ALMOND_DELETE_%d", type];
        case CommandType_DYNAMIC_ALMOND_NAME_CHANGE:
            return [NSString stringWithFormat:@"DYNAMIC_ALMOND_NAME_CHANGE_%d", type];
        case CommandType_LOGIN_TEMPPASS_COMMAND:
            return [NSString stringWithFormat:@"LOGIN_TEMPPASS_COMMAND_%d", type];
        case CommandType_CLOUD_SANITY:
            return [NSString stringWithFormat:@"CLOUD_SANITY_%d", type];
        case CommandType_CLOUD_SANITY_RESPONSE:
            return [NSString stringWithFormat:@"CLOUD_SANITY_RESPONSE_%d", type];
        case CommandType_KEEP_ALIVE:
            return [NSString stringWithFormat:@"KEEP_ALIVE_%d", type];
        case CommandType_GENERIC_COMMAND_REQUEST:
            return [NSString stringWithFormat:@"GENERIC_COMMAND_REQUEST_%d", type];
        case CommandType_GENERIC_COMMAND_RESPONSE:
            return [NSString stringWithFormat:@"GENERIC_COMMAND_RESPONSE_%d", type];
        case CommandType_GENERIC_COMMAND_NOTIFICATION:
            return [NSString stringWithFormat:@"GENERIC_COMMAND_NOTIFICATION_%d", type];
//        case CommandType_SENSOR_CHANGE_REQUEST:
//            return [NSString stringWithFormat:@"SENSOR_CHANGE_REQUEST_%d", type];
//        case CommandType_SENSOR_CHANGE_RESPONSE:
//            return [NSString stringWithFormat:@"SENSOR_CHANGE_RESPONSE_%d", type];
        case CommandType_DEVICE_DATA_FORCED_UPDATE_REQUEST:
            return [NSString stringWithFormat:@"DEVICE_DATA_FORCED_UPDATE_REQUEST_%d", type];
        case CommandType_ALMOND_NAME_CHANGE_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_NAME_CHANGE_REQUEST_%d", type];
        case CommandType_ALMOND_NAME_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_NAME_CHANGE_RESPONSE_%d", type];
        case CommandType_ALMOND_MODE_CHANGE_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_MODE_CHANGE_REQUEST_%d", type];
        case CommandType_ALMOND_MODE_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_MODE_CHANGE_RESPONSE_%d", type];
        case CommandType_CHANGE_PASSWORD_REQUEST:
            return [NSString stringWithFormat:@"CHANGE_PASSWORD_REQUEST_%d", type];
        case CommandType_CHANGE_PASSWORD_RESPONSE:
            return [NSString stringWithFormat:@"CHANGE_PASSWORD_RESPONSE_%d", type];
        case CommandType_DELETE_ACCOUNT_REQUEST:
            return [NSString stringWithFormat:@"DELETE_ACCOUNT_REQUEST_%d", type];
        case CommandType_DELETE_ACCOUNT_RESPONSE:
            return [NSString stringWithFormat:@"DELETE_ACCOUNT_RESPONSE_%d", type];
        case CommandType_USER_INVITE_REQUEST:
            return [NSString stringWithFormat:@"USER_INVITE_REQUEST_%d", type];
        case CommandType_USER_INVITE_RESPONSE:
            return [NSString stringWithFormat:@"USER_INVITE_RESPONSE_%d", type];
        case CommandType_ALMOND_AFFILIATION_DATA_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_AFFILIATION_DATA_REQUEST_%d", type];
        case CommandType_ALMOND_AFFILIATION_DATA_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_AFFILIATION_DATA_RESPONSE_%d", type];
        case CommandType_USER_PROFILE_REQUEST:
            return [NSString stringWithFormat:@"USER_PROFILE_REQUEST_%d", type];
        case CommandType_USER_PROFILE_RESPONSE:
            return [NSString stringWithFormat:@"USER_PROFILE_RESPONSE_%d", type];
        case CommandType_UPDATE_USER_PROFILE_REQUEST:
            return [NSString stringWithFormat:@"UPDATE_USER_PROFILE_REQUEST_%d", type];
        case CommandType_UPDATE_USER_PROFILE_RESPONSE:
            return [NSString stringWithFormat:@"UPDATE_USER_PROFILE_RESPONSE_%d", type];
        case CommandType_ME_AS_SECONDARY_USER_REQUEST:
            return [NSString stringWithFormat:@"ME_AS_SECONDARY_USER_REQUEST_%d", type];
        case CommandType_ME_AS_SECONDARY_USER_RESPONSE:
            return [NSString stringWithFormat:@"ME_AS_SECONDARY_USER_RESPONSE_%d", type];
        case CommandType_DELETE_SECONDARY_USER_REQUEST:
            return [NSString stringWithFormat:@"DELETE_SECONDARY_USER_REQUEST_%d", type];
        case CommandType_DELETE_SECONDARY_USER_RESPONSE:
            return [NSString stringWithFormat:@"DELETE_SECONDARY_USER_RESPONSE_%d", type];
        case CommandType_DELETE_ME_AS_SECONDARY_USER_REQUEST:
            return [NSString stringWithFormat:@"DELETE_ME_AS_SECONDARY_USER_REQUEST_%d", type];
        case CommandType_DELETE_ME_AS_SECONDARY_USER_RESPONSE:
            return [NSString stringWithFormat:@"DELETE_ME_AS_SECONDARY_USER_RESPONSE_%d", type];
        case CommandType_UNLINK_ALMOND_REQUEST:
            return [NSString stringWithFormat:@"UNLINK_ALMOND_REQUEST_%d", type];
        case CommandType_UNLINK_ALMOND_RESPONSE:
            return [NSString stringWithFormat:@"UNLINK_ALMOND_RESPONSE_%d", type];
        case CommandType_NOTIFICATION_PREF_CHANGE_REQUEST:
            return [NSString stringWithFormat:@"NOTIFICATION_PREF_CHANGE_REQUEST_%d", type];
        case CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATION_PREF_CHANGE_RESPONSE_%d", type];
        case CommandType_NOTIFICATION_REGISTRATION:
            return [NSString stringWithFormat:@"NOTIFICATION_REGISTRATION_%d", type];
        case CommandType_NOTIFICATION_REGISTRATION_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATION_REGISTRATION_RESPONSE_%d", type];
        case CommandType_NOTIFICATION_DEREGISTRATION:
            return [NSString stringWithFormat:@"NOTIFICATION_DEREGISTRATION_%d", type];
        case CommandType_NOTIFICATION_DEREGISTRATION_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATION_DEREGISTRATION_RESPONSE_%d", type];
        case CommandType_DYNAMIC_NOTIFICATION_PREFERENCE_LIST:
            return [NSString stringWithFormat:@"DYNAMIC_NOTIFICATION_PREFERENCE_LIST_%d", type];
        case CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST:
            return [NSString stringWithFormat:@"NOTIFICATION_PREFERENCE_LIST_REQUEST_%d", type];
        case CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATION_PREFERENCE_LIST_RESPONSE_%d", type];
        case CommandType_DYNAMIC_ALMOND_MODE_CHANGE:
            return [NSString stringWithFormat:@"DYNAMIC_ALMOND_MODE_CHANGE_%d", type];
        case CommandType_SENSOR_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"SENSOR_CHANGE_RESPONSE_%d", type];
        case CommandType_ALMOND_MODE_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_MODE_REQUEST_%d", type];
        case CommandType_ALMOND_MODE_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_MODE_RESPONSE_%d", type];

        case CommandType_NOTIFICATIONS_SYNC_REQUEST:
            return [NSString stringWithFormat:@"NOTIFICATIONS_SYNC_REQUEST_%d", type];
        case CommandType_NOTIFICATIONS_SYNC_RESPONSE:
            return [NSString stringWithFormat:@"NOTIFICATIONS_SYNC_RESPONSE_%d", type];

        default: {
            return [NSString stringWithFormat:@"Unknown_%d", type];
        }
    }
}

@end

// ===============================================================================================

@interface SecurifiToolkit () <SingleTonDelegate>
@property(nonatomic, readonly) SecurifiConfigurator *config;
@property(nonatomic, readonly) SFIReachabilityManager *cloudReachability;
@property(nonatomic, readonly) SFIOfflineDataManager *dataManager;
@property(nonatomic, readonly) DatabaseStore *databaseStore;
@property(nonatomic, readonly) id <SFINotificationStore> notificationsStore;
@property(nonatomic, readonly) Scoreboard *scoreboard;
@property(nonatomic, readonly) dispatch_queue_t socketCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t socketDynamicCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t commandDispatchQueue;
@property(nonatomic, weak) SingleTon *networkSingleton;
@property(atomic) BOOL isShutdown;

// a work-around measure until cloud dynamic updates are working; we keep track of the last mode change request and
// update internal state on receipt of a confirmation from the cloud; normally, we would rely on the
// dynamic update to inform us of actual new state.
@property(nonatomic, strong) AlmondModeChangeRequest *pendingAlmondModeChange;
@property(nonatomic, strong) NotificationPreferences *pendingNotificationPreferenceChange;

// tracks only "refresh" request to get new ones
@property(nonatomic, strong) NotificationListRequest *pendingRefreshNotificationsRequest;
@property(nonatomic, strong) NotificationCountRequest *pendingNotificationCountRequest;

@property(nonatomic, strong) BaseCommandRequest *pendingAlmondStateAndSettingsRequest;
@end

@implementation SecurifiToolkit

#pragma mark - Lifecycle methods

static SecurifiToolkit *singleton = nil;

+ (void)initialize:(SecurifiConfigurator *)config {
    static dispatch_once_t once_predicate;

    dispatch_once(&once_predicate, ^{
        singleton = [[SecurifiToolkit alloc] initWithConfig:config];
    });
}

+ (BOOL)isInitialized {
    return singleton != nil;
}

+ (instancetype)sharedInstance {
    return singleton;
}

- (instancetype)initWithConfig:(SecurifiConfigurator *)config {
    self = [super init];
    if (self) {
        _config = [config copy];

        _scoreboard = [Scoreboard new];
        _dataManager = [SFIOfflineDataManager new];

        if (config.enableNotifications) {
            _databaseStore = [DatabaseStore new];
            [_databaseStore setup];
            _notificationsStore = [_databaseStore newStore];
        }

        // default; do not change
        [self setupReachability:config.productionCloudHost];
        self.useProductionCloud = YES;

        _socketCallbackQueue = dispatch_queue_create("socket_callback", DISPATCH_QUEUE_CONCURRENT);
        _socketDynamicCallbackQueue = dispatch_queue_create("socket_dynamic_callback", DISPATCH_QUEUE_CONCURRENT);
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

        [center addObserver:self selector:@selector(onDynamicDeviceListChange:) name:DYNAMIC_DEVICE_DATA_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceListResponse:) name:DEVICE_DATA_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onDynamicDeviceValueListChange:) name:DYNAMIC_DEVICE_VALUE_LIST_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceValueListChange:) name:DEVICE_VALUE_LIST_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onAlmondListResponse:) name:ALMOND_LIST_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceHashResponse:) name:DEVICEDATA_HASH_NOTIFIER object:nil];

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
        }
    }

    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma mark - SDK state

- (BOOL)isCloudConnecting {
    BOOL reachable = [self isReachable];
    if (!reachable) {
        return NO;
    }

    SDKCloudStatus state = [self getConnectionState];
    return state == SDKCloudStatusInitializing;
}

- (BOOL)isCloudOnline {
    BOOL reachable = [self isReachable];
    if (!reachable) {
        return NO;
    }

    SDKCloudStatus state = [self getConnectionState];

    switch (state) {
        case SDKCloudStatusNotLoggedIn:
        case SDKCloudStatusLoginInProcess:
        case SDKCloudStatusLoggedIn:
        case SDKCloudStatusInitialized:
            return YES;

        case SDKCloudStatusUninitialized:
        case SDKCloudStatusInitializing:
        case SDKCloudStatusNetworkDown:
        case SDKCloudStatusCloudConnectionShutdown:
            return NO;

        default:
            return NO;
    }
}

- (BOOL)isReachable {
    return [self.cloudReachability isReachable];
}

- (BOOL)isLoggedIn {
    SingleTon *singleton = self.networkSingleton;
    return singleton && singleton.isLoggedIn;
}

- (BOOL)isAccountActivated {
    return [self secIsAccountActivated];
}

- (int)minsRemainingForUnactivatedAccount {
    return (int) [self secMinsRemainingForUnactivatedAccount];
}

- (SDKCloudStatus)getConnectionState {
    SingleTon *singleTon = self.networkSingleton;
    if (singleTon) {
        return [singleTon connectionState];
    }
    else {
        return SDKCloudStatusUninitialized;
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
    [self _asyncInitToolkit];
}

- (void)_asyncInitToolkit {
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

        SDKCloudStatus state = [block_self getConnectionState];
        switch (state) {
            case SDKCloudStatusNotLoggedIn:
            case SDKCloudStatusLoginInProcess:
            case SDKCloudStatusLoggedIn:
            case SDKCloudStatusInitialized: {
                DLog(@"INIT SDK. Connection established already. Returning.");
                return;
            };

            case SDKCloudStatusInitializing: {
                DLog(@"INIT SDK. Already initializing. Returning.");
                return;
            };

            case SDKCloudStatusUninitialized:
            case SDKCloudStatusNetworkDown:
            case SDKCloudStatusCloudConnectionShutdown:
            default: {
                DLog(@"INIT SDK. Connection needs establishment. Passing thru");
            };
        }

        NSLog(@"INIT SDK");

        SingleTon *singleTon = [block_self setupNetworkSingleton];

        // After setting up the network, we need to do some basic things
        // 1. send sanity cmd to test the socket
        // 2. logon
        // 3. update the devices list
        // 4. check hashes etc.

        GenericCommand *cmd;
        BOOL cmdSendSuccess;

        // Send sanity command testing network connection
        cmd = [block_self makeCloudSanityCommand];
        cmdSendSuccess = [block_self internalInitializeCloud:singleTon command:cmd];
        if (!cmdSendSuccess) {
            NSLog(@"%s: init SDK: send sanity failed:", __PRETTY_FUNCTION__);
            singleTon.connectionState = SDKCloudStatusNetworkDown;
            return;
        }

        DLog(@"%s: init SDK: send sanity successful", __PRETTY_FUNCTION__);
        DLog(@"%s: session started: %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());

        // If no logon credentials, then initialization is completed.
        if (![block_self hasLoginCredentials]) {
            DLog(@"%s: no logon credentials", __PRETTY_FUNCTION__);
            singleTon.connectionState = SDKCloudStatusNotLoggedIn;
            [singleTon markCloudInitialized];

            // This event is very important because it will prompt the UI not to wait for events and immediately show a logon screen
            // We probably should track things down and find a way to remove a dependency on this event in the UI.
            [block_self postNotification:kSFIDidLogoutNotification data:nil];
            return;
        }

        // Send logon credentials
        singleTon.connectionState = SDKCloudStatusLoginInProcess;

        DLog(@"%s: sending temp pass credentials", __PRETTY_FUNCTION__);
        cmd = [block_self makeTempPassLoginCommand];
        cmdSendSuccess = [block_self internalInitializeCloud:singleTon command:cmd];
        if (!cmdSendSuccess) {
            DLog(@"%s: failed on sending login command", __PRETTY_FUNCTION__);
            singleTon.connectionState = SDKCloudStatusNetworkDown;
        }

        // Request updates to the almond; See onLoginResponse handler for logic handling first-time login and follow-on requests.
        [block_self asyncInitializeConnection1:singleTon];
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

    dispatch_async(self.socketCallbackQueue, ^(void) {
        [block_self tearDownNetworkSingleton];
    });
}

- (void)debugUpdateConfiguration:(SecurifiConfigurator *)configurator {
    _config = configurator.copy;
}

// Invokes post-connection set-up and login to request updates that had been made while the connection was down
- (void)asyncInitializeConnection1:(SingleTon *)socket {
    // After successful login, refresh the Almond list and hash values.
    // This routine is important because the UI will listen for outcomes to these requests.
    // Specifically, the event kSFIDidUpdateAlmondList.

    __weak SecurifiToolkit *block_self = self;
    dispatch_async(self.commandDispatchQueue, ^() {
        DLog(@"%s: requesting almond list", __PRETTY_FUNCTION__);
        GenericCommand *cmd = [block_self makeAlmondListCommand];
        [block_self internalInitializeCloud:socket command:cmd];
    });
}

// Invokes post-connection set-up and login to request updates that had been made while the connection was down
- (void)asyncInitializeConnection2:(SingleTon *)socket {
    // After successful login, refresh the Almond list and hash values.
    // This routine is important because the UI will listen for outcomes to these requests.
    // Specifically, the event kSFIDidUpdateAlmondList.

    __weak SecurifiToolkit *block_self = self;
    dispatch_async(self.commandDispatchQueue, ^() {
        SFIAlmondPlus *plus = [block_self currentAlmond];
        if (plus != nil) {
            NSString *mac = plus.almondplusMAC;

            if (![socket wasHashFetchedForAlmond:mac]) {
                [socket markHashFetchedForAlmond:mac];

                DLog(@"%s: requesting hash for current almond: %@", __PRETTY_FUNCTION__, mac);
                GenericCommand *cmd = [block_self makeDeviceHashCommand:mac];
                [block_self internalInitializeCloud:socket command:cmd];
            }

            [block_self tryRequestAlmondMode:mac];
        }

        [block_self tryRefreshNotifications];

        [socket markCloudInitialized];
    });
}

#pragma mark - Command dispatch

// 1. open connection
// 2. send cloud sanity command
//      a. wait for response
//      b. if no response or bad response, kill connection and mark SingleTon as dead
//      c. if good response, then process next command
// 3. (optional) send logon (temp pass)
//      a. wait for response
//      b. if no response or bad response, kill connection and mark SingleTon as dead
//      c. if good response, then process next command

- (void)closeConnection {
    [self tearDownNetworkSingleton];
}

- (void)asyncSendToCloud:(GenericCommand *)command {
    if (self.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }

    // Initialize network if need be
    SingleTon *socket = self.networkSingleton;
    if (socket == nil || (!socket.isStreamConnected && socket.connectionState != SDKCloudStatusInitializing)) {
        // Set up network and wait
        //
        NSLog(@"Waiting to initialize socket");
        [self _asyncInitToolkit];
    }

    __weak SecurifiToolkit *block_self = self;
    dispatch_async(self.commandDispatchQueue, ^() {
        BOOL success = [block_self internalSendToCloud:block_self.networkSingleton command:command];
        if (success) {
            DLog(@"[Generic cmd: %d] send success", command.commandType);
        }
        else {
            DLog(@"[Generic cmd: %d] send error", command.commandType);
        }
    });
}

- (sfi_id)asyncChangeAlmond:(SFIAlmondPlus *)almond device:(SFIDevice *)device value:(SFIDeviceKnownValues *)newValue {
    // Generate internal index between 1 to 100
    MobileCommandRequest *request = [MobileCommandRequest new];
    request.almondMAC = almond.almondplusMAC;
    request.deviceID = [NSString stringWithFormat:@"%d", device.deviceID];
    request.deviceType = device.deviceType;
    request.indexID = [NSString stringWithFormat:@"%d", newValue.index];
    request.changedValue = newValue.value;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_MOBILE_COMMAND;
    cmd.command = request;

    [self asyncSendToCloud:cmd];

    return request.correlationId;
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
    [self removeCurrentAlmond];
    [self.dataManager purgeAll];
    if (self.configuration.enableNotifications) {
        [self.databaseStore purgeAllNotifications];
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
        [self asyncInitializeConnection1:self.networkSingleton];
    }
    else {
        // Logon failed:
        // Ensure all credentials are cleared
        [self tearDownLoginSession];
        [self tearDownNetworkSingleton];
    }

    // In any case, notify the UI about the login result
    [self postNotification:kSFIDidCompleteLoginNotification data:res];
}

- (void)onLogoutResponse:(NSNotification *)notification {
    [self tearDownLoginSession];
    [self tearDownNetworkSingleton];
    [self postNotification:kSFIDidLogoutNotification data:nil];
}

- (void)onLogoutAllResponse:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    LoginResponse *res = info[@"data"];

    if (res.isSuccessful) {
        DLog(@"SDK received success on Logout All");
        [self tearDownLoginSession];
        [self tearDownNetworkSingleton];
    }

    [self postNotification:kSFIDidLogoutAllNotification data:res];
}

- (void)onDeleteAccountResponse:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    DeleteAccountResponse *res = info[@"data"];
    if (res.isSuccessful) {
        DLog(@"SDK received success on Delete Account");
        [self tearDownLoginSession];
        [self tearDownNetworkSingleton];
        [self postNotification:kSFIDidLogoutAllNotification data:nil];
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

    NSArray *devices = [self deviceList:mac];
    if (devices.count == 0) {
        DLog(@"%s: devices empty: requesting device list for current almond: %@", __PRETTY_FUNCTION__, mac);
        [self asyncRequestDeviceList:mac];
    }

    // If the network is down, then do not send Hash request:
    // 1. it's not needed
    // 2. it will be sent automatically when the connection comes up
    // 3. sending it now will stimulate connection establishment and sending the command prior to other normal-bring up
    // commands will cause the connection to fail IF the currently selected almond is no longer linked to the account.
    SingleTon *singleton = self.networkSingleton;

    if (singleton == nil) {
        DLog(@"%s: network is down; not sending request for hash or mode: %@", __PRETTY_FUNCTION__, mac);
        return;
    }

    if (![singleton wasHashFetchedForAlmond:mac]) {
        [singleton markHashFetchedForAlmond:mac];

        DLog(@"%s: hash not checked on this connection: requesting hash for current almond: %@", __PRETTY_FUNCTION__, mac);
        GenericCommand *cmd = [self makeDeviceHashCommand:mac];
        [self asyncSendToCloud:cmd];
    }
    else {
        DLog(@"%s: hash already checked on this connection for current almond: %@", __PRETTY_FUNCTION__, mac);
    }

    // Fetch the Almond Mode
    [self tryRequestAlmondMode:mac];

    // refresh notification preferences; currently, we cannot rely on receiving dynamic updates for these values and so always refresh.
    [self asyncRequestNotificationPreferenceList:mac];
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

- (NSArray *)almondList {
    return [self.dataManager readAlmondList];
}

- (NSArray *)deviceList:(NSString *)almondMac {
    return [self.dataManager readDeviceList:almondMac];
}

- (NSArray *)deviceValuesList:(NSString *)almondMac {
    return [self.dataManager readDeviceValueList:almondMac];
}

- (NSArray *)notificationPrefList:(NSString *)almondMac {
    return [self.dataManager readNotificationList:almondMac];
}

#pragma mark - Device and Device Value Management

- (void)asyncRequestDeviceList:(NSString *)almondMac {
    if ([self.networkSingleton willFetchDeviceListFetchedForAlmond:almondMac]) {
        return;
    }
    [self.networkSingleton markWillFetchDeviceListForAlmond:almondMac];

    DeviceListRequest *deviceListCommand = [DeviceListRequest new];
    deviceListCommand.almondMAC = almondMac;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DEVICE_DATA;
    cmd.command = deviceListCommand;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeviceValueList:(NSString *)almondMac {
    DeviceValueRequest *command = [DeviceValueRequest new];
    command.almondMAC = almondMac;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DEVICE_VALUE;
    cmd.command = command;

    [self.networkSingleton markDeviceValuesFetchedForAlmond:almondMac];
    [self asyncSendToCloud:cmd];
}

- (BOOL)tryRequestDeviceValueList:(NSString *)almondMac {
    if ([self.networkSingleton wasDeviceValuesFetchedForAlmond:almondMac]) {
        return NO;
    }

    [self.networkSingleton markDeviceValuesFetchedForAlmond:almondMac];
    [self asyncRequestDeviceValueList:almondMac];
    return YES;
}


#pragma mark - Scoreboard management

- (Scoreboard *)scoreboardSnapshot {
    return [self.scoreboard copy];
}

- (void)markCommandEvent:(CommandType)commandType {
    if (self.config.enableScoreboard) {
        CommandTypeEvent *event = [[CommandTypeEvent alloc] initWithCommandType:commandType];
        [self.scoreboard markEvent:event];
    }
}

#pragma mark - Almond commands

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

#pragma mark - Account related commands

- (void)asyncRequestChangeCloudPassword:(NSString *)currentPwd changedPwd:(NSString *)changedPwd {
    ChangePasswordRequest *changePwdCommand = [ChangePasswordRequest new];
    changePwdCommand.emailID = [self loginEmail];
    changePwdCommand.currentPassword = currentPwd;
    changePwdCommand.changedPassword = changedPwd;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_CHANGE_PASSWORD_REQUEST;
    cmd.command = changePwdCommand;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeleteCloudAccount:(NSString *)password {
    DeleteAccountRequest *delAccountCommand = [DeleteAccountRequest new];
    delAccountCommand.emailID = [self loginEmail];
    delAccountCommand.password = password;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DELETE_ACCOUNT_REQUEST;
    cmd.command = delAccountCommand;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestUnlinkAlmond:(NSString *)almondMAC password:(NSString *)password {
    UnlinkAlmondRequest *unlinkAlmondCommand = [UnlinkAlmondRequest new];
    unlinkAlmondCommand.almondMAC = almondMAC;
    unlinkAlmondCommand.password = password;
    unlinkAlmondCommand.emailID = [self loginEmail];

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_UNLINK_ALMOND_REQUEST;
    cmd.command = unlinkAlmondCommand;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestInviteForSharingAlmond:(NSString *)almondMAC inviteEmail:(NSString *)inviteEmailID {
    UserInviteRequest *userInviteCommand = [[UserInviteRequest alloc] init];
    userInviteCommand.almondMAC = almondMAC;
    userInviteCommand.emailID = inviteEmailID;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_USER_INVITE_REQUEST;
    cmd.command = userInviteCommand;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeleteSecondaryUser:(NSString *)almondMAC email:(NSString *)emailID {
    DeleteSecondaryUserRequest *delUserCommand = [DeleteSecondaryUserRequest new];
    delUserCommand.almondMAC = almondMAC;
    delUserCommand.emailID = emailID;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DELETE_SECONDARY_USER_REQUEST;
    cmd.command = delUserCommand;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeleteMeAsSecondaryUser:(NSString *)almondMAC {
    DeleteMeAsSecondaryUserRequest *delUserCommand = [DeleteMeAsSecondaryUserRequest new];
    delUserCommand.almondMAC = almondMAC;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DELETE_ME_AS_SECONDARY_USER_REQUEST;
    cmd.command = delUserCommand;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestChangeAlmondName:(NSString *)changedAlmondName almondMAC:(NSString *)almondMAC {
    AlmondNameChange *req = [AlmondNameChange new];
    req.almondMAC = almondMAC;
    req.changedAlmondName = changedAlmondName;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ALMOND_NAME_CHANGE_REQUEST;
    cmd.command = req;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestMeAsSecondaryUser {
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ME_AS_SECONDARY_USER_REQUEST;
    cmd.command = [MeAsSecondaryUserRequest new];

    [self asyncSendToCloud:cmd];
}

#pragma mark - Almond and router settings

- (void)asyncAlmondStatusAndSettings:(NSString *)almondMac {
    if (almondMac.length == 0) {
        return;
    }

    BaseCommandRequest *pending = self.pendingAlmondStateAndSettingsRequest;
    if (pending) {
        if (!pending.isExpired) {
            return;
        }
    }
    self.pendingAlmondStateAndSettingsRequest = [BaseCommandRequest new];

    // sends a series of requests to fetch all the information at once.
    // note ordering might be important to the UI layer, which for now receives the response payloads directly
    [self internalRequestAlmondStatusAndSettings:almondMac command:GET_WIRELESS_SUMMARY_COMMAND];
    [self internalRequestAlmondStatusAndSettings:almondMac command:GET_WIRELESS_SETTINGS_COMMAND];
    [self internalRequestAlmondStatusAndSettings:almondMac command:GET_CONNECTED_DEVICE_COMMAND];
    [self internalRequestAlmondStatusAndSettings:almondMac command:GET_BLOCKED_DEVICE_COMMAND];
}

- (void)internalRequestAlmondStatusAndSettings:(NSString *)almondMac command:(NSString *)commandPayload {
    GenericCommandRequest *request = [GenericCommandRequest new];
    request.almondMAC = almondMac;
    request.applicationID = APPLICATION_ID;
    request.data = commandPayload;

    GenericCommand *cmd = [[GenericCommand alloc] init];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = request;

    [self asyncSendToCloud:cmd];
}

- (sfi_id)asyncUpdateAlmondWirelessSettings:(NSString *)almondMAC wirelessSettings:(SFIWirelessSetting *)settings {
    GenericCommandRequest *req = [[GenericCommandRequest alloc] init];
    req.almondMAC = almondMAC;
    req.data = [settings toXml];

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = req;
    [self asyncSendToCloud:cmd];

    return req.correlationId;
}

- (sfi_id)asyncSetAlmondWirelessUsersSettings:(NSString *)almondMAC blockedDeviceMacs:(NSArray *)blockedMacs {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];

    [writer startElement:@"AlmondBlockedMACs"];
    [writer addAttribute:@"action" value:@"set"];
    [writer addAttribute:@"count" integerValue:blockedMacs.count];

    int index = 0;
    for (NSString *mac in blockedMacs) {
        index++;
        [writer startElement:@"BlockedMAC"];
        [writer addAttribute:@"index" intValue:index];
        [writer addText:mac];
        [writer endElement];
    }

    [writer endElement];
    [writer endElement];

    GenericCommandRequest *req = [[GenericCommandRequest alloc] init];
    req.almondMAC = almondMAC;
    req.data = [writer toString];

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = req;
    [self asyncSendToCloud:cmd];

    return req.correlationId;
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

- (sfi_id)asyncRequestAlmondModeChange:(NSString *)almondMAC mode:(SFIAlmondMode)newMode {
    if (almondMAC == nil) {
        SLog(@"asyncRequestAlmondModeChange : almond MAC is nil");
        return 0;
    }

    AlmondModeChangeRequest *req = [AlmondModeChangeRequest new];
    req.almondMAC = almondMAC;
    req.mode = newMode;
    req.userId = [self loginEmail];

    self.pendingAlmondModeChange = req;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ALMOND_MODE_CHANGE_REQUEST;
    cmd.command = req;

    [self asyncSendToCloud:cmd];

    return req.correlationId;
}

- (SFIAlmondMode)modeForAlmond:(NSString *)almondMac {
    return [self tryCachedAlmondModeValue:almondMac];

}

- (SFIAlmondMode)tryCachedAlmondModeValue:(NSString *)almondMac {
    SingleTon *singleTon = self.networkSingleton;
    if (singleTon) {
        return [singleTon almondMode:almondMac];
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

    self.pendingNotificationPreferenceChange = req;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_PREF_CHANGE_REQUEST;
    cmd.command = req;

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

#pragma mark - SingleTon management

- (SingleTon *)setupNetworkSingleton {
    NSLog(@"Setting up network");

    [self tearDownNetworkSingleton];

    SingleTon *newSingleton = [SingleTon newSingletonWithResponseCallbackQueue:self.socketCallbackQueue dynamicCallbackQueue:self.socketDynamicCallbackQueue];
    newSingleton.delegate = self;
    newSingleton.connectionState = SDKCloudStatusInitializing;
    newSingleton.config = self.config;

    _networkSingleton = newSingleton;

    [newSingleton initNetworkCommunication:self.useProductionCloud];

    return newSingleton;
}

- (void)tearDownNetworkSingleton {
    NSLog(@"Starting tear down of network");

    SingleTon *old = self.networkSingleton;
    old.delegate = nil; // no longer interested in callbacks from this instance
    [old shutdown];

    self.pendingAlmondModeChange = nil;
    self.pendingNotificationPreferenceChange = nil;
    self.pendingRefreshNotificationsRequest = nil;
    self.pendingNotificationCountRequest = nil;
    self.pendingAlmondStateAndSettingsRequest = nil;

    self.networkSingleton = nil;

    NSLog(@"Finished tear down of network");
}

#pragma mark - SingleTonDelegate methods

- (void)singletTonDidReceiveDynamicUpdate:(SingleTon *)singleTon commandType:(CommandType)commandType {
    self.scoreboard.dynamicUpdateCount++;
    [self markCommandEvent:commandType];
}

- (void)singletTonDidSendCommand:(SingleTon *)singleTon command:(GenericCommand *)command {
    self.scoreboard.commandRequestCount++;
    [self markCommandEvent:command.commandType];
}

- (void)singletTonDidReceiveCommandResponse:(SingleTon *)singleTon command:(GenericCommand *)cmd timeToCompletion:(NSTimeInterval)roundTripTime responseType:(CommandType)responseType {
    self.scoreboard.commandResponseCount++;
    [self markCommandEvent:responseType];

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

- (void)singletTonCloudConnectionDidEstablish:(SingleTon *)singleTon {
    self.scoreboard.connectionCount++;
}

- (void)singletTonCloudConnectionDidClose:(SingleTon *)singleTon {
    if (singleTon == self.networkSingleton) {
        DLog(@"%s: posting NETWORK_DOWN_NOTIFIER on closing cloud connection", __PRETTY_FUNCTION__);
        [self postNotification:NETWORK_DOWN_NOTIFIER data:nil];
    }
}

#pragma mark - Internal Command Dispatch and Notification

- (BOOL)internalInitializeCloud:(SingleTon *)socket command:(GenericCommand *)command {
    return [socket submitCloudInitializationCommand:command];
}

- (BOOL)internalSendToCloud:(SingleTon *)socket command:(GenericCommand *)command {
    return [socket submitCommand:command];
}

- (void)postNotification:(NSString *)notificationName data:(id)payload {
    // An interesting behavior: notifications are posted mainly to the UI. There is an assumption built into the system that
    // the notifications are posted synchronously from the SDK. Change the dispatch queue to async, and the
    // UI can easily become confused. This needs to be sorted out.

    __weak id block_payload = payload;

    dispatch_sync(self.socketCallbackQueue, ^() {
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
        [self.networkSingleton markCloudInitialized];
        return;
    }

    AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        [self.networkSingleton markCloudInitialized];
        return;
    }

    NSArray *almondList = obj.almondPlusMACList;

    // Store the new list
    [self.dataManager writeAlmondList:almondList];

    // Ensure Current Almond is consistent with new list
    SFIAlmondPlus *plus = [self manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];

    // After requesting the Almond list, we then want to get additional info
    [self asyncInitializeConnection2:self.networkSingleton];

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
        newAlmondList = [self.dataManager deleteAlmond:deleted];
        if (self.config.enableNotifications) {
            [self.databaseStore deleteNotificationsForAlmond:deleted.almondplusMAC];
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

    NSArray *currentList = [self almondList];
    for (SFIAlmondPlus *almond in currentList) {
        if ([almond.almondplusMAC isEqualToString:obj.almondplusMAC]) {
            //Change the name of the current almond in the offline list
            almond.almondplusName = obj.almondplusName;

            // Save the change
            [self.dataManager writeAlmondList:currentList];

            // Update the Current Almond
            SFIAlmondPlus *plus = [self currentAlmond];
            if ([plus.almondplusMAC isEqualToString:almond.almondplusMAC]) {
                almond.colorCodeIndex = plus.colorCodeIndex;
                [self setCurrentAlmond:almond];
            }

            // Tell the world so they can update their view
            [self postNotification:kSFIDidChangeAlmondName data:almond];

            return;
        }
    }
}

// When the almond list is changed, ensure the Current Almond setting is consistent with the list.
// The setting may be changed by this method.
// Returns the current Almond, which might or might not be the same as the old one. May return nil.
- (SFIAlmondPlus *)manageCurrentAlmondOnAlmondListUpdate:(NSArray *)almondList manageCurrentAlmondChange:(BOOL)doManage {
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
        SFIAlmondPlus *current = [self currentAlmond];

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

        [self removeCurrentAlmond];

        GenericCommand *cmd = [self makeAlmondListCommand];
        [self asyncSendToCloud:cmd];

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
        [self.dataManager writeHashList:reportedHash currentMAC:currentMac];
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

    [self.networkSingleton clearWillFetchDeviceListForAlmond:obj.almondMAC];

    if (!obj.isSuccessful) {
        return;
    }

    NSString *almondMAC = obj.almondMAC;
    NSMutableArray *newDeviceList = obj.deviceList;

    [self processDeviceListChange:almondMAC newDevices:newDeviceList];
}

- (void)onDeviceListResponse:(id)sender {
    NSLog(@"Received device list response");

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceListResponse *obj = (DeviceListResponse *) [data valueForKey:@"data"];

    [self.networkSingleton clearWillFetchDeviceListForAlmond:obj.almondMAC];

    if (!obj.isSuccessful) {
        NSLog(@"Device list response was not successful; stopping");
        return;
    }

    NSString *mac = obj.almondMAC;
    NSArray *newDevices = obj.deviceList;

    [self processDeviceListChange:mac newDevices:newDevices];
}

// Processes device lists received in dynamic and on-demand updates.
// After storing the new list, a notification is posted and an updated values list is requested
- (void)processDeviceListChange:(NSString *)mac newDevices:(NSArray *)newDevices {
    [self.dataManager writeDeviceList:newDevices currentMAC:mac];

    // Request values for devices
    [self asyncRequestDeviceValueList:mac];

    // And tell the world there is a new list
    [self postNotification:kSFIDidChangeDeviceList data:mac];
}

#pragma mark - Device Value Update callbacks

- (void)onDynamicDeviceValueListChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceValueResponse *obj = (DeviceValueResponse *) [data valueForKey:@"data"];
    NSString *currentMAC = obj.almondMAC;

    [self processDynamicDeviceValueChange:obj currentMAC:currentMAC];
}

- (void)onDeviceValueListChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceValueResponse *obj = (DeviceValueResponse *) [data valueForKey:@"data"];
    NSString *currentMAC = obj.almondMAC;

    if (currentMAC.length == 0) {
        return;
    }

    // Update offline storage
    [self.dataManager writeDeviceValueList:obj.deviceValueList currentMAC:currentMAC];

    [self postNotification:kSFIDidChangeDeviceValueList data:currentMAC];
}

// Processes a dynamic change to a device value
- (void)processDynamicDeviceValueChange:(DeviceValueResponse *)obj currentMAC:(NSString *)currentMAC {
    if (currentMAC.length == 0) {
        return;
    }

    NSMutableArray *cloudDeviceValueList = obj.deviceValueList;
    NSArray *currentDeviceValueList = [self.dataManager readDeviceValueList:currentMAC];

    NSMutableArray *newDeviceValueList;
    if (currentDeviceValueList != nil) {
        for (SFIDeviceValue *currentValue in currentDeviceValueList) {
            for (SFIDeviceValue *cloudValue in cloudDeviceValueList) {
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
        if (cloudDeviceValueList.count > 0 && currentDeviceValueList.count == 0) {
            isDeviceMissing = YES;
        }
        else {
            for (SFIDeviceValue *currentCloudValue in cloudDeviceValueList) {
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
    }
    else {
        newDeviceValueList = cloudDeviceValueList;
    }

    // Update offline storage
    [self.dataManager writeDeviceValueList:newDeviceValueList currentMAC:currentMAC];

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

    NotificationPreferences *req = self.pendingNotificationPreferenceChange;
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
        self.pendingNotificationPreferenceChange = nil;
        return;
    }

    [self.dataManager writeNotificationList:newPrefs currentMAC:almondMac];

    self.pendingNotificationPreferenceChange = nil;
    [self postNotification:kSFINotificationPreferencesDidChange data:almondMac];
}

- (void)onNotificationRegistrationResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NotificationRegistrationResponse *obj = (NotificationRegistrationResponse *) [data valueForKey:@"data"];
    NSString *notification = obj.isSuccessful ? kSFIDidRegisterForNotifications : kSFIDidFailToRegisterForNotifications;
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
        [self.dataManager writeNotificationList:obj.notificationDeviceList currentMAC:currentMAC];
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
    [self.dataManager writeNotificationList:notificationList currentMAC:currentMAC];
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

    DLog(@"asyncRefreshNotifications: recevied request id:'%@'", requestId);

    // Remove the guard preventing more refresh notifications
    if (requestId.length == 0) {
        // note: we are only tracking "refresh" requests to prevent more than one of them to be processed at a time.
        // these requests are not the same as "catch up" requests for older sync points that were queued for fetching
        // but not downloaded; see internalTryProcessNotificationSyncPoints.
        NSLog(@"asyncRefreshNotifications: clearing refresh request tracking");
        self.pendingRefreshNotificationsRequest = nil;
    }

    // Store the notifications and stop tracking the pageState that they were associated with
    //
    // As implemented, iteration will continue until a duplicate notification is detected. This procedure
    // ensures that if the system is missing some notifications, it will catch up eventually.
    // Notifications are delivered newest to oldest, making it likely all new ones are fetched in the first call.
    DatabaseStore *store = self.databaseStore;

    NSUInteger newCount = res.newCount;
    NSInteger storedCount = [store storeNotifications:res.notifications syncPoint:requestId];
    NSUInteger totalCount = res.notifications.count;
    BOOL allStored = (storedCount == totalCount);

    if (allStored) {
        DLog(@"asyncRefreshNotifications: stored:%li", (long) totalCount);
    }
    else {
        DLog(@"asyncRefreshNotifications: stored partial notifications:%li of %li", (long) storedCount, (long) totalCount);
    }

    if (storedCount == 0) {
        [store storeBadgeCount:newCount];

        // check whether there is queued work to be done
        [self internalTryProcessNotificationSyncPoints];

        // if nothing stored, then no need to tell the world
        return;
    }

    if (!allStored) {
        // stopped early
        // nothing more to do
        [store storeBadgeCount:newCount];

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

        // Keep track of this page state until the response has been processed
        [store trackSyncPoint:nextPageState];

        [self internalAsyncFetchNotifications:nextPageState];
    }
    else {
        // check whether there is queued work to be done
        [self internalTryProcessNotificationSyncPoints];
    }
}

// Check whether there are page states in the data store that need to be fetched.
// This could happen when the app is halted or connections break before a previous
// run completed fetching all pages.
- (void)internalTryProcessNotificationSyncPoints {
    DatabaseStore *store = self.databaseStore;

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
    self.pendingNotificationCountRequest = nil;

    NotificationCountResponse *res = data[@"data"];
    if (res.error) {
        NSLog(@"onNotificationCountResponse: error response");
        return;
    }

    // Store the notifications and stop tracking the pageState that they were associated with
    DatabaseStore *store = self.databaseStore;
    [store storeBadgeCount:res.badgeCount];

    [self postNotification:kSFINotificationBadgeCountDidChange data:nil];

    if (res.badgeCount > 0) {
        [self tryRefreshNotifications];
    }
}

#pragma mark - Notification access and refresh commands

- (BOOL)storePushNotification:(SFINotification *)notification {
    if (!self.config.enableNotifications) {
        return NO;
    }

    BOOL success = [self.databaseStore storeNotification:notification];
    if (success) {
        [self postNotification:kSFINotificationDidStore data:nil];
    }

    return success;
}

- (NSArray *)notifications {
    if (!self.config.enableNotifications) {
        return [NSArray array];
    }
    return [self.notificationsStore fetchNotifications:100];
}

- (void)markNotificationViewed:(SFINotification *)notification {
    if (!self.config.enableNotifications) {
        return;
    }
    [self.notificationsStore markViewed:notification];
    [self postNotification:kSFINotificationDidMarkViewed data:nil];
}

- (NSInteger)countUnviewedNotifications {
    if (!self.config.enableNotifications) {
        return 0;
    }
    return [self.notificationsStore countUnviewedNotifications];
}

- (id <SFINotificationStore>)newNotificationStore {
    return [self.databaseStore newStore];
}

- (BOOL)copyNotificationStoreTo:(NSString *)filePath {
    if (!self.config.enableNotifications) {
        return NO;
    }
    return [self.databaseStore copyDatabaseTo:filePath];
}

// this method sends a request to fetch the latest notifications;
// it does not handle the case of fetching older ones 
- (void)tryRefreshNotifications {
    if (!self.config.enableNotifications) {
        return;
    }

    NotificationListRequest *pending = self.pendingRefreshNotificationsRequest;
    if (pending) {
        if (![pending isExpired]) {
            // give the request 5 seconds to complete
            NSLog(@"asyncRefreshNotifications: fail fast; already fetching latest");
            return;
        }
    }

    [self internalAsyncFetchNotifications:nil];
}

- (void)tryFetchNotificationCount {
    if (!self.config.enableNotifications) {
        return;
    }

    NotificationCountRequest *pending = self.pendingNotificationCountRequest;
    if (pending) {
        if (![pending shouldExpireAfterSeconds:5]) {
            // give the request 5 seconds to complete
            NSLog(@"tryFetchNotificationCount: fail fast; already fetching latest count");
            return;
        }
    }

    NotificationCountRequest *req = [NotificationCountRequest new];

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATIONS_COUNT_REQUEST;
    cmd.command = req;

    [self asyncSendToCloud:cmd];
}

- (NSInteger)notificationsBadgeCount {
    if (!self.config.enableNotifications) {
        return 0;
    }

    return self.databaseStore.badgeCount;
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
        NSLog(@"asyncRefreshNotifications: tracking refresh request");
        self.pendingRefreshNotificationsRequest = req;
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

    AlmondModeChangeRequest *req = self.pendingAlmondModeChange;
    if (req) {
        [self.networkSingleton markModeForAlmond:req.almondMAC mode:req.mode];
        self.pendingAlmondModeChange = nil;
    }

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

    [self.networkSingleton markModeForAlmond:res.almondMAC mode:res.mode];
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

    [self.networkSingleton markModeForAlmond:res.almondMAC mode:res.mode];
    [self postNotification:kSFIAlmondModeDidChange data:res];
}

@end

