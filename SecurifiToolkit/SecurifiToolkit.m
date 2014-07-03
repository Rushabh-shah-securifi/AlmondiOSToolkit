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

#define SEC_SERVICE_NAME                    @"securifiy.login_service"
#define SEC_EMAIL                           @"com.securifi.email"
#define SEC_PWD                             @"com.securifi.pwd"
#define SEC_USER_ID                         @"com.securifi.userid"

#define SEC_USER_DEFAULT_LOGGED_IN_ONCE     @"kLoggedInOnce"

@interface SecurifiToolkit () <SingleTonDelegate>
@property (nonatomic, readonly) NSObject *syncLocker;
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
        _syncLocker = [NSObject new];

        _socketCallbackQueue = dispatch_queue_create("socket_callback", DISPATCH_QUEUE_CONCURRENT);
        _commandDispatchQueue = dispatch_queue_create("command_dispatch", DISPATCH_QUEUE_SERIAL);

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(onReachabilityDidChange:) name:kSFIReachabilityChangedNotification object:nil];
        [center addObserver:self selector:@selector(onLoginResponse:) name:LOGIN_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onLogoutResponse:) name:LOGOUT_NOTIFIER object:nil];
        [center addObserver:self selector:@selector(onLogoutAllResponse:) name:LOGOUT_ALL_NOTIFIER object:nil];
    }

    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kSFIReachabilityChangedNotification object:nil];
    [center removeObserver:self name:LOGIN_NOTIFIER object:nil];
    [center removeObserver:self name:LOGOUT_NOTIFIER object:nil];
    [center removeObserver:self name:LOGOUT_ALL_NOTIFIER object:nil];
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
    NSLog(@"Starting tear down of network singleton");
    SingleTon *old = self.networkSingleton;
    old.delegate = nil; // no longer interested in callbacks from this instance
    [old shutdown];
    NSLog(@"Finished tear down of network singleton");
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
        NSLog(@"INIT SDK. Already shutdown. Returning.");
        return;
    }

    if (self.initializing) {
        NSLog(@"INIT SDK. Already initializing.");
        return;
    }
    self.initializing = YES;
    NSLog(@"INIT SDK");

    __weak SecurifiToolkit *block_self = self;

    //Start a Async task of sending Sanity command and TempPassCommand
    //Async task will send command and will generate respective events
    dispatch_async(self.socketCallbackQueue, ^(void) {
        block_self.initializing = YES;

        SingleTon *singleTon = [block_self setupNetworkSingleton];

        // Send sanity command testing network connection
        GenericCommand *cmd = [block_self makeCloudSanityCommand];

        NSError *error;
        BOOL success = [block_self internalSendToCloud:singleTon command:cmd error:&error];
        if (!success) {
            singleTon.connectionState = SDKCloudStatusNetworkDown;
            NSLog(@"%s: init SDK: send sanity failed: %@", __PRETTY_FUNCTION__, error.localizedDescription);
            block_self.initializing = NO;
            return;
        }

        NSLog(@"%s: init SDK: send sanity successful", __PRETTY_FUNCTION__);
        NSLog(@"%s: session started: %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());

        //Send Temppass command
        if ([block_self hasLoginCredentials]) {
            @try {
                [block_self sendLoginCommand:singleTon];
            }
            @catch (NSException *e) {
                singleTon.connectionState = SDKCloudStatusNetworkDown;
                NSLog(@"%s: Exception throw on init sdk. Network down: %@", __PRETTY_FUNCTION__, e.reason);
            }
        }
        else {
            NSLog(@"%s: no logon credentials", __PRETTY_FUNCTION__);
            singleTon.connectionState = SDKCloudStatusNotLoggedIn;
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFIER object:block_self userInfo:nil];
        }

        block_self.initializing = NO;
    });
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
}

#pragma mark - Command dispatch

typedef void (^SendCompletion)(BOOL success, NSError *error);

