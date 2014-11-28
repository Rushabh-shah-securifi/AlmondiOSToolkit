//
//  SecurifiToolkit.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
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
#import "SFIXmlWriter.h"
#import "SecurifiConfigurator.h"


#define kPREF_CURRENT_ALMOND                                @"kAlmondCurrent"
#define kPREF_USER_DEFAULT_LOGGED_IN_ONCE                   @"kLoggedInOnce"

#define SEC_SERVICE_NAME                                    @"securifiy.login_service"
#define SEC_EMAIL                                           @"com.securifi.email"
#define SEC_PWD                                             @"com.securifi.pwd"
#define SEC_USER_ID                                         @"com.securifi.userid"
#define SEC_IS_ACCOUNT_ACTIVATED                            @"com.securifi.isActivated"
#define SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT          @"com.securifi.minsRemaining"

NSString *const kSFIDidCompleteLoginNotification = @"kSFIDidCompleteLoginNotification";
NSString *const kSFIDidLogoutNotification = @"kSFIDidLogoutNotification";
NSString *const kSFIDidLogoutAllNotification = @"kSFIDidLogoutAllNotification";
NSString *const kSFIDidChangeCurrentAlmond = @"kSFIDidChangeCurrentAlmond";
NSString *const kSFIDidUpdateAlmondList = @"kSFIDidUpdateAlmondList";
NSString *const kSFIDidChangeAlmondName = @"kSFIDidChangeAlmondName";
NSString *const kSFIDidChangeDeviceList = @"kSFIDidChangeDeviceData";
NSString *const kSFIDidChangeDeviceValueList = @"kSFIDidChangeDeviceValueList";
NSString *const kSFIDidCompleteMobileCommandRequest = @"kSFIDidCompleteMobileCommandRequest";
NSString *const kSFIDidChangeNotificationList = @"kSFIDidChangeNotificationList";

@interface CommandTypeEvent : NSObject <ScoreboardEvent>
@property (readonly) CommandType commandType;
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
        case CommandType_SENSOR_CHANGE_REQUEST:
            return [NSString stringWithFormat:@"SENSOR_CHANGE_REQUEST_%d", type];
        case CommandType_SENSOR_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"SENSOR_CHANGE_RESPONSE_%d", type];
        case CommandType_DEVICE_DATA_FORCED_UPDATE_REQUEST:
            return [NSString stringWithFormat:@"DEVICE_DATA_FORCED_UPDATE_REQUEST_%d", type];
        case CommandType_ALMOND_NAME_CHANGE_REQUEST:
            return [NSString stringWithFormat:@"ALMOND_NAME_CHANGE_REQUEST_%d", type];
        case CommandType_ALMOND_NAME_CHANGE_RESPONSE:
            return [NSString stringWithFormat:@"ALMOND_NAME_CHANGE_RESPONSE_%d", type];
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
@property(nonatomic, readonly) Scoreboard *scoreboard;
@property(nonatomic, readonly) dispatch_queue_t socketCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t socketDynamicCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t commandDispatchQueue;
@property(nonatomic, weak) SingleTon *networkSingleton;
@property(atomic) BOOL initializing; // when TRUE an op is already in progress to set up a network
@property(atomic) BOOL isShutdown;
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

+ (instancetype)sharedInstance {
    return singleton;
}

