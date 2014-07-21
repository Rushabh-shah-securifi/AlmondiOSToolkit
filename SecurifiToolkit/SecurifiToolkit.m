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
#import "PrivateCommandTypes.h"
#import "KeyChainWrapper.h"

#define kPREF_CURRENT_ALMOND                                @"kAlmondCurrent"
#define kPREF_USER_DEFAULT_LOGGED_IN_ONCE                   @"kLoggedInOnce"

#define SEC_SERVICE_NAME                                    @"securifiy.login_service"
#define SEC_EMAIL                                           @"com.securifi.email"
#define SEC_PWD                                             @"com.securifi.pwd"
#define SEC_USER_ID                                         @"com.securifi.userid"

NSString *const kSFIDidCompleteLoginNotification = @"kSFIDidCompleteLoginNotification";
NSString *const kSFIDidLogoutNotification = @"kSFIDidLogoutNotification";
NSString *const kSFIDidLogoutAllNotification = @"kSFIDidLogoutAllNotification";
NSString *const kSFIDidUpdateAlmondList = @"kSFIDidUpdateAlmondList";
NSString *const kSFIDidChangeAlmondName = @"kSFIDidChangeAlmondName";
NSString *const kSFIDidChangeDeviceList = @"kSFIDidChangeDeviceData";
NSString *const kSFIDidChangeDeviceValueList = @"kSFIDidChangeDeviceValueList";

@interface SecurifiToolkit () <SingleTonDelegate>
@property(nonatomic, readonly) dispatch_queue_t socketCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t socketDynamicCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t commandDispatchQueue;
@property(nonatomic, weak) SingleTon *networkSingleton;
@property(atomic) BOOL initializing; // when TRUE an op is already in progress to set up a network
@property(atomic) BOOL isShutdown;
@end

@implementation SecurifiToolkit

#pragma mark - Lifecycle methods

+ (instancetype)sharedInstance {
    static dispatch_once_t once_predicate;
    static SecurifiToolkit *singleton = nil;

    dispatch_once(&once_predicate, ^{
        singleton = [SecurifiToolkit new];
    });

    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        _socketCallbackQueue = dispatch_queue_create("socket_callback", DISPATCH_QUEUE_CONCURRENT);
        _socketDynamicCallbackQueue = dispatch_queue_create("socket_dynamic_callback", DISPATCH_QUEUE_CONCURRENT);

        _commandDispatchQueue = dispatch_queue_create("command_dispatch", DISPATCH_QUEUE_SERIAL);

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        [center addObserver:self selector:@selector(onLoginResponse:) name:LOGIN_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onLogoutResponse:) name:LOGOUT_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onLogoutAllResponse:) name:LOGOUT_ALL_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onDynamicAlmondListAdd:) name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDynamicAlmondListDelete:) name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDynamicAlmondNameChange:) name:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onDynamicDeviceListChange:) name:DYNAMIC_DEVICE_DATA_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceListResponse:) name:DEVICE_DATA_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onDynamicDeviceValueListChange:) name:DYNAMIC_DEVICE_VALUE_LIST_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceValueListChange:) name:DEVICE_VALUE_LIST_NOTIFIER object:nil];

        [center addObserver:self selector:@selector(onAlmondListResponse:) name:ALMOND_LIST_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDeviceHashResponse:) name:DEVICEDATA_HASH_NOTIFIER object:nil];
    }

    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

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
    return [[SFIReachabilityManager sharedManager] isReachable];
}

