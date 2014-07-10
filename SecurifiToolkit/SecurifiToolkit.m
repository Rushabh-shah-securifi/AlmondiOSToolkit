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
#import "SecurifiCloudResources-Prefix.pch"

#define SEC_SERVICE_NAME                    @"securifiy.login_service"
#define SEC_EMAIL                           @"com.securifi.email"
#define SEC_PWD                             @"com.securifi.pwd"
#define SEC_USER_ID                         @"com.securifi.userid"

#define SEC_USER_DEFAULT_LOGGED_IN_ONCE     @"kLoggedInOnce"

NSString *const kSFIDidCompleteLoginNotification = @"kSFIDidCompleteLoginNotification";
NSString *const kSFIDidLogoutNotification = @"kSFIDidLogoutNotification";
NSString *const kSFIDidLogoutAllNotification = @"kSFIDidLogoutAllNotification";
NSString *const kSFIDidUpdateAlmondList = @"kSFIDidUpdateAlmondList";
NSString *const kSFIDidChangeAlmondName = @"kSFIDidChangeAlmondName";

@interface SecurifiToolkit () <SingleTonDelegate>
@property (nonatomic, readonly) dispatch_queue_t socketCallbackQueue;
@property (nonatomic, readonly) dispatch_queue_t commandDispatchQueue;
@property (weak, nonatomic) SingleTon *networkSingleton;
@property BOOL initializing; // when TRUE an op is already in progress to set up a network
@property BOOL isShutdown;
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
        _commandDispatchQueue = dispatch_queue_create("command_dispatch", DISPATCH_QUEUE_SERIAL);

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(onReachabilityDidChange:) name:kSFIReachabilityChangedNotification object:nil];
        [center addObserver:self selector:@selector(onLoginResponse:) name:LOGIN_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onLogoutResponse:) name:LOGOUT_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onLogoutAllResponse:) name:LOGOUT_ALL_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onDynamicAlmondListAdd:) name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(dynamicAlmondListDeleteCallback:) name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(dynamicAlmondNameChangeCallback:) name:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER object:nil];
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
}

- (SingleTon*)setupNetworkSingleton {
    NSLog(@"Setting up network singleton");

    [self tearDownNetworkSingleton];

    SingleTon *newSingleton = [SingleTon newSingleton:self.socketCallbackQueue];
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
            return YES;

        case SDKCloudStatusUninitialized:
        case SDKCloudStatusInitializing:
        case SDKCloudStatusNetworkDown:
        case SDKCloudStatusCloudConnectionShutdown:
        default:
            return NO;

    }
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