- (instancetype)initWithConfig:(SecurifiConfigurator *)config {
    self = [super init];
    if (self) {
        _config = [config copy];

        _scoreboard = [Scoreboard new];
        _dataManager = [SFIOfflineDataManager new];

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
        [center addObserver:self selector:@selector(onNotificationPrefListChange:) name:NOTIFICATION_PREFERENCE_LIST_RESPONSE_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onAlmondListResponse:) name:ALMOND_LIST_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceHashResponse:) name:DEVICEDATA_HASH_NOTIFIER object:nil];
    }

    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self name:kSFIReachabilityChangedNotification object:nil];

    [center removeObserver:self name:LOGIN_NOTIFIER object:nil];
    [center removeObserver:self name:LOGOUT_NOTIFIER object:nil];
    [center removeObserver:self name:LOGOUT_ALL_NOTIFIER object:nil];

    [center removeObserver:self name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER object:nil];
    [center removeObserver:self name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER object:nil];
    [center removeObserver:self name:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER object:nil];

    [center removeObserver:self name:DYNAMIC_DEVICE_DATA_NOTIFIER object:nil];
    [center removeObserver:self name:DEVICE_DATA_NOTIFIER object:nil];

    [center removeObserver:self name:DYNAMIC_DEVICE_VALUE_LIST_NOTIFIER object:nil];
    [center removeObserver:self name:DEVICE_VALUE_LIST_NOTIFIER object:nil];

    [center removeObserver:self name:ALMOND_LIST_NOTIFIER object:nil];
    [center removeObserver:self name:DEVICEDATA_HASH_NOTIFIER object:nil];

    [center removeObserver:self name:DELETE_ACCOUNT_RESPONSE_NOTIFIER object:nil];
    [center removeObserver:self name:NOTIFICATION_PREFERENCE_LIST_RESPONSE_NOTIFIER object:nil];
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

    }

    return NO;
}

- (BOOL)isReachable {
    return [self.cloudReachability isReachable];
}

- (BOOL)isLoggedIn {
    SingleTon *singleton = self.networkSingleton;
    return singleton && singleton.isLoggedIn;
}

- (BOOL)isAccountActivated {
    return [[self secIsAccountActivated] boolValue];
}