- (void)asyncSendToCloud:(SingleTon*)socket command:(GenericCommand*)command completion:(SendCompletion)callback {
    if (!socket.isStreamConnected && !self.initializing) {
        [self initSDK];
        socket = self.networkSingleton;
    }

    __strong GenericCommand *block_command = command;
    __weak SingleTon *block_socket = socket;
    __weak SecurifiToolkit *block_self = self;

    dispatch_async(self.commandDispatchQueue, ^() {
        NSError *outError;
        BOOL success = [block_self internalSendToCloud:block_socket command:block_command error:&outError];
        if (success) {
            NSLog(@"[Generic cmd: %d] send success", block_command.commandType);
        }
        else {
            NSLog(@"[Generic cmd: %d] send error: %@", block_command.commandType, outError.localizedDescription);

            if (block_socket.disableNetworkDownNotification == NO) {
                NSLog(@"%s: Posting NETWORK_DOWN_NOTIFIER, error=%@", __PRETTY_FUNCTION__, outError.localizedDescription);
                [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:nil userInfo:nil];
            }
        }

        if (callback) {
            callback(success, outError);
        }
    });
}

- (void)asyncSendToCloud:(GenericCommand*)command {
    if (self.isShutdown) {
        NSLog(@"SDK is shutdown. Returning.");
        return;
    }

    [self asyncSendToCloud:self.networkSingleton command:command completion:nil];
}

#pragma mark - Cloud Logon

- (void)asyncSendLoginWithEmail:(NSString *)email password:(NSString *)password {
    if (self.isShutdown) {
        NSLog(@"SDK is shutdown. Returning.");
        return;
    }

    [self clearSecCredentials];
    [self setSecEmail:email];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:SEC_USER_DEFAULT_LOGGED_IN_ONCE];

    Login *loginCommand = [[Login alloc] init];
    loginCommand.UserID = [NSString stringWithString:email];
    loginCommand.Password = [NSString stringWithString:password];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = LOGIN_COMMAND;
    cloudCommand.command = loginCommand;

    [self asyncSendToCloud:cloudCommand];
}

- (NSString *)loginEmail {
    return [self secEmail];
}

- (void)sendLoginCommand:(SingleTon *)singleTon {
    LoginTempPass *cmd = [self makeTempPassLoginCommand];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = LOGIN_TEMPPASS_COMMAND;
    cloudCommand.command = cmd;

    NSError *error_2;
    BOOL success = [self internalSendToCloud:singleTon command:cloudCommand error:&error_2];
    if (!success) {
        NSLog(@"%s: Error init sdk: %@", __PRETTY_FUNCTION__, error_2.localizedDescription);
        singleTon.connectionState = SDKCloudStatusNetworkDown;
    }
    else {
        NSLog(@"%s: login command sent", __PRETTY_FUNCTION__);
        singleTon.connectionState = SDKCloudStatusLoginInProcess;
    }
}

- (void)storeLoginCredentials:(LoginResponse *)obj {
    NSString *tempPass = obj.tempPass;
    NSString *userId = obj.userID;

    [self setSecPassword:tempPass];
    [self setSecUserId:userId];
}

- (void)removeLoginCredentials {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SFIDatabaseUpdateService stopDatabaseUpdateService];
    });

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
    [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
    [prefs removeObjectForKey:COLORCODE];
    [prefs synchronize];

    [self clearSecCredentials];

    //Delete files
    [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
    [SFIOfflineDataManager deleteFile:HASH_FILENAME];
    [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
    [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];

    [prefs synchronize];
}

- (void)onLoginResponse:(NSNotification*)notification {
    NSDictionary *info = notification.userInfo;
    LoginResponse *res = info[@"data"];

    if (res == nil) {
        [self removeLoginCredentials];
    }
    else if (res.isSuccessful) {
        [self storeLoginCredentials:res];
    }
    else {
        [self removeLoginCredentials];
    }
}

- (void)onLogoutResponse:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    LoginResponse *res = info[@"data"];
    if (res.isSuccessful) {
        [self removeLoginCredentials];
    }
}

- (void)onLogoutAllResponse:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    LoginResponse *res = info[@"data"];
    if (res.isSuccessful) {
        [self removeLoginCredentials];
    }
}