- (void)initSDK {
    if (self.isShutdown) {
        DLog(@"INIT SDK. Already shutdown. Returning.");
        return;
    }

    if (self.initializing) {
        DLog(@"INIT SDK. Already initializing.");
        return;
    }

    [[SFIDatabaseUpdateService sharedInstance] startDatabaseUpdateService];
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
    self.initializing = YES;
    NSLog(@"INIT SDK");

    SingleTon *singleTon = [self setupNetworkSingleton];

    // After setting up the network, we need to do some basic things
    // 1. send sanity cmd to test the socket
    // 2. logon
    // 3. update the devices list
    // 4. check hashes etc.

    GenericCommand *cmd;
    BOOL cmdSendSuccess;

    // Send sanity command testing network connection
    cmd = [self makeCloudSanityCommand];
    cmdSendSuccess = [self internalSendToCloud:singleTon command:cmd];
    if (!cmdSendSuccess) {
        NSLog(@"%s: init SDK: send sanity failed:", __PRETTY_FUNCTION__);
        singleTon.connectionState = SDKCloudStatusNetworkDown;
        self.initializing = NO;
        return;
    }

    DLog(@"%s: init SDK: send sanity successful", __PRETTY_FUNCTION__);
    DLog(@"%s: session started: %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());

    // If no logon credentials, then initialization is completed.
    if (![self hasLoginCredentials]) {
        DLog(@"%s: no logon credentials", __PRETTY_FUNCTION__);
        singleTon.connectionState = SDKCloudStatusNotLoggedIn;
        self.initializing = NO;

        // This event is very important because it will prompt the UI not to wait for events and immediately show a logon screen
        [self postNotification:kSFIDidLogoutNotification data:nil];
        return;
    }

    // Send logon credentials
    DLog(@"%s: Sending temp pass credentials", __PRETTY_FUNCTION__);
    singleTon.connectionState = SDKCloudStatusLoginInProcess;

    cmd = [self makeTempPassLoginCommand];
    cmdSendSuccess = [self internalSendToCloud:singleTon command:cmd];
    if (!cmdSendSuccess) {
        DLog(@"%s: failed on sending login command", __PRETTY_FUNCTION__);
        singleTon.connectionState = SDKCloudStatusNetworkDown;
    }
    self.initializing = NO;


}

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

    [[SFIDatabaseUpdateService sharedInstance] stopDatabaseUpdateService];
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


- (void)asyncSendToCloud:(SingleTon *)socket command:(GenericCommand *)command {
    if (socket == nil || (!socket.isStreamConnected && !self.initializing)) {
        // Set up network and wait
        //
        NSLog(@"Waiting to initialize socket");
        [self _asyncInitSDK];
    }

    BOOL success = [self internalSendToCloud:socket command:command];
    if (success) {
        DLog(@"[Generic cmd: %d] send success", command.commandType);
    }
    else {
        DLog(@"[Generic cmd: %d] send error", command.commandType);
    }
}

- (void)asyncSendToCloud:(GenericCommand*)command {
    if (self.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }

    [self asyncSendToCloud:self.networkSingleton command:command];
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
    [defaults setBool:YES forKey:SEC_USER_DEFAULT_LOGGED_IN_ONCE];

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

- (void)onLoginResponse:(NSNotification*)notification {
    NSDictionary *info = notification.userInfo;
    LoginResponse *res = info[@"data"];

    if (res.isSuccessful) {
        // The response will contain the TempPass token, which we store in the keychain.
        [self storeLoginCredentials:res];
    }
    else {
        // Ensure all credentials are cleared
        [self tearDownLoginSession];
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

#pragma mark - Almond Lists

#define kPREF_CURRENT_ALMOND @"kAlmondCurrent"

- (void)removeCurrentAlmond {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kPREF_CURRENT_ALMOND];
    [prefs removeObjectForKey:COLORCODE];
    [prefs synchronize];
}

- (void)setCurrentAlmond:(SFIAlmondPlus *)almond colorCodeIndex:(int)assignedColor {
    almond.colorCodeIndex = assignedColor;

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:almond];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:kPREF_CURRENT_ALMOND];
    [defaults setInteger:assignedColor forKey:COLORCODE];
    [defaults synchronize];
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

- (void)asyncLoadAlmondList {
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = ALMOND_LIST;
    cloudCommand.command = [AlmondListRequest new];

    [self asyncSendToCloud:cloudCommand];
}

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

#pragma mark - Network reconnection handling

- (void)onReachabilityDidChange:(id)notification {
    DLog(@"changed to reachable");
}

#pragma mark - Keychain Access

- (void)clearSecCredentials {
    [KeyChainWrapper removeEntryForUserEmail:SEC_EMAIL forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_PWD forService:SEC_SERVICE_NAME];
    [KeyChainWrapper removeEntryForUserEmail:SEC_USER_ID forService:SEC_SERVICE_NAME];
}

- (BOOL)hasLoginCredentials {
    // Keychains persist after an app is deleted. Therefore, to ensure credentials are "wiped out",
    // we keep track of whether this is a new install by storing a value in user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL logged_in_once = [defaults boolForKey:SEC_USER_DEFAULT_LOGGED_IN_ONCE];

    return logged_in_once && [self hasSecEmail] && [self hasSecPassword];
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

#pragma mark - SingleTonDelegate methods

- (void)singletTonCloudConnectionDidClose:(SingleTon *)singleTon {
    if (singleTon == self.networkSingleton) {
        DLog(@"%s: posting NETWORK_DOWN_NOTIFIER on closing cloud connection", __PRETTY_FUNCTION__);
        [self postNotification:NETWORK_DOWN_NOTIFIER data:nil];
    }
}

#pragma mark - Sending and Network

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

#pragma mark - Dynamic Updates

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

    //Write Almond List offline - New list with added almond
    NSArray *almondList = obj.almondPlusMACList;
    [SFIOfflineDataManager writeAlmondList:almondList];

    // Manage the "Current selected Almond" value
    if (almondList.count == 0) {
        [self removeCurrentAlmond];
    }
    else if (almondList.count == 1) {
        SFIAlmondPlus *currentAlmond = almondList[0];
        [self setCurrentAlmond:currentAlmond colorCodeIndex:0];
    }
    else {
        BOOL currentStillInList = NO;
        SFIAlmondPlus *current = [self currentAlmond];

        if (current) {
            for (SFIAlmondPlus *almond in almondList) {
                if ([almond.almondplusMAC isEqualToString:current.almondplusMAC]) {
                    currentStillInList = YES;
                    break;
                }
            }
        }

        if (!currentStillInList) {
            // Just pick the first one in this case
            SFIAlmondPlus *currentAlmond = almondList[0];
            [self setCurrentAlmond:currentAlmond colorCodeIndex:0];
        }
    }

    [self postNotification:kSFIDidUpdateAlmondList data:nil];
}

- (void)dynamicAlmondListDeleteCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    
    AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        return;
    }
    
    NSArray *deletedAlmondList = obj.almondPlusMACList;
    if (deletedAlmondList.count == 0) {
        return;
    }
    SFIAlmondPlus *deletedAlmond = deletedAlmondList[0];

    // Diff the current list, removing the deleted almond
    NSArray *currentAlmondList = [SFIOfflineDataManager readAlmondList];
    NSMutableArray *newAlmondList = [[NSMutableArray alloc] init];
    //
    // Update Almond List
    for (SFIAlmondPlus *currentOfflineAlmond in currentAlmondList) {
        if (![currentOfflineAlmond.almondplusMAC isEqualToString:deletedAlmond.almondplusMAC]) {
            //Add the current Almond from list except the deleted one
            [newAlmondList addObject:currentOfflineAlmond];
        }
    }

    [SFIOfflineDataManager writeAlmondList:newAlmondList];
    [SFIOfflineDataManager deleteAlmond:deletedAlmond];

    // Manage the "Current Almond"
    if (newAlmondList.count == 0) {
        [self removeCurrentAlmond];
    }
    else if (newAlmondList.count == 1) {
        SFIAlmondPlus *newAlmond = newAlmondList[0];
        [self setCurrentAlmond:newAlmond colorCodeIndex:0];
    }
    else {
        SFIAlmondPlus *plus = [self currentAlmond];
        if ([plus.almondplusMAC isEqualToString:deletedAlmond.almondplusMAC]) {
            [self removeCurrentAlmond];
        }
    }

    [self postNotification:kSFIDidUpdateAlmondList data:nil];
}

- (void)dynamicAlmondNameChangeCallback:(id)sender {
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
                [self setCurrentAlmond:almond colorCodeIndex:plus.colorCodeIndex];
            }

            // Tell the world so they can update their view
            [self postNotification:kSFIDidChangeAlmondName data:almond];

            return;
        }
    }
}



@end