- (BOOL)isLoggedIn {
    SingleTon *singleton = self.networkSingleton;
    return singleton && singleton.isLoggedIn;
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

#pragma mark - SDK Initialization

// Initialize the SDK. Can be called repeatedly to ensure the SDK is set-up.
- (void)initSDK {
    if (self.isShutdown) {
        DLog(@"INIT SDK. Already shutdown. Returning.");
        return;
    }

    if (self.initializing) {
        DLog(@"INIT SDK. Already initializing.");
        return;
    }

    [self _asyncInitSDK];
}

- (void)_asyncInitSDK {
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
- (void)shutdown {
    if (self.isShutdown) {
        return;
    }
    self.isShutdown = YES;
    NSLog(@"Shutdown SDK");

    SecurifiToolkit __weak *block_self = self;

    dispatch_async(self.socketCallbackQueue, ^(void) {
        [block_self tearDownNetworkSingleton];
        block_self.networkSingleton = nil;
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
        [self _asyncInitSDK];
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

#pragma mark - Cloud Logon

- (void)asyncSendLoginWithEmail:(NSString *)email password:(NSString *)password {
    if (self.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }

    [self tearDownLoginSession];
    [self setSecEmail:email];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kPREF_USER_DEFAULT_LOGGED_IN_ONCE];

    Login *loginCommand = [Login new];
    loginCommand.UserID = email;
    loginCommand.Password = password;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = LOGIN_COMMAND;
    cloudCommand.command = loginCommand;

    [self asyncSendToCloud:cloudCommand];
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
        GenericCommand *cmd = [[GenericCommand alloc] init];
        cmd.commandType = LOGOUT_COMMAND;
        cmd.command = nil;

        [self asyncSendToCloud:cmd];
    }
    else {
        // Not connected, so just purge on-device credentials and cache
        [self onLogoutResponse:nil];
    }
}

- (void)asyncSendLogoutAllWithEmail:(NSString *)email password:(NSString *)password {
    LogoutAllRequest *cmd = [[LogoutAllRequest alloc] init];
    cmd.UserID = [NSString stringWithString:email];
    cmd.Password = [NSString stringWithString:password];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = LOGOUT_ALL_COMMAND;
    cloudCommand.command = cmd;

    [self asyncSendToCloud:cloudCommand];
}

- (void)storeLoginCredentials:(LoginResponse *)obj {
    NSString *tempPass = obj.tempPass;
    NSString *userId = obj.userID;

    [self setSecPassword:tempPass];
    [self setSecUserId:userId];
}

- (void)tearDownLoginSession {
    [self removeCurrentAlmond];
    [self clearSecCredentials];
    [SFIOfflineDataManager purgeAll];
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

        // Request updates: normally, once a logon token has been retrieved, we just issue these commands as part of SDK initialization.
        // But the client was not logged in. Send them now...
        [self asyncInitializeConnection1:self.networkSingleton];
    }
    else {
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

- (NSString *)currentAlmondName {
    return [[self currentAlmond] almondplusName];
}

- (NSArray *)almondList {
    return [SFIOfflineDataManager readAlmondList];
}

- (NSArray *)deviceList:(NSString *)almondMac {
    return [SFIOfflineDataManager readDeviceList:almondMac];
}

- (NSArray *)deviceValuesList:(NSString *)almondMac {
    return [SFIOfflineDataManager readDeviceValueList:almondMac];
}


#pragma mark - Device and Device Value Management

- (void)asyncRequestDeviceList:(NSString *)almondMac {
    DeviceListRequest *deviceListCommand = [[DeviceListRequest alloc] init];
    deviceListCommand.almondMAC = almondMac;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = DEVICEDATA;
    cloudCommand.command = deviceListCommand;

    [self asyncSendToCloud:cloudCommand];
}

- (void)asyncRequestDeviceValueList:(NSString *)almondMac {
    DeviceValueRequest *command = [[DeviceValueRequest alloc] init];
    command.almondMAC = almondMac;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = DEVICE_VALUE;
    cloudCommand.command = command;

    [self.networkSingleton markDeviceValuesFetchedForAlmond:almondMac];
    [self asyncSendToCloud:cloudCommand];
}

- (BOOL)tryRequestDeviceValueList:(NSString *)almondMac {
    if ([self.networkSingleton wasDeviceValuesFetchedForAlmond:almondMac]) {
        return NO;
    }

    [self.networkSingleton markDeviceValuesFetchedForAlmond:almondMac];
    [self asyncRequestDeviceValueList:almondMac];
    return YES;
}

#pragma mark - Device value updates

- (void)writeDeviceValueList:(NSArray *)deviceList currentMAC:(NSString *)almondMac {
    [SFIOfflineDataManager writeDeviceValueList:deviceList currentMAC:almondMac];
}

#pragma mark - Command constructors

- (GenericCommand *)makeCloudSanityCommand {
    GenericCommand *sanityCommand = [[GenericCommand alloc] init];
    sanityCommand.commandType = CLOUD_SANITY;
    sanityCommand.command = nil;
    return sanityCommand;
}

- (GenericCommand *)makeTempPassLoginCommand {
    LoginTempPass *cmd = [[LoginTempPass alloc] init];
    cmd.UserID = [self secUserId];
    cmd.TempPass = [self secPassword];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = LOGIN_TEMPPASS_COMMAND;
    cloudCommand.command = cmd;

    return cloudCommand;
}

- (GenericCommand *)makeAlmondListCommand {
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = ALMOND_LIST;
    cloudCommand.command = [AlmondListRequest new];
    return cloudCommand;
}

- (GenericCommand *)makeDeviceHashCommand:(NSString *)almondMac {
    DeviceDataHashRequest *deviceHashCommand = [[DeviceDataHashRequest alloc] init];
    deviceHashCommand.almondMAC = almondMac;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = DEVICEDATA_HASH;
    cloudCommand.command = deviceHashCommand;

    return cloudCommand;
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

#pragma mark - SingleTon management

- (SingleTon *)setupNetworkSingleton {
    NSLog(@"Setting up network singleton");

    [self tearDownNetworkSingleton];

    SingleTon *newSingleton = [SingleTon newSingletonWithResponseCallbackQueue:self.socketCallbackQueue dynamicCallbackQueue:self.socketDynamicCallbackQueue];
    newSingleton.delegate = self;
    newSingleton.connectionState = SDKCloudStatusInitializing;

    _networkSingleton = newSingleton;
    [newSingleton initNetworkCommunication];

    return newSingleton;
}

- (void)tearDownNetworkSingleton {
    DLog(@"Starting tear down of network singleton");
    SingleTon *old = self.networkSingleton;
    old.delegate = nil; // no longer interested in callbacks from this instance
    [old shutdown];

    DLog(@"Finished tear down of network singleton");
}

#pragma mark - SingleTonDelegate methods

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
    [SFIOfflineDataManager writeAlmondList:almondList];

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
    [SFIOfflineDataManager writeAlmondList:almondList];

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
        newAlmondList = [SFIOfflineDataManager deleteAlmond:deleted];
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
            [SFIOfflineDataManager writeAlmondList:currentList];

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
        [SFIOfflineDataManager purgeAll];
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
    NSString *storedHash = [SFIOfflineDataManager readHashList:currentMac];

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
        [SFIOfflineDataManager writeHashList:currentHash currentMAC:currentMac];
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
    if (!obj.isSuccessful) {
        return;
    }

    NSMutableArray *newDeviceList = obj.deviceList;
    NSString *almondMAC = obj.almondMAC;

    // Compare the list with device value list size and correct the list accordingly if any device was deleted
    // Read device value list from storage
    NSArray *oldDeviceValueList = [SFIOfflineDataManager readDeviceValueList:almondMAC];

    // Delete from the device value list
    NSMutableArray *newDeviceValueList = [[NSMutableArray alloc] init];

    // Devices have been removed
    BOOL removedDevices = [newDeviceList count] < [oldDeviceValueList count];

    if (removedDevices) {
        for (SFIDevice *currentDevice in newDeviceList) {
            for (SFIDeviceValue *offlineDeviceValue in oldDeviceValueList) {
                if (currentDevice.deviceID == offlineDeviceValue.deviceID) {
                    offlineDeviceValue.isPresent = TRUE;
                    break;
                }
            }
        }

        for (SFIDeviceValue *offlineDeviceValue in oldDeviceValueList) {
            if (offlineDeviceValue.isPresent) {
                [newDeviceValueList addObject:offlineDeviceValue];
            }
        }
    }

    // Update offline storage
    [SFIOfflineDataManager writeDeviceList:newDeviceList currentMAC:almondMAC];
    if (removedDevices) {
        [SFIOfflineDataManager writeDeviceValueList:newDeviceValueList currentMAC:almondMAC];
    }

    // Request values for devices
    [self asyncRequestDeviceValueList:almondMAC];

    NSArray *currentDevices = [SFIOfflineDataManager readDeviceList:almondMAC];
    [self diffDeviceListsAndNotify:almondMAC currentDevices:currentDevices newDevices:newDeviceList];
}

- (void)onDeviceListResponse:(id)sender {
    NSLog(@"Received device list response");

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceListResponse *obj = (DeviceListResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        NSLog(@"Device list response was not successful; stopping");
        return;
    }

    NSString *mac = obj.almondMAC;

    NSArray *currentDevices = [SFIOfflineDataManager readDeviceList:mac];
    NSArray *newDevices = obj.deviceList;

    [self diffDeviceListsAndNotify:mac currentDevices:currentDevices newDevices:newDevices];
}

// Diffs the old and new device lists, and if they are different posts a notification
- (void)diffDeviceListsAndNotify:(NSString *)mac currentDevices:(NSArray *)currentDevices newDevices:(NSArray *)newDevices {
    BOOL didChange;
    if (currentDevices.count != newDevices.count) {
        didChange = YES;
    }
    else {
        // see if the device ID's are all the same
        NSMutableSet *currentSet = [NSMutableSet set];
        NSMutableSet *newSet = [NSMutableSet set];

        for (SFIDevice *device in currentDevices) {
            unsigned int id_int = device.deviceID;
            [currentSet addObject:[NSNumber numberWithInt:id_int]];
        }

        for (SFIDevice *device in newDevices) {
            unsigned int id_int = device.deviceID;
            [newSet addObject:[NSNumber numberWithInt:id_int]];
        }

        if ([newSet isEqualToSet:currentSet]) {
            didChange = NO;
        }
        else {
            didChange = YES;
        }
    }

    // Save new list
    if (didChange) {
        NSLog(@"Device list response had differences");

        [SFIOfflineDataManager writeDeviceList:newDevices currentMAC:mac];

        // Request values for devices
        [self asyncRequestDeviceValueList:mac];

        // And tell the world there is a new list
        [self postNotification:kSFIDidChangeDeviceList data:mac];
    }
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

    [self processDeviceValueResponse:obj currentMAC:currentMAC];
}

- (void)onDeviceValueListChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceValueResponse *obj = (DeviceValueResponse *) [data valueForKey:@"data"];
    NSString *currentMAC = obj.almondMAC;

    [self processDeviceValueResponse:obj currentMAC:currentMAC];
}

- (void)processDeviceValueResponse:(DeviceValueResponse *)obj currentMAC:(NSString *)currentMAC {
    if (currentMAC.length == 0) {
        return;
    }

    NSMutableArray *cloudDeviceValueList = obj.deviceValueList;
    NSArray *currentDeviceValueList = [SFIOfflineDataManager readDeviceValueList:currentMAC];

    NSMutableArray *newDeviceValueList;
    if (currentDeviceValueList != nil) {
        for (SFIDeviceValue *currentValue in currentDeviceValueList) {
            for (SFIDeviceValue *cloudValue in cloudDeviceValueList) {
                if (currentValue.deviceID == cloudValue.deviceID) {
                    cloudValue.isPresent = YES;

                    NSMutableArray *currentValues = currentValue.knownValues;
                    NSMutableArray *cloudValues = cloudValue.knownValues;

                    for (SFIDeviceKnownValues *currentMobileKnownValue in currentValues) {
                        for (SFIDeviceKnownValues *currentCloudKnownValue in cloudValues) {
                            if (currentMobileKnownValue.index == currentCloudKnownValue.index) {
                                currentMobileKnownValue.value = currentCloudKnownValue.value;
                                break;
                            }
                        }
                    }
                    [currentValue setKnownValues:currentValues];
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
    [SFIOfflineDataManager writeDeviceValueList:newDeviceValueList currentMAC:currentMAC];

    [self postNotification:kSFIDidChangeDeviceValueList data:currentMAC];
}

@end