- (void)asyncSendLogout {
    if (self.isShutdown) {
        NSLog(@"SDK is shutdown. Returning.");
        return;
    }

    GenericCommand *cmd = [[GenericCommand alloc] init];
    cmd.commandType = LOGOUT_COMMAND;
    cmd.command = nil;

    [self asyncSendToCloud:cmd];
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

- (LoginTempPass *)makeTempPassLoginCommand {
    LoginTempPass *cmd = [[LoginTempPass alloc] init];
    cmd.UserID = [self secUserId];
    cmd.TempPass = [self secPassword];

    return cmd;
}

#pragma mark - Network reconnection handling

- (void)onReachabilityDidChange:(id)notification {
        NSLog(@"changed to reachable");
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
/*
    @synchronized (self.syncLocker) {
        if (singleTon == self.networkSingleton) {
            NSLog(@"%s: ejecting SingleTon on closing of cloud connection", __PRETTY_FUNCTION__);
            self.networkSingleton = nil;
        }
    }
*/
}

#pragma mark - Sending and Network

- (BOOL)internalSendToCloud:(SingleTon *)socket command:(id)sender error:(NSError **)outError {
    NSLog(@"%s: Waiting to enter sync block",__PRETTY_FUNCTION__);
    @synchronized (self.syncLocker) {
        NSLog(@"%s: Entered sync block",__PRETTY_FUNCTION__);

        // Wait for connection establishment if need be.
        if (!socket.isStreamConnected) {
            NSLog(@"Waiting for connection establishment");
            [socket waitForConnectionEstablishment];
            NSLog(@"Done waiting for connection establishment");

            if (!socket.isStreamConnected) {
                NSLog(@"Stream died on connection");
                NSMutableDictionary *details = [NSMutableDictionary dictionary];
                [details setValue:@"Securifi - Send Error" forKey:NSLocalizedDescriptionKey];
                *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];
                return NO;
            }
        }

        GenericCommand *obj = (GenericCommand *) sender;

        NSString *commandPayload;
        unsigned int commandLength = 0;
        unsigned int commandType = 0;
        NSData *sendCommandPayload;

        @try {
            switch (obj.commandType) {
                case LOGIN_COMMAND: {
                    /* Check if User is already logged in [ if he has received loginResponse command */
                    if (socket.isLoggedIn == YES) {
                        //Post Callback that you are logged in
                        LoginResponse *object = [[LoginResponse alloc] init];
                        object.isSuccessful = NO;
                        object.userID = nil;
                        object.tempPass = nil;
                        [object setReason:@"Already Loggedin"];

                        NSDictionary *data = @{@"data" : object};

                        //Send Object
                        //NSLog(@"Before Notification");
                        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFIER object:self userInfo:data];

                        return YES;
                    }
                    else {
                        // [SNLog Log:@"%s: Sending LOGIN COMMAND",__PRETTY_FUNCTION__];
                        Login *ob1 = (Login *) obj.command;
                        commandPayload = [NSString stringWithFormat:FRESH_LOGIN_REQUEST_XML, ob1.UserID, ob1.Password];


                        commandType = (uint32_t) htonl(LOGIN_COMMAND);

                        sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                        commandLength = (uint32_t) htonl([sendCommandPayload length]);
                    }

                    break;
                }
                case LOGIN_TEMPPASS_COMMAND: {
                    // [SNLog Log:@"%s: Sending LOGIN_TEMPPASS_COMMAND",__PRETTY_FUNCTION__];
                    LoginTempPass *ob1 = (LoginTempPass *) obj.command;
                    commandPayload = [NSString stringWithFormat:LOGIN_REQUEST_XML, ob1.UserID, ob1.TempPass];

                    //Cloud has switch for both command as LOGIN_COMMAND
                    commandType = (uint32_t) htonl(LOGIN_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case LOGOUT_COMMAND: {
                    // [SNLog Log:@"%s: Sending LOGOUT COMMAND",__PRETTY_FUNCTION__];
//                    Logout *ob1 = (Logout *)obj.command;
                    commandPayload = LOGOUT_REQUEST_XML;
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    //Cloud has switch for both command as LOGIN_COMMAND
                    commandType = (uint32_t) htonl(LOGOUT_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    //PY 250214 - Logout Response will be received now
                    //Remove preferences
//                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//
//                    // [SNLog Log:@"%s: TempPass - %@ \n UserID - %@",__PRETTY_FUNCTION__,[prefs objectForKey:tmpPwdKey], [prefs objectForKey:usrIDKey]];
//                    [prefs removeObjectForKey:tmpPwdKey];
//                    [prefs removeObjectForKey:usrIDKey];
//                    [prefs synchronize];
//                    // [SNLog Log:@"%s: After delete\n",__PRETTY_FUNCTION__];
//                    // [SNLog Log:@"%s: TempPass - %@ \n UserID - %@",__PRETTY_FUNCTION__,[prefs objectForKey:tmpPwdKey], [prefs objectForKey:usrIDKey]];
//
//                    [socket setConnectionState:NOT_LOGGED_IN];
//
//                    //PY 160913 - Reconnect to cloud
//                    id ret = [[SecurifiToolkit sharedInstance] initSDKCloud];
//                    if (ret == nil)
//                    {
//                        // [SNLog Log:@"%s: APP Delegate : SDKInit Error",__PRETTY_FUNCTION__];
//                    }
//

                    break;
                }
                case SIGNUP_COMMAND: {
                    // [SNLog Log:@"%s: Sending SIGNUP Command",__PRETTY_FUNCTION__];
                    Signup *ob1 = (Signup *) obj.command;
                    commandPayload = [NSString stringWithFormat:SIGNUP_REQUEST_XML, ob1.UserID, ob1.Password];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(SIGNUP_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case CLOUD_SANITY: {
                    // [SNLog Log:@"%s: Sending CLOUD_SANITY Command",__PRETTY_FUNCTION__];
                    commandPayload = CLOUDSANITY_REQUEST_XML;//[NSString stringWithFormat:CLOUDSANITY_REQUEST_XML];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(CLOUD_SANITY);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case AFFILIATION_CODE_REQUEST: {
                    // [SNLog Log:@"%s: Sending Affiliation Code request",__PRETTY_FUNCTION__];
                    AffiliationUserRequest *affiliationObj = (AffiliationUserRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:AFFILIATION_CODE_REQUEST_XML, affiliationObj.Code];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(AFFILIATION_CODE_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case LOGOUT_ALL_COMMAND: {
                    //PY 160913 - Logout all command
                    // [SNLog Log:@"%s: Sending Logout request",__PRETTY_FUNCTION__];
                    //            <root>
                    //            <LogoutAll>
                    //            <EmailID>validemail@mycompany.com</EmailID>
                    //            <Password>originalpassword</Password>
                    //            </LogoutAll>
                    //            </root>

                    LogoutAllRequest *logoutAllObj = (LogoutAllRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:LOGOUT_ALL_REQUEST_XML, logoutAllObj.UserID, logoutAllObj.Password];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(LOGOUT_ALL_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case ALMOND_LIST: {
                    //PY 160913 - almond list command
                    // [SNLog Log:@"%s: Sending almond list request",__PRETTY_FUNCTION__];
                    // <root></root>

                    //AlmondListRequest *logoutAllObj = (AlmondListRequest *)obj.command;
                    commandPayload = ALMOND_LIST_REQUEST_XML; //[NSString stringWithFormat:];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(ALMOND_LIST);


                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case DEVICEDATA_HASH: {
                    //PY 170913 - Device Hash command
                    // [SNLog Log:@"%s: Sending Device Hash request",__PRETTY_FUNCTION__];
                    //            <root><DeviceDataHash>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceDataHash></root>

                    DeviceDataHashRequest *deviceDataHashObj = (DeviceDataHashRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_DATA_HASH_REQUEST_XML, deviceDataHashObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(DEVICEDATA_HASH);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case DEVICEDATA: {
                    //PY 170913 - Device Data command
                    // [SNLog Log:@"%s: Sending Device Data request",__PRETTY_FUNCTION__];
                    //            <root><DeviceData>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceData></root>

                    DeviceListRequest *deviceDataObj = (DeviceListRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_DATA_REQUEST_XML, deviceDataObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(DEVICEDATA);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case DEVICE_VALUE: {
                    //PY 190913 - Device Value command
                    // [SNLog Log:@"%s: Sending DeviceValue request",__PRETTY_FUNCTION__];
                    //            <root><DeviceValue>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceValue></root>

                    DeviceValueRequest *deviceValueObj = (DeviceValueRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_VALUE_REQUEST_XML, deviceValueObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(DEVICE_VALUE);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case MOBILE_COMMAND: {
                    //PY 200913 - Mobile command
                    // [SNLog Log:@"%s: Sending MobileCommand request",__PRETTY_FUNCTION__];
                    /* <root><MobileCommand>
                     * <AlmondplusMAC>251176214925585</AlmondplusMAC>
                     * <Device ID=”6”>
                     * <NewValue Index=”1”>NewTextValue</NewValue>
                     * </Device>
                     * <MobileInternalIndex>324</MobileInternalIndex>
                     * </MobileCommand></root>
                     */

                    MobileCommandRequest *mobileCommandObj = (MobileCommandRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:MOBILE_COMMAND_REQUEST_XML, mobileCommandObj.almondMAC, mobileCommandObj.deviceID, mobileCommandObj.indexID, mobileCommandObj.changedValue, mobileCommandObj.internalIndex];
                    NSLog(@"Command length %lu", (unsigned long) [commandPayload length]);


                    //PY 290114: Replacing the \" (backslash quotes) in the string to just " (quotes).
                    //When we are using string obfuscation the decoded string has the \ escape character with it.
                    //The cloud is unable to handle it and rejects the command.
                    //Add this line to any XML  string with has \" in it. For example: <Device ID=\"%@\">
                    commandPayload = [self stringByRemovingEscapeCharacters:commandPayload];

                    commandType = (uint32_t) htonl(MOBILE_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    NSLog(@"Payload Command length %lu", (unsigned long) [sendCommandPayload length]);
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case GENERIC_COMMAND_REQUEST: {
                    //PY 291013 - Generic command
//                    <root>
//                    <GenericCommandRequest>
//                    <AlmondplusMAC>251176214925585</AlmondplusMAC>
//                    <ApplicationID></ApplicationID>
//                    <MobileInternalIndex>1</MobileInternalIndex>
//                    <Data>
//                    [Base64Encoded]
//                    <root><Reboot>1</Reboot></root>[Base64Encoded]
//                    </Data>
//                    </GenericCommandRequest>
//                    </root>
                    // [SNLog Log:@"%s: Sending GenricCommand request",__PRETTY_FUNCTION__];

                    GenericCommandRequest *genericCommandObj = (GenericCommandRequest *) obj.command;

                    //Encode data to Base64
                    NSData *dataToEncode = [genericCommandObj.data dataUsingEncoding:NSUTF8StringEncoding];
                    NSData *encodedData = [dataToEncode base64EncodedDataWithOptions:0];
                    NSString *encodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];

                    commandPayload = [NSString stringWithFormat:GENERIC_COMMAND_REQUEST_XML, genericCommandObj.almondMAC, genericCommandObj.applicationID, genericCommandObj.mobileInternalIndex, encodedString];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(GENERIC_COMMAND_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                    //PY 011113 - Reactivation email command
                case VALIDATE_REQUEST: {
                    // [SNLog Log:@"%s: Sending VALIDATE request",__PRETTY_FUNCTION__];
                    /*
                     <root>
                     <ValidateAccountRequest>
                     <EmailID>xyz@abc.com</EmailID>
                     </ValidateAccountRequest>
                     </root>
                     */

                    ValidateAccountRequest *validateObj = (ValidateAccountRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:VALIDATE_REQUEST_XML, validateObj.email];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(VALIDATE_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case RESET_PASSWORD_REQUEST: {
                    // [SNLog Log:@"%s: Sending RESET_PASSWORD request",__PRETTY_FUNCTION__];
                    /*
                     <root>
                     <ResetPasswordRequest>
                     <EmailID>xyz@abc.com</EmailID>
                     </ResetPasswordRequest>
                     </root>
                     */

                    ResetPasswordRequest *resetPwdObj = (ResetPasswordRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:RESET_PWD_REQUEST_XML, resetPwdObj.email];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(RESET_PASSWORD_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                    //PY 150114 - Forced Data Update
                case DEVICE_DATA_FORCED_UPDATE_REQUEST: {
                    // [SNLog Log:@"%s: Sending DEVICE_DATA_FORCED_UPDATE_REQUEST request",__PRETTY_FUNCTION__];
                    /*
                    <root><DeviceDataForcedUpdate>
                    <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    <MobileInternalIndex>1234</MobileInternalIndex>
                    </DeviceDataForcedUpdate></root>
                     */

                    SensorForcedUpdateRequest *forcedUpdateObj = (SensorForcedUpdateRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:SENSOR_FORCED_UPDATE_REQUEST_XML, forcedUpdateObj.almondMAC, forcedUpdateObj.mobileInternalIndex];
                    //commandLength = (uint32_t)htonl([commandPayload length]);


                    //Send as Command 61
                    commandType = (uint32_t) htonl(MOBILE_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case SENSOR_CHANGE_REQUEST: {
                    //PY 200114 - Sensor name and location change
                    //[SNLog Log:@"%s: Sending SENSOR_CHANGE_REQUEST request",__PRETTY_FUNCTION__];

                    /*
                     <root><SensorChange>
                     <AlmondplusMAC>251176214925585</AlmondplusMAC>
                     <Device ID=”6”>
                     <NewName optional>MyGreatSensor</NewName>
                     <NewLocation optional>Buckingham Palace</NewLocation>
                     </Device>
                     <MobileInternalIndex>324</MobileInternalIndex>
                     </SensorChange></root>
                     */

                    SensorChangeRequest *sensorChangeObj = (SensorChangeRequest *) obj.command;

                    if (sensorChangeObj.changedName != nil && sensorChangeObj.changedLocation == nil) {
                        commandPayload = [NSString stringWithFormat:SENSOR_CHANGE_NAME_REQUEST_XML, sensorChangeObj.almondMAC, sensorChangeObj.deviceID, sensorChangeObj.changedName, sensorChangeObj.mobileInternalIndex];
                    }
                    else if (sensorChangeObj.changedLocation != nil && sensorChangeObj.changedName == nil) {
                        commandPayload = [NSString stringWithFormat:SENSOR_CHANGE_LOCATION_REQUEST_XML, sensorChangeObj.almondMAC, sensorChangeObj.deviceID, sensorChangeObj.changedLocation, sensorChangeObj.mobileInternalIndex];
                    }
                    else {
                        commandPayload = [NSString stringWithFormat:SENSOR_CHANGE_REQUEST_XML, sensorChangeObj.almondMAC, sensorChangeObj.deviceID, sensorChangeObj.changedName, sensorChangeObj.changedLocation, sensorChangeObj.mobileInternalIndex];
                    }
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    //PY 290114: Replacing the \" (backslash quotes) in the string to just " (quotes).
                    //When we are using string obfuscation the decoded string has the \ escape character with it.
                    //The cloud is unable to handle it and rejects the command.
                    //Add this line to any XML  string with has \" in it. For example: <Device ID=\"%@\">
                    commandPayload = [self stringByRemovingEscapeCharacters:commandPayload];

                    NSLog(@"Command Payload %@: ", commandPayload);

                    //Send as Command 61
                    commandType = (uint32_t) htonl(MOBILE_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }

                default:
                    break;
            }
            //isLoggedin might be set to 1 if we miss the TCP termination callback
            //Check on each write if it fails set isLoggedin to

            NSLog(@"@Payload being sent: %@", commandPayload);

            NSStreamStatus type;
            do {
                type = [socket.outputStream streamStatus];
                // [SNLog Log:@"%s: Socket in opening state.. wait..",__PRETTY_FUNCTION__];
            } while (type == NSStreamStatusOpening);

            [socket.outputStream streamStatus];

            // [SNLog Log:@"%s: Out of stream type check loop : %d",__PRETTY_FUNCTION__,type];

            if (socket.isStreamConnected && socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [socket.outputStream write:(uint8_t *) &commandLength maxLength:4]) {
                    socket.isLoggedIn = NO;
                    NSMutableDictionary *details = [NSMutableDictionary dictionary];
                    [details setValue:@"Securifi Length - Send Error" forKey:NSLocalizedDescriptionKey];
                    *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];

                    socket.sendCommandFail = YES;
                    socket.isStreamConnected = NO;

                    return NO;
                }
            }

            //stream status
            if (socket.isStreamConnected && socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [socket.outputStream write:(uint8_t *) &commandType maxLength:4]) {
                    socket.isLoggedIn = NO;
                    NSMutableDictionary *details = [NSMutableDictionary dictionary];
                    [details setValue:@"Securifi Command Type - Send Error" forKey:NSLocalizedDescriptionKey];
                    *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];

                    socket.sendCommandFail = YES;
                    socket.isStreamConnected = NO;

                    return NO;
                }
            }

            if (socket.isStreamConnected && socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [socket.outputStream write:[sendCommandPayload bytes] maxLength:[sendCommandPayload length]]) {
                    socket.isLoggedIn = NO;
                    NSMutableDictionary *details = [NSMutableDictionary dictionary];
                    [details setValue:@"Securifi Payload - Send Error" forKey:NSLocalizedDescriptionKey];
                    *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];

                    socket.sendCommandFail = YES;
                    socket.isStreamConnected = NO;

                    return NO;
                }
            }

            NSLog(@"%s: Exiting sync block",__PRETTY_FUNCTION__);

            if (socket.outputStream == nil) {
                NSLog(@"%s: Output stream is nil, out=%@", __PRETTY_FUNCTION__, socket.outputStream);
                return NO;
            }
            else if (!socket.isStreamConnected) {
                NSLog(@"%s: Output stream is not connected, out=%@", __PRETTY_FUNCTION__, socket.outputStream);
                return NO;
            }
            else if (socket.outputStream.streamStatus == NSStreamStatusError) {
                NSLog(@"%s: Output stream has error status, out=%@", __PRETTY_FUNCTION__, socket.outputStream);
                return NO;
            }
            else {
                NSLog(@"%s: sent command to cloud: TIME => %f ", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                return YES;
            }
        }
        @catch (NSException *e) {
            NSLog(@"%s: Exception : %@",__PRETTY_FUNCTION__, e.reason);
            @throw;
        }
    }//synchronized

}

- (NSString *)stringByRemovingEscapeCharacters:(NSString *)inputString {
    NSMutableString *s = [NSMutableString stringWithString:inputString];
    [s replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    //[s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}


@end