- (int)minsRemainingForUnactivatedAccount {
    return [[self secMinsRemainingForUnactivatedAccount] intValue];
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

- (void)setupReachability:(NSString*)hostname {
    [_cloudReachability shutdown];
    _cloudReachability = [[SFIReachabilityManager alloc] initWithHost:hostname];
}

- (void)onReachabilityChanged:(id)notice {
    self.scoreboard.reachabilityChangedCount++;
}

#pragma mark - SDK Initialization

// Initialize the SDK. Can be called repeatedly to ensure the SDK is set-up.
- (void)initToolkit {
    if (self.isShutdown) {
        DLog(@"INIT SDK. Already shutdown. Returning.");
        return;
    }

    if (self.initializing) {
        DLog(@"INIT SDK. Already initializing.");
        return;
    }

    [self _asyncInitToolkit];
}

- (void)_asyncInitToolkit {
    if (self.isShutdown) {
        DLog(@"INIT SDK. Already shutdown. Returning.");
        return;
    }

    if (self.initializing) {
        DLog(@"INIT SDK. Already initializing.");
        return;
    }

    __weak SecurifiToolkit *block_self = self;

    dispatch_async(self.commandDispatchQueue, ^() {
        if (block_self.isShutdown) {
            DLog(@"INIT SDK. Already shutdown. Returning.");
            return;
        }
        if (block_self.initializing) {
            DLog(@"INIT SDK. Already initializing.");
            return;
        }
        block_self.initializing = YES;
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
            block_self.initializing = NO;
            return;
        }

        DLog(@"%s: init SDK: send sanity successful", __PRETTY_FUNCTION__);
        DLog(@"%s: session started: %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());

        // If no logon credentials, then initialization is completed.
        if (![block_self hasLoginCredentials]) {
            DLog(@"%s: no logon credentials", __PRETTY_FUNCTION__);
            singleTon.connectionState = SDKCloudStatusNotLoggedIn;
            [singleTon markCloudInitialized];

            block_self.initializing = NO;

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
        block_self.initializing = NO;

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
        }

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
    if (socket == nil || (!socket.isStreamConnected && !self.initializing)) {
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

- (void)storeLoginCredentials:(LoginResponse *)obj {
    NSString *tempPass = obj.tempPass;
    NSString *userId = obj.userID;

    [self setSecPassword:tempPass];
    [self setSecUserId:userId];

    //PY: 101014 - Not activated accounts can be accessed for 7 days
    [self storeAccountActivationCredentials:obj];

}

-(void)storeAccountActivationCredentials:(LoginResponse *)obj{
    //PY: 101014 - Not activated accounts can be accessed for 7 days
    NSString * isAccountActivated = obj.isAccountActivated;
    NSString * minsRemainingForUnactivatedAccount = obj.minsRemainingForUnactivatedAccount;
    [self setSecAccountActivationStatus:isAccountActivated];
    [self setSecMinsRemainingForUnactivatedAccount:minsRemainingForUnactivatedAccount];
}

- (void)tearDownLoginSession {
    [self removeCurrentAlmond];
    [self clearSecCredentials];
    [self.dataManager purgeAll];
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
        [self postNotification:kSFIDidLogoutAllNotification data:nil];
    }
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
    if (![singleton wasHashFetchedForAlmond:mac]) {
        [singleton markHashFetchedForAlmond:mac];

        DLog(@"%s: hash not checked on this connection: requesting hash for current almond: %@", __PRETTY_FUNCTION__, mac);
        GenericCommand *cmd = [self makeDeviceHashCommand:mac];
        [self asyncSendToCloud:cmd];
    }
    else {
        DLog(@"%s: hash already checked on this connection for current almond: %@", __PRETTY_FUNCTION__, mac);
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

- (NSArray *)almondList {
    return [self.dataManager readAlmondList];
}

- (NSArray *)deviceList:(NSString *)almondMac {
    return [self.dataManager readDeviceList:almondMac];
}

- (NSArray *)deviceValuesList:(NSString *)almondMac {
    return [self.dataManager readDeviceValueList:almondMac];
}

-(NSArray *)notificationPrefList:(NSString *)almondMac{
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
    if (self.collectEvents) {
        CommandTypeEvent *event = [[CommandTypeEvent alloc] initWithCommandType:commandType];
        [self.scoreboard markEvent:event];
    }
}

#pragma mark - Account related commands

- (void)asyncRequestChangeCloudPassword:(NSString*)currentPwd changedPwd:(NSString*)changedPwd{
    ChangePasswordRequest *changePwdCommand = [ChangePasswordRequest new];
    changePwdCommand.emailID = [self loginEmail];
    changePwdCommand.currentPassword = currentPwd;
    changePwdCommand.changedPassword = changedPwd;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_CHANGE_PASSWORD_REQUEST;
    cmd.command = changePwdCommand;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeleteCloudAccount:(NSString*)password{
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

- (void)asyncRequestInviteForSharingAlmond:(NSString*)almondMAC inviteEmail:(NSString*)inviteEmailID{
    UserInviteRequest *userInviteCommand = [[UserInviteRequest alloc]init];
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
    AlmondNameChange *nameChange = [AlmondNameChange new];
    nameChange.almondMAC = almondMAC;
    nameChange.changedAlmondName = changedAlmondName;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ALMOND_NAME_CHANGE_REQUEST;
    cmd.command = nameChange;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestMeAsSecondaryUser {
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ME_AS_SECONDARY_USER_REQUEST;
    cmd.command = [MeAsSecondaryUserRequest new];

    [self asyncSendToCloud:cmd];
}

#pragma mark - Almond and router settings

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

#pragma mark - Notifications

- (void)asyncRequestRegisterForNotification:(NSString*)deviceToken {
    if (deviceToken == nil) {
        SLog(@"asyncRequestRegisterForNotification : device toke is nil");
        return;
    }
    
    NotificationRegistration *notificationRegister = [NotificationRegistration new];
    notificationRegister.regID = deviceToken;
    notificationRegister.platform = @"iOS";

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_REGISTRATION;
    cmd.command = notificationRegister;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestDeregisterForNotification:(NSString *)deviceToken {
    if (deviceToken == nil) {
        SLog(@"asyncRequestRegisterForNotification : device toke is nil");
        return;
    }

    NotificationDeleteRegistrationRequest *notificationDeregister = [NotificationDeleteRegistrationRequest new];
    notificationDeregister.regID = deviceToken;
    notificationDeregister.platform = @"iOS";

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_DEREGISTRATION;
    cmd.command = notificationDeregister;

    [self asyncSendToCloud:cmd];
}

- (void)asyncRequestNotificationPreferenceList:(NSString*)almondMAC {
    if (almondMAC == nil) {
        SLog(@"asyncRequestRegisterForNotification : almond MAC is nil");
        return;
    }

    NotificationPreferenceListRequest *notificationPrefList = [NotificationPreferenceListRequest new];
    notificationPrefList.almondplusMAC = almondMAC;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST;
    cmd.command = notificationPrefList;

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
    LoginTempPass *cmd = [LoginTempPass new];
    cmd.UserID = [self secUserId];
    cmd.TempPass = [self secPassword];

    GenericCommand *command = [GenericCommand new];
    command.commandType = CommandType_LOGIN_COMMAND; // use Login command type
    command.command = cmd;

    return command;
}

- (GenericCommand *)makeAlmondListCommand {
    GenericCommand *command = [GenericCommand new];
    command.commandType = CommandType_ALMOND_LIST;
    command.command = [AlmondListRequest new];
    return command;
}

- (GenericCommand *)makeDeviceHashCommand:(NSString *)almondMac {
    DeviceDataHashRequest *deviceHashCommand = [DeviceDataHashRequest new];
    deviceHashCommand.almondMAC = almondMac;

    GenericCommand *command = [GenericCommand new];
    command.commandType = CommandType_DEVICE_DATA_HASH;
    command.command = deviceHashCommand;

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
- (NSString *)secIsAccountActivated {
    return [KeyChainWrapper retrieveEntryForUser:SEC_IS_ACCOUNT_ACTIVATED forService:SEC_SERVICE_NAME];
}

- (void)setSecAccountActivationStatus:(NSString *)isActivated {
    if (isActivated == nil) {
        [KeyChainWrapper createEntryForUser:SEC_IS_ACCOUNT_ACTIVATED entryValue:IS_ACCOUNT_ACTIVATED_DEFAULT forService:SEC_SERVICE_NAME];
    }
    else {
        [KeyChainWrapper createEntryForUser:SEC_IS_ACCOUNT_ACTIVATED entryValue:isActivated forService:SEC_SERVICE_NAME];
    }
}

- (NSString *)secMinsRemainingForUnactivatedAccount {
    return [KeyChainWrapper retrieveEntryForUser:SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT forService:SEC_SERVICE_NAME];
}

-(void)setSecMinsRemainingForUnactivatedAccount:(NSString *)minsRemaining{
    if(minsRemaining == nil){
       [KeyChainWrapper createEntryForUser:SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT entryValue:MINS_REMAINING_DEFAULT forService:SEC_SERVICE_NAME];
    }else{
     [KeyChainWrapper createEntryForUser:SEC_MINS_REMAINING_FOR_UNACTIVATED_ACCOUNT entryValue:minsRemaining forService:SEC_SERVICE_NAME];
    }
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

    NSLog(@"Command completion: cmd:%@, %0.3f secs", cmd, roundTripTime);
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
- (SFIAlmondPlus*)manageCurrentAlmondOnAlmondListUpdate:(NSArray *)almondList manageCurrentAlmondChange:(BOOL)doManage {
    // Manage the "Current selected Almond" value
    if (almondList.count == 0) {
        [self removeCurrentAlmond];
        [self.dataManager purgeAll];
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

#pragma mark - Device Updates

- (void)onDeviceHashResponse:(id)sender {
    NSLog(@"Received Almond hash response");

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceDataHashResponse *obj = (DeviceDataHashResponse *) [data valueForKey:@"data"];
    NSString *currentHash = obj.almondHash;
    if (!obj.isSuccessful || currentHash.length == 0) {
        // We assume, on failure, the Almond is no longer associated with this account and
        // our list of Almonds is out of date. Therefore, issue a request for the Almond list.
        NSLog(@"Device hash response failed; requesting Almond list");

        [self removeCurrentAlmond];

        GenericCommand *cmd = [self makeAlmondListCommand];
        [self asyncSendToCloud:cmd];

        return;
    }

    SFIAlmondPlus *plus = [self currentAlmond];
    if (plus == nil) {
        NSLog(@"Device Hash Response failed: No current Almond");
        return;
    }

    NSString *currentMac = plus.almondplusMAC;
    NSString *storedHash = [self.dataManager readHashList:currentMac];

    if (currentHash == nil || [currentHash isEqualToString:@"null"]) {
        //Hash sent by cloud as null - No Device
        NSLog(@"Device Hash Response: null; request devices");
        [self asyncRequestDeviceList:currentMac];
    }
    else if (storedHash.length > 0 && currentMac.length > 0 && [storedHash isEqualToString:currentHash]) {
        // Devices list is fresh. Update the device values.
        NSLog(@"Device Hash Response: matched; request values");
        [self tryRequestDeviceValueList:currentMac];
    }
    else {
        //Save hash in file for each almond
        NSLog(@"Device Hash Response: mismatch; requesting devices; mac:%@, current:%@, stored:%@", currentMac, currentHash, storedHash);
        [self.dataManager writeHashList:currentHash currentMAC:currentMac];
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

#pragma mark - Device Value Updates

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


#pragma mark - Notification Preference List
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
    
    if([obj.notificationDeviceList count]!=0){
        // Update offline storage
        [self.dataManager writeNotificationList:obj.notificationDeviceList currentMAC:currentMAC];
        [self postNotification:kSFIDidChangeNotificationList data:currentMAC];
    }
}


//- (void)onDynamicNotificationListChange:(id)sender {
//    NSNotification *notifier = (NSNotification *) sender;
//    NSDictionary *data = [notifier userInfo];
//    if (data == nil) {
//        return;
//    }
//    
//    DeviceValueResponse *obj = (DeviceValueResponse *) [data valueForKey:@"data"];
//    NSString *currentMAC = obj.almondMAC;
//    
//    [self processDynamicDeviceValueChange:obj currentMAC:currentMAC];
//}

// Processes a dynamic change to a device value
- (void)processDynamicNotificationPrefChange:(NotificationPreferenceListResponse *)obj currentMAC:(NSString *)currentMAC {
    if (currentMAC.length == 0) {
        return;
    }
    
//    NSMutableArray *cloudDeviceValueList = obj.deviceValueList;
//    NSArray *currentDeviceValueList = [self.dataManager readDeviceValueList:currentMAC];
//    
//    NSMutableArray *newDeviceValueList;
//    if (currentDeviceValueList != nil) {
//        for (SFIDeviceValue *currentValue in currentDeviceValueList) {
//            for (SFIDeviceValue *cloudValue in cloudDeviceValueList) {
//                if (currentValue.deviceID == cloudValue.deviceID) {
//                    cloudValue.isPresent = YES;
//                    
//                    NSArray *currentValues = [currentValue knownDevicesValues];
//                    NSArray *cloudValues = [cloudValue knownDevicesValues];
//                    
//                    for (SFIDeviceKnownValues *currentMobileKnownValue in currentValues) {
//                        for (SFIDeviceKnownValues *currentCloudKnownValue in cloudValues) {
//                            if (currentMobileKnownValue.index == currentCloudKnownValue.index) {
//                                currentMobileKnownValue.value = currentCloudKnownValue.value;
//                                break;
//                            }
//                        }
//                    }
//                    
//                    [currentValue replaceKnownDeviceValues:currentValues];
//                }
//            }
//        }
//        
//        newDeviceValueList = [NSMutableArray arrayWithArray:currentDeviceValueList];
//        
//        // Traverse the list and add the new value to offline list
//        // If there are new values without corresponding devices, we know to request the device list.
//        BOOL isDeviceMissing = NO;
//        if (cloudDeviceValueList.count > 0 && currentDeviceValueList.count == 0) {
//            isDeviceMissing = YES;
//        }
//        else {
//            for (SFIDeviceValue *currentCloudValue in cloudDeviceValueList) {
//                if (!currentCloudValue.isPresent) {
//                    [newDeviceValueList addObject:currentCloudValue];
//                    isDeviceMissing = YES;
//                }
//            }
//        }
//        
//        if (isDeviceMissing) {
//            NSLog(@"Missing devices for values. Requesting device hash for %@", currentMAC);
//            GenericCommand *command = [self makeDeviceHashCommand:currentMAC];
//            [self asyncSendToCloud:command];
//        }
//    }
//    else {
//        newDeviceValueList = cloudDeviceValueList;
//    }
//    
//    // Update offline storage
//    [self.dataManager writeDeviceValueList:newDeviceValueList currentMAC:currentMAC];
//    
//    [self postNotification:kSFIDidChangeDeviceValueList data:currentMAC];
}

@end

