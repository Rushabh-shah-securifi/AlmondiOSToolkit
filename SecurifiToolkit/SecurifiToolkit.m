//
//  SecurifiToolkit.m
//  SecurifiToolkit

//  Created by Nirav Uchat on 7/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.

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
#import "Signup.h"
#import "ValidateAccountRequest.h"
#import "AlmondListRequest.h"
#import "DeviceDataHashRequest.h"
#import "AffiliationUserRequest.h"
#import "ResetPasswordRequest.h"
#import "ClientParser.h"
#import "SceneParser.h"
#import "RuleParser.h"
#import "DeviceParser.h"
#import "DataBaseManager.h"
#import "RouterParser.h"
#import "BrowsingHistoryDataBase.h"
#import "ConnectionStatus.h"
#import "CreateJSON.h"
#import "HTTPRequest.h"
#import "AlmondListManagement.h"
#import "KeyChainAccess.h"
#import "AlmondManagement.h"
#import "CompleteDB.h"
#import "LocalNetworkManagement.h"
#import "WebSocketEndpoint.h"

#define kDASHBOARD_HELP_SHOWN                               @"kDashboardHelpShown"
#define kDEVICES_HELP_SHOWN                                 @"kDevicesHelpShown"
#define kRULES_HELP_SHOWN                                   @"kRulesHelpShown"
#define kSCENES_HELP_SHOWN                                  @"kScenesHelpShown"
#define kWIFI_HELP_SHOWN                                    @"kWifiHelpShown"
#define kWIFI_TRIGGER_HELP_SHOWN                            @"kWifiTriggerHelpShown"


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
NSString *const kSFINotificationPreferencesListDidChange = @"kSFINotificationPreferencesListDidChange";
NSString *const kSFINotificationPreferenceChangeActionAdd = @"add";
NSString *const kSFINotificationPreferenceChangeActionDelete = @"delete";

// ===============================================================================================

@interface SecurifiToolkit () <SFIDeviceLogStoreDelegate, NetworkDelegate>
@property(nonatomic, readonly) SFIReachabilityManager *cloudReachability;
@property(nonatomic, readonly) DatabaseStore *deviceLogsDb;
@property(nonatomic, readonly) id <SFINotificationStore> notificationsStore;
@property(nonatomic, readonly) dispatch_queue_t networkCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t networkDynamicCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t commandDispatchQueue;
@property(nonatomic, strong) RuleParser *ruleParser;
@property(nonatomic, strong) SceneParser *sceneParser;
@property(nonatomic, strong) ClientParser *clientParser;
@property(nonatomic, strong) DeviceParser *deviceParser;
@property(nonatomic, strong) RouterParser *routerParser;

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
        [self initialize];
        
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
        
        [self setupReachability:config.productionCloudHost];
        self.useProductionCloud = YES;
        
        _networkCallbackQueue = dispatch_queue_create("socket_callback", DISPATCH_QUEUE_CONCURRENT);
        _networkDynamicCallbackQueue = dispatch_queue_create("socket_dynamic_callback", DISPATCH_QUEUE_CONCURRENT);
        _commandDispatchQueue = dispatch_queue_create("command_dispatch", DISPATCH_QUEUE_SERIAL);
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(onReachabilityChanged:) name:kSFIReachabilityChangedNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)initialize{
    self.scenesArray = [NSMutableArray new];
    self.clients = [NSMutableArray new];
    self.devices = [NSMutableArray new];
    
    self.ruleParser =[[RuleParser alloc]init];
    self.sceneParser =[[SceneParser alloc]init];
    self.clientParser =[[ClientParser alloc]init];
    self.deviceParser = [[DeviceParser alloc]init];
    self.routerParser = [[RouterParser alloc]init];
//    [DataBaseManager initializeDataBase]; //this is for testing, earlier was used to retrive generic indexes.
    if(self.configuration.siteMapEnable){
        [BrowsingHistoryDataBase initializeDataBase];
        [CompleteDB initializeCompleteDataBase];
    }
    self.genericDevices = [DeviceParser parseGenericDevicesDict:[self.deviceParser parseJson:@"deviceListJson"]];
    self.genericIndexes = [DeviceParser parseGenericIndexesDict:[self.deviceParser parseJson:@"GenericIndexesData"]];
}

#pragma mark - helpscreen management
//called form login page, on each login help screen will be shown
- (void)initializeHelpScreenUserDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:kDASHBOARD_HELP_SHOWN];
    [defaults setBool:NO forKey:kDEVICES_HELP_SHOWN];
    [defaults setBool:NO forKey:kSCENES_HELP_SHOWN];
    [defaults setBool:NO forKey:kRULES_HELP_SHOWN];
    [defaults setBool:NO forKey:kWIFI_HELP_SHOWN];
    [defaults setBool:NO forKey:kWIFI_TRIGGER_HELP_SHOWN];
    
    NSLog(@"initialize dashboard default value: %d", [defaults boolForKey:kDASHBOARD_HELP_SHOWN]);
}

- (void)setScreenDefault:(NSString *)screen{
    NSLog(@"setScreenDefault");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([screen isEqualToString:@"dashboard"])
        [defaults setBool:YES forKey:kDASHBOARD_HELP_SHOWN];
    else if([screen isEqualToString:@"devices"])
        [defaults setBool:YES forKey:kDEVICES_HELP_SHOWN];
    else if([screen isEqualToString:@"scenes"])
        [defaults setBool:YES forKey:kSCENES_HELP_SHOWN];
    else if([screen isEqualToString:@"rules"])
        [defaults setBool:YES forKey:kRULES_HELP_SHOWN];
    else if([screen isEqualToString:@"wifi"])
        [defaults setBool:YES forKey:kWIFI_HELP_SHOWN];
    else if([screen isEqualToString:@"wifitrigger"])
        [defaults setBool:YES forKey:kWIFI_TRIGGER_HELP_SHOWN];
}

- (BOOL)isScreenShown:(NSString *)screen{
    NSLog(@"isScreenShown");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([screen isEqualToString:@"dashboard"])
        return [defaults boolForKey:kDASHBOARD_HELP_SHOWN];
    else if([screen isEqualToString:@"devices"])
        return [defaults boolForKey:kDEVICES_HELP_SHOWN];
    else if([screen isEqualToString:@"scenes"])
        return [defaults boolForKey:kSCENES_HELP_SHOWN];
    else if([screen isEqualToString:@"rules"])
        return [defaults boolForKey:kRULES_HELP_SHOWN];
    else if([screen isEqualToString:@"wifi"])
        return [defaults boolForKey:kWIFI_HELP_SHOWN];
    else if([screen isEqualToString:@"wifitrigger"])
        return [defaults boolForKey:kWIFI_TRIGGER_HELP_SHOWN];
    else
        return YES;
}


-(void)createNetworkInstanceAndChangeDelegate:(SFIAlmondPlus*)plus webSocketEndPoint:(WebSocketEndpoint*)endpoint res:(DynamicAlmondModeChange *)res{
    SFIAlmondLocalNetworkSettings *settings = [LocalNetworkManagement localNetworkSettingsForAlmond:plus.almondplusMAC];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:SFIAlmondConnectionMode_local forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    NetworkConfig *networkConfig = [NetworkConfig webSocketConfig:settings almondMac:plus.almondplusMAC];
    
    Network *network = [Network networkWithNetworkConfig:networkConfig callbackQueue:self.networkCallbackQueue dynamicCallbackQueue:self.networkDynamicCallbackQueue];
    network.delegate = self;
    [endpoint setAlmondNameAndMAC:plus.almondplusMAC];
    
    endpoint.delegate=network;
    network.endpoint = endpoint;
    
    self.network = network;
    
    [network networkEndpointDidConnect:endpoint];
    if(res!=nil)
        [self onDynamicAlmondModeChange:res network:endpoint];
    
}

#pragma mark - Connection management

// tests that the system configuration and current almond's link type are compatible with the specified mode
- (BOOL)isCurrentConnectionModeCompatible:(enum SFIAlmondConnectionMode)mode {
    // if systems is not configured for cloud, then say NO
    enum SFIAlmondConnectionMode defaultMode = [self currentConnectionMode];
    if (defaultMode != mode) {
        NSLog(@"default mode is not equal %d == %d",defaultMode,mode);
        return NO;
    }
    
    // check current almond config
    SFIAlmondPlus *current = [self currentAlmond];
    if (current) {
        if (current.linkType == SFIAlmondPlusLinkType_local_only) {
            NSLog(@"returning mode %d",mode);
            return mode == SFIAlmondConnectionMode_local;
        }
    }
    return YES;
}


- (enum SFIAlmondConnectionMode)currentConnectionMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    enum SFIAlmondConnectionMode mode = (enum SFIAlmondConnectionMode) [defaults integerForKey:kPREF_DEFAULT_CONNECTION_MODE];
    return mode;
}

- (void)setConnectionMode:(enum SFIAlmondConnectionMode)mode{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:mode forKey:kPREF_DEFAULT_CONNECTION_MODE];
    NSLog(@"i am called");
    [self tryShutdownAndStartNetworks:mode];
    [self postNotification:kSFIDidChangeAlmondConnectionMode data:nil];
}

// for changing network settings
// ensures a local connection for the specified almond is shutdown and, if needed, restarted
- (void)tryShutdownAndStartNetworks:(enum SFIAlmondConnectionMode)mode{
    
    if (!self.config.enableLocalNetworking) {
        return;
    }
    
    __weak SecurifiToolkit *block_self = self;
    NSLog(@" mode == %d",mode);
    //FORCED_DISCONNECT state is added here to make sure that toggle between cloud network and local network does not break;
    dispatch_async(self.commandDispatchQueue, ^() {
        [block_self tearDownNetwork];
        [block_self asyncInitNetwork];
    });
}


#pragma mark - Connection and Network state reporting

- (BOOL)isNetworkOnline{
    return ([ConnectionStatus getConnectionStatus] == (ConnectionStatusType*)AUTHENTICATED);
}

- (BOOL)isCloudReachable {
    return [self.cloudReachability isReachable];
}

- (BOOL)isCloudLoggedIn {
    NSLog(@"isCloudLoggedIn");
    Network *network = self.network;
    NSLog(@"status: %d", network.loginStatus);
    return network && network.loginStatus == NetworkLoginStatusLoggedIn;
}

- (BOOL)isAccountActivated {
    return [KeyChainAccess secIsAccountActivated];
}

- (int)minsRemainingForUnactivatedAccount {
    return (int) [KeyChainAccess secMinsRemainingForUnactivatedAccount];
}

- (enum SFIAlmondConnectionStatus)connectionStatusFromNetworkState:(enum ConnectionStatusType)status {
    
    switch (status) {
        case (ConnectionStatusType)NO_NETWORK_CONNECTION:
            return SFIAlmondConnectionStatus_disconnected;
        case (ConnectionStatusType)IS_CONNECTING_TO_NETWORK:
            return SFIAlmondConnectionStatus_connecting;
        case (ConnectionStatusType)CONNECTED_TO_NETWORK:
        case (ConnectionStatusType)AUTHENTICATED:
            return SFIAlmondConnectionStatus_connected;
        default:
            return SFIAlmondConnectionStatus_disconnected;
    }
}

- (ConnectionStatusType)networkStatus{
    if (self.network) {
        return [ConnectionStatus getConnectionStatus];
    }
    else {
        return NO_NETWORK_CONNECTION;
    }
}

- (void)setupReachability:(NSString *)hostname {
    [_cloudReachability shutdown];
    _cloudReachability = [[SFIReachabilityManager alloc] initWithHost:hostname];
}

- (void)onReachabilityChanged:(id)notice {
    self.scoreboard.reachabilityChangedCount++;
    NSLog(@"onReachability is called from toolkit");
    if(self.isAppInForeGround){
        if(self.isCloudReachable && [ConnectionStatus getConnectionStatus] == (ConnectionStatusType*)NO_NETWORK_CONNECTION && self.currentConnectionMode == SFIAlmondConnectionMode_cloud)
            [self asyncInitNetwork];
    }else{
        NSLog(@"application is in the background so does not start the start the network");
    }
}

#pragma mark - SDK Initialization
- (SecurifiConfigurator *)configuration {
    return [self.config copy];
}

-(void) asyncInitCloud {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"i am called");
    [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
    [self tryShutdownAndStartNetworks:SFIAlmondConnectionMode_cloud];
    
}


// Initialize the SDK. Can be called repeatedly to ensure the SDK is set-up.
- (void) asyncInitNetwork {
    __weak SecurifiToolkit *block_self = self;
    
    if (block_self.isShutdown) {
        DLog(@"INIT SDK. SDK is already shutdown. Returning.");
        return;
    }
    NSLog(@"i am called");
    ConnectionStatusType state = [ConnectionStatus getConnectionStatus];
    switch (state) {
        case AUTHENTICATED:
        case CONNECTED_TO_NETWORK: {
            NSLog(@"INIT SDK. connection established already. Returning.");
            return;
        };
        case IS_CONNECTING_TO_NETWORK: {
            NSLog(@"INIT SDK. connection already initializing. Returning.");
            return;
        };
        case DISCONNECTING_NETWORK: {
            NSLog(@"disconnecting from network is called");
        }
        case NO_NETWORK_CONNECTION:
        default: {
            NSLog(@"INIT SDK. connection needs establishment. Passing thru");
        };
    }
    NSLog(@"setupnetwork is called from asyncinitnetwork");
    Network *network = [block_self setUpNetwork];
}


-(void) sendTempPassLoginCommand{
    __weak SecurifiToolkit *block_self = self;
    GenericCommand *cmd;
    BOOL cmdSendSuccess;
    // Send logon credentials
    block_self.network.loginStatus = NetworkLoginStatusInProcess;
    NSLog(@"%s: sending temp pass credentials", __PRETTY_FUNCTION__);
    cmd = [block_self makeTempPassLoginCommand];
    cmdSendSuccess = [block_self.network submitCommand:cmd];
    if (!cmdSendSuccess) {
        NSLog(@"%s: failed on sending login command", __PRETTY_FUNCTION__);
    }
}

// Shutdown the SDK. No further work may be done after this method has been invoked.
- (void)shutdownToolkit {
    if (self.isShutdown) {
        return;
    }
    self.isShutdown = YES;
    
    SecurifiToolkit __weak *block_self = self;
    
    dispatch_async(self.networkCallbackQueue, ^(void) {
        NSLog(@"I am called");
        [block_self tearDownNetwork];
    });
}

- (void)debugUpdateConfiguration:(SecurifiConfigurator *)configurator {
    _config = configurator.copy;
}

// Invokes post-connection set-up and login to request updates that had been made while the connection was down
//- (void)asyncInitializeConnection1:(Network *)network {
//    // After successful login, refresh the Almond list and hash values.
//    // This routine is important because the UI will listen for outcomes to these requests.
//    // Specifically, the event kSFIDidUpdateAlmondList.
//
//    __weak SecurifiToolkit *block_self = self;
////    dispatch_async(self.commandDispatchQueue, ^() {
//        DLog(@"%s: requesting almond list", __PRETTY_FUNCTION__);
//        GenericCommand *cmd = [block_self makeAlmondListCommand];
//        NSLog(@"almond list command send1");
//        [network submitCommand:cmd];
////    });
//}

-(void)cleanUp{
    [self removeObjectFromArray:self.devices];
    [self removeObjectFromArray:self.scenesArray];
    [self removeObjectFromArray:self.clients];
    [self removeObjectFromArray:self.ruleList];
}

-(void)removeObjectFromArray:(NSMutableArray *)array{
    if(array!=nil && array.count>0)
        [array removeAllObjects];
}

// Invokes post-connection set-up and login to request updates that had been made while the connection was down
- (void)asyncInitializeConnection2:(Network *)network {
    // After successful login, refresh the Almond list and hash values.
    // This routine is important because the UI will listen for outcomes to these requests.
    // Specifically, the event kSFIDidUpdateAlmondList.
    NSLog(@"asyncInitializeConnection2");
    __weak SecurifiToolkit *block_self = self;
    
    SFIAlmondPlus *plus = [block_self currentAlmond];
    
    NSLog(@"asyncInitializeConnection plus mac %@",plus.almondplusMAC);
    if (plus != nil) {
        NSString *mac = plus.almondplusMAC;
        //        NetworkState *state = network.networkState;
        //        if (![state wasHashFetchedForAlmond:mac]) {
        //            [state markHashFetchedForAlmond:mac];
        
        GenericCommand *cmd;
        NSLog(@"commandDispatchQueue 1..");
        cmd = [GenericCommand requestSensorDeviceList:plus.almondplusMAC];
        
        [block_self asyncSendToNetwork:cmd];
        
        cmd = [GenericCommand requestSceneList:plus.almondplusMAC];
        
        [block_self asyncSendToNetwork:cmd];
        
        cmd = [GenericCommand requestAlmondClients:plus.almondplusMAC];
        
        [block_self asyncSendToNetwork:cmd];
        
        cmd = [GenericCommand requestAlmondRules:plus.almondplusMAC];
        
        [block_self asyncSendToNetwork:cmd];
        
        if(self.currentConnectionMode!=SFIAlmondConnectionMode_local){
            cmd = [GenericCommand requestRouterSummary:plus.almondplusMAC];
            [block_self asyncSendToNetwork:cmd];
        }
        
        cmd = [self tryRequestAlmondMode:mac];
        if(cmd!=nil)
            [block_self asyncSendToNetwork:cmd];
        
        [block_self tryRefreshNotifications];
        //        }
        
    }
    
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
    NSLog(@"I am called");
    [self tearDownNetwork];
}

- (void)asyncSendToNetwork: (GenericCommand *)command {
    
    if (self.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }
    
    Network *network = self.network;
    
    if(network ==nil){
        NSLog(@"calling _asyncInitNetwork %d ",command.command);
        //[self asyncInitNetwork];
    }
    
    BOOL success = [self.network submitCommand:command];
    NSLog(@"boolean value is %d",success);
    if (success) {
        NSLog(@"[Generic cmd: %d] send success", command.commandType);
    }else {
        NSLog(@"[Generic cmd: %d] send error", command.commandType);
    }
}

- (sfi_id)asyncSendAlmondAffiliationRequest:(NSString *)linkCode {
    if (!linkCode) {
        return 0;
    }
    NSLog(@"i am called");
    // ensure we are in the correct connection mode
    //[self setConnectionMode:SFIAlmondConnectionMode_cloud forAlmond:self.currentAlmond];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    AffiliationUserRequest *request = [[AffiliationUserRequest alloc] init];
    request.Code = linkCode;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_AFFILIATION_CODE_REQUEST;
    cmd.command = request;
    
    [self asyncSendToNetwork:cmd];
    
    return request.correlationId;
}

#pragma mark - Cloud Logon

- (NSString *)loginEmail {
    return [KeyChainAccess secEmail];
}

- (void)storeLoginCredentials:(LoginResponse *)response {
    NSString *tempPass = response.tempPass;
    NSString *userId = response.userID;
    
    [KeyChainAccess setSecPassword:tempPass];
    [KeyChainAccess setSecUserId:userId];
    
    [self storeAccountActivationCredentials:response];
}

- (void)storeAccountActivationCredentials:(LoginResponse *)response {
    //PY: 101014 - Not activated accounts can be accessed for 7 days
    BOOL activated = response.isAccountActivated;
    NSUInteger remaining = response.minsRemainingForUnactivatedAccount;
    
    [KeyChainAccess setSecAccountActivationStatus:activated];
    [KeyChainAccess setSecMinsRemainingForUnactivatedAccount:remaining];
}

- (void)tearDownLoginSession {
    NSLog(@"i am called");
    [KeyChainAccess clearSecCredentials];
    [self purgeStoredData];
}

- (void)purgeStoredData {
    NSLog(@"i am called");
    //[self setConnectionMode:SFIAlmondConnectionMode_cloud];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
    [AlmondManagement removeCurrentAlmond];
    [self.dataManager purgeAll]; // local connection information is not purged
    if (self.configuration.enableNotifications) {
        [self.notificationsDb purgeAll];
        [self.deviceLogsDb purgeAll];
    }
}

- (void)onLoginResponse:(LoginResponse *)res network:(Network *)network {
    if (res.isSuccessful) {
        NSLog(@"loggedin success");
        NSLog(@" Who is setting status SecurifiNetwork - onLoginResponse");
        [ConnectionStatus setConnectionStatusTo:(ConnectionStatusType*)AUTHENTICATED];
        // Password is always cleared prior to submitting a fresh login from the UI.
        if (![KeyChainAccess hasSecPassword]) {
            // So, if no password is in the keychain, then we know the temp pass needs to be stored on successful login response.
            // The response will contain the TempPass token, which we store in the keychain. The original password is not stored.
            [self storeLoginCredentials:res];
        }
        
        //PY 141014: Store account activation information every time the user logs in
        [self storeAccountActivationCredentials:res];
        
        // Request updates: normally, once a logon token has been retrieved, we just issue these commands as part of SDK initialization.
        // But the client was not logged in. Send them now...
        //        [self asyncInitializeConnection1:network];
        GenericCommand *cmd = [self makeAlmondListCommand];
        NSLog(@"almond list command send1");
        [network submitCommand:cmd];
    }
    else {
        // Logon failed:
        // Ensure all credentials are cleared
        [self tearDownLoginSession];
        NSLog(@"I am called");
        [self tearDownNetwork];
    }
    
    // In any case, notify the UI about the login result
    [self postNotification:kSFIDidCompleteLoginNotification data:res];
}

- (void)onLogoutResponse {
    [self tearDownLoginSession];
    NSLog(@"I am called");
    [self tearDownNetwork];
    [self postNotification:kSFIDidLogoutNotification data:nil];
}

- (void)onLogoutAllResponse:(LoginResponse *)res {
    if (res.isSuccessful) {
        DLog(@"SDK received success on Logout All");
        [self tearDownLoginSession];
        NSLog(@"I am called");
        [self tearDownNetwork];
        //        [self resetCurrentAlmond];
    }
    
    [self postNotification:kSFIDidLogoutAllNotification data:res];
}

- (void)onDeleteAccountResponse:(DeleteAccountResponse *)res {
    if (res.isSuccessful) {
        DLog(@"SDK received success on Delete Account");
        // treat it like a logout; clean up and tear down state
        [self onLogoutResponse];
    }
}

// pre-populates the current almond setting based with the first local almond it finds.
// called after login session has been purged
- (void)resetCurrentAlmond {
    NSLog(@"i am called");
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

- (void)setCurrentAlmond:(SFIAlmondPlus *)almond {
    NSLog(@"i am called");
    [AlmondManagement setCurrentAlmond:almond];
}

- (void)writeCurrentAlmond:(SFIAlmondPlus *)almond {
    NSLog(@"i am called");
    self.currentAlmond =almond;
    [AlmondManagement writeCurrentAlmond:almond];
}

- (SFIAlmondPlus *)currentAlmond {
    return [AlmondManagement currentAlmond];
}

- (NSArray *)almondList {
    return [self.dataManager readAlmondList];
}

- (BOOL)almondExists:(NSString *)almondMac {
    return [AlmondManagement almondExists:almondMac];
}

- (NSArray *)localLinkedAlmondList {
    return [AlmondManagement localLinkedAlmondList];
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
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        NetworkState *state = aNetwork.networkState;
        if ([state willFetchDeviceListFetchedForAlmond:almondMac]) {
            return NO;
        }
        
        [state markWillFetchDeviceListForAlmond:almondMac];
        return YES;
    };
    
    BOOL local = [self useLocalNetwork:almondMac];
}

- (void)asyncRequestDeviceValueList:(NSString *)almondMac {
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        [aNetwork.networkState markDeviceValuesFetchedForAlmond:almondMac];
        return YES;
    };
    
    BOOL local = [self useLocalNetwork:almondMac];
}

- (BOOL)tryRequestDeviceValueList:(NSString *)almondMac {
    BOOL local = [self useLocalNetwork:almondMac];
    NSLog(@"i am called");
    Network *network = local ? [self setUpNetwork] : self.network;;
    
    NetworkState *state = network.networkState;
    if ([state wasDeviceValuesFetchedForAlmond:almondMac]) {
        return NO;
    }
    [state markDeviceValuesFetchedForAlmond:almondMac];
    
    [self asyncRequestDeviceValueList:almondMac];
    
    return YES;
}


#pragma mark - Sending Commands to Network
- (void)asyncSendLogout {
    if (self.isShutdown) {
        DLog(@"SDK is shutdown. Returning.");
        return;
    }
    
    if (self.isNetworkOnline) {
        [self asyncRequestDeregisterForNotification];
        
        GenericCommand *cmd = [GenericCommand new];
        cmd.commandType = CommandType_LOGOUT_COMMAND;
        cmd.command = nil;
        
        [self asyncSendToNetwork:cmd];
    }
    else {
        // Not connected, so just purge on-device credentials and cache
        [self onLogoutResponse];
    }
}

- (void)asyncRequestDeregisterForNotification {
    if (![KeyChainAccess isSecApnTokenRegistered]) {
        SLog(@"asyncRequestRegisterForNotification : no device token to deregister");
        return;
    }
    
    NSString *deviceToken = [KeyChainAccess secRegisteredApnToken];
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
    
    [self asyncSendToNetwork:cmd];
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

- (void)asyncSendValidateCloudAccount:(NSString *)email {
    if (email.length == 0) {
        return;
    }
    
    HTTPRequest *request = [HTTPRequest new];
    [request sendAsyncHTTPRequestResendActivationLink:email];
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
    
    [self asyncSendToNetwork:cmd];
}

- (void)asyncRequestResetCloudPassword:(NSString *)email {
    if (email.length == 0) {
        return;
    }
    
    ResetPasswordRequest *req = [ResetPasswordRequest new];
    req.email = email;
    
    GenericCommand *cmd = [[GenericCommand alloc] init];
    cmd.commandType = CommandType_RESET_PASSWORD_REQUEST;
    cmd.command = req;
    
    NSLog(@"i am called");
    // make sure cloud connection is set up
    [self tearDownLoginSession];
    [KeyChainAccess setSecEmail:email];
    
    [self asyncSendToNetwork:cmd];
}

- (void)asyncRequestDeleteCloudAccount:(NSString *)password {
    DeleteAccountRequest *request = [DeleteAccountRequest new];
    request.emailID = [self loginEmail];
    request.password = password;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DELETE_ACCOUNT_REQUEST;
    cmd.command = request;
    
    [self asyncSendToNetwork:cmd];}

- (void)asyncRequestUnlinkAlmond:(NSString *)almondMAC password:(NSString *)password {
    UnlinkAlmondRequest *request = [UnlinkAlmondRequest new];
    request.almondMAC = almondMAC;
    request.password = password;
    request.emailID = [self loginEmail];
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_UNLINK_ALMOND_REQUEST;
    cmd.command = request;
    
    [self asyncSendToNetwork:cmd];
}

- (void)asyncRequestInviteForSharingAlmond:(NSString *)almondMAC inviteEmail:(NSString *)inviteEmailID {
    UserInviteRequest *request = [UserInviteRequest new];
    request.almondMAC = almondMAC;
    request.emailID = inviteEmailID;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_USER_INVITE_REQUEST;
    cmd.command = request;
    
    [self asyncSendToNetwork:cmd];
}

- (void)asyncRequestDeleteSecondaryUser:(NSString *)almondMAC email:(NSString *)emailID {
    DeleteSecondaryUserRequest *request = [DeleteSecondaryUserRequest new];
    request.almondMAC = almondMAC;
    request.emailID = emailID;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DELETE_SECONDARY_USER_REQUEST;
    cmd.command = request;
    
   [self asyncSendToNetwork:cmd];
}

- (void)asyncRequestDeleteMeAsSecondaryUser:(NSString *)almondMAC {
    DeleteMeAsSecondaryUserRequest *request = [DeleteMeAsSecondaryUserRequest new];
    request.almondMAC = almondMAC;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DELETE_ME_AS_SECONDARY_USER_REQUEST;
    cmd.command = request;
    
   [self asyncSendToNetwork:cmd];
}

- (void)asyncRequestChangeAlmondName:(NSString *)changedAlmondName almondMAC:(NSString *)almondMAC {
    AlmondNameChange *request = [AlmondNameChange new];
    request.almondMAC = almondMAC;
    request.changedAlmondName = changedAlmondName;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ALMOND_NAME_CHANGE_REQUEST;
    cmd.command = request;
    
    [self asyncSendToNetwork:cmd];
}

- (void)asyncRequestMeAsSecondaryUser {
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ME_AS_SECONDARY_USER_REQUEST;
    cmd.command = [MeAsSecondaryUserRequest new];
    
    [self asyncSendToNetwork:cmd];
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
        
        return storedCmd.isExpired;
    };
    
    // sends a series of requests to fetch all the information at once.
    // note ordering might be important to the UI layer, which for now receives the response payloads directly
    [self internalRequestAlmondStatusAndSettings:almondMac command:SecurifiToolkitAlmondRouterRequest_summary commandPrecondition:precondition];
}

- (void)internalJSONRequestAlmondWifiClients:(NSString *)almondMac {
    BOOL local = [self useLocalNetwork:almondMac];
    NSLog(@"local: %d", local);
    if (local) {
        GenericCommand *cmd = [GenericCommand requestAlmondClients:almondMac];
        [self asyncSendToNetwork:cmd ];
    }
    else{
        GenericCommand *cmd = [GenericCommand requestAlmondClients:almondMac];
        [self asyncSendToNetwork:cmd];
    }
    
}

- (void)internalRequestAlmondStatusAndSettings:(NSString *)almondMac command:(enum SecurifiToolkitAlmondRouterRequest)type commandPrecondition:(NetworkPrecondition)precondition {
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
    
    [self asyncSendToNetwork:cmd];
}

- (sfi_id)asyncUpdateAlmondWirelessSettings:(NSString *)almondMAC wirelessSettings:(SFIWirelessSetting *)settings {
    GenericCommand *cmd = [GenericCommand cloudUpdateWirelessSettings:settings almondMac:almondMAC];
    [self asyncSendToNetwork:cmd];
    
    return cmd.correlationId;
}

#pragma mark - Notification Preferences and Almond mode changes

- (SFIAlmondMode)modeForAlmond:(NSString *)almondMac {
    return [self tryCachedAlmondModeValue:almondMac];
}

- (SFIAlmondMode)tryCachedAlmondModeValue:(NSString *)almondMac {
    Network *network = self.network;
    if (network) {
        return [network.networkState almondMode:almondMac];
    }
    
    return SFIAlmondMode_unknown;
}

// Checks whether a Mode has already been fetched for the almond, and if so, fails quietly.
// Otherwise, it requests the mode information.
- (GenericCommand* )tryRequestAlmondMode:(NSString *)almondMac {
    if (almondMac == nil || self.currentConnectionMode==SFIAlmondConnectionMode_local) {
        return nil;
    }
    
    AlmondModeRequest *req = [AlmondModeRequest new];
    req.almondMAC = almondMac;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ALMOND_MODE_REQUEST;
    cmd.command = req;
    
    return cmd;
}

- (sfi_id)asyncRequestAlmondModeChange:(NSString *)almondMac mode:(SFIAlmondMode)newMode {
    if (almondMac == nil) {
        NSLog(@"asyncRequestAlmondModeChange : almond MAC is nil");
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
    
    GenericCommand *cmd = [GenericCommand changeAlmondMode:newMode userId:userId almondMac:almondMac];
    cmd.networkPrecondition = precondition;
    
    [self asyncSendToNetwork:cmd ];
    
    return cmd.correlationId;
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
    req.UserID = [KeyChainAccess secUserId];
    req.TempPass = [KeyChainAccess secPassword];
    
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


#pragma mark - Network management
-(Network *)setUpNetwork{
    enum SFIAlmondConnectionMode mode = [self currentConnectionMode];
    Network *network = nil;
    NetworkConfig *networkConfig = nil;
    switch (mode) {
        case SFIAlmondConnectionMode_cloud:{
            NSLog(@"entering the cloud mode");
            [self tearDownNetwork];
            networkConfig = [NetworkConfig cloudConfig:self.config useProductionHost:self.useProductionCloud];
        }
        break;
        case SFIAlmondConnectionMode_local:{
            SFIAlmondPlus* almond = self.currentAlmond;
            NSLog(@"Entering the local mode");
            [self tearDownNetwork];
            
            SFIAlmondLocalNetworkSettings *settings = [LocalNetworkManagement localNetworkSettingsForAlmond:almond.almondplusMAC];
            
            networkConfig = [NetworkConfig webSocketConfig:settings almondMac:almond.almondplusMAC];
            
        }
            break;
        default:
            break;
    }
    
    network = [Network networkWithNetworkConfig:networkConfig callbackQueue:self.networkCallbackQueue dynamicCallbackQueue:self.networkDynamicCallbackQueue];
    network.delegate = self;
    
    self.network = network;
    
    [network connect];
    
    return network;
}

-(Network*) createNetworkWithConfig:(NetworkConfig *)config{
    Network* network = [Network networkWithNetworkConfig:config callbackQueue:self.networkCallbackQueue dynamicCallbackQueue:self.networkDynamicCallbackQueue];
    return network;
}

- (void)connectMesh{
    if([self currentConnectionMode] == SFIAlmondConnectionMode_local && self.network!=nil)
        [self.network connectMesh];
}

- (void)shutDownMesh{
    if([self currentConnectionMode] == SFIAlmondConnectionMode_local && self.network!=nil)
        [self.network shutdownMesh];
}


-(void) tearDownNetwork{
    NSLog(@" tearDownNetwork ");
    Network *old = self.network;
    if(old){
        old.delegate = nil;
        [old shutdown];
        
        self.network = nil;
    } 
    [self cleanUp];
}

// internal function used by high-level command dispatch methods for branching on local or cloud command queue
- (BOOL)useLocalNetwork:(NSString *)almondMac {
    if (!self.config.enableLocalNetworking) {
        return NO;
    }
    
    NSLog(@"i am called");
    // if in cloud mode, then fail fast
    if (![self isCurrentConnectionModeCompatible:SFIAlmondConnectionMode_local]) {
        return NO;
    }
    
    // if network is set up, make sure it is for the specified almond
    Network *local = self.network;
    if (local) {
        NSString *mac = local.config.almondMac;
        NSLog(@"Is mac present in the network %d" ,mac && [mac isEqualToString:almondMac]);
        return mac && [mac isEqualToString:almondMac];
    }
    
    // if network not set up then check that settings are complete; the network will be set up on calling
    // asyncSubmitLocal command.
    //todo need a fast cache for this; very expensive to hit the file system constantly
    SFIAlmondLocalNetworkSettings *settings = [LocalNetworkManagement localNetworkSettingsForAlmond:almondMac];
    return settings.hasCompleteSettings;
}

- (BOOL)isCurrentLocalNetworkForAlmond:(NSString *)almondMac {
    if (!self.config.enableLocalNetworking) {
        return NO;
    }
    
    Network *network = self.network;
    if (!network) {
        return NO;
    }
    
    NetworkConfig *config = network.config;
    return [config.almondMac isEqualToString:almondMac];
}

#pragma mark - NetworkDelegate methods

- (void)networkConnectionDidEstablish:(Network *)network {
    if (network == self.network) {
        self.scoreboard.connectionCount++;
    }
}

- (void)networkConnectionDidClose:(Network *)network {
    network.delegate = nil;
    NSLog(@"networkDidCloseIsCalled");
    if (network == self.network) {
        self.network = nil;
        DLog(@"%s: posting NETWORK_DOWN_NOTIFIER on closing cloud connection", __PRETTY_FUNCTION__);
    }
}

- (void)networkDidSendCommand:(Network *)network command:(GenericCommand *)command {
    if (network == self.network) {
        self.scoreboard.commandRequestCount++;
        [self markCommandEvent:command.commandType];
    }
}

- (void)networkDidReceiveCommandResponse:(Network *)network command:(GenericCommand *)cmd timeToCompletion:(NSTimeInterval)roundTripTime responseType:(enum CommandType)commandType {
    if (network == self.network) {
        self.scoreboard.commandResponseCount++;
        [self markCommandEvent:commandType];
    }
    
    id p_cmd = cmd.command;
    if ([p_cmd isKindOfClass:[MobileCommandRequest class]]) {
        NSDictionary *payload = @{
                                  @"command" : p_cmd,
                                  @"timing" : @(roundTripTime)
                                  };
        NSLog(@" posting kSFIDidCompleteMobileCommandRequest");
        [self postNotification:kSFIDidCompleteMobileCommandRequest data:payload];
    }
    
}

- (void)networkDidReceiveResponse:(Network *)network response:(id)payload responseType:(enum CommandType)commandType {
    
    if (network == self.network) {
        self.scoreboard.commandResponseCount++;
        [self markCommandEvent:commandType];
    }
    
    switch (commandType) {
        case CommandType_LOGIN_RESPONSE: {
            LoginResponse *obj = (LoginResponse *) payload;
            [self onLoginResponse:obj network:network];
            break;
        }
            
        case CommandType_LOGOUT_RESPONSE: {
            [self onLogoutResponse];
            break;
        }
            
        case CommandType_LOGOUT_ALL_RESPONSE: {
            LoginResponse *res = payload;
            [self onLogoutAllResponse:res];
            break;
        }
            
        case CommandType_DELETE_ACCOUNT_RESPONSE: {
            DeleteAccountResponse *res = payload;
            [self onDeleteAccountResponse:res];
            break;
        }
            
        case CommandType_ALMOND_LIST_RESPONSE: {
            AlmondListResponse *res = payload;
            [AlmondListManagement onAlmondListResponse:res network:network];
            break;
        }
            
        case CommandType_DEVICE_DATA_HASH_RESPONSE: {
            DeviceDataHashResponse *res = payload;
            [self onDeviceHashResponse:res];
            break;
        }
            
        case CommandType_DEVICE_DATA_RESPONSE: {
            DeviceListResponse *res = payload;
            [self onDeviceListResponse:res network:network];
            break;
        }
            
        case CommandType_DEVICE_LIST_AND_VALUES_RESPONSE: {
            DeviceListResponse *res = payload;
            [self onDeviceListAndValuesResponse:res network:network];
            break;
        }
            
        case CommandType_DEVICE_VALUE_LIST_RESPONSE: {
            DeviceValueResponse *res = payload;
            [self onDeviceValueListChange:res];
            break;
        }
            
        case CommandType_GENERIC_COMMAND_RESPONSE: {
            GenericCommandResponse *res = payload;
            [self onAlmondRouterGenericCommandResponse:res network:network];
            break;
        }
            
        case CommandType_GENERIC_COMMAND_NOTIFICATION: {
            GenericCommandResponse *res = payload;
            [self onAlmondRouterGenericNotification:res network:network];
            break;
        }
            
        case CommandType_ALMOND_MODE_CHANGE_RESPONSE: {
            AlmondModeChangeResponse *res = payload;
            [self onAlmondModeChangeCompletion:payload network:network];
            break;
        }
            
        case CommandType_ALMOND_MODE_RESPONSE: {
            NSLog(@"almond mode payload %@",payload);
            AlmondModeResponse *res = payload;
            [self onAlmondModeResponse:res network:network];
            break;
        }
            
        case CommandType_NOTIFICATION_REGISTRATION_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationRegistrationResponse *res = payload;
                [self onNotificationRegistrationResponseCallback:res];
            }
            break;
        }
            
        case CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE: {
            NSLog(@"toolkit - CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE");
            if (self.config.enableNotifications) {
                NotificationPreferenceListResponse *res = payload;
                [self onNotificationPrefListChange:res];
            }
            break;
        }
            
        case CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE: {
            NSLog(@"toolkit - CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE");
            if (self.config.enableNotifications) {
                NotificationPreferenceResponse *res = payload;
                [self onDeviceNotificationPreferenceChangeResponseCallback:res network:network];
            }
            break;
        }
            
        case CommandType_NOTIFICATIONS_SYNC_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationListResponse *res = payload;
                NSLog(@"CommandType_NOTIFICATIONS_SYNC_RESPONSE");
                [self onNotificationListSyncResponse:res network:network];
            }
            break;
        };
            
        case CommandType_NOTIFICATIONS_COUNT_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationCountResponse *res = payload;
                [self onNotificationCountResponse:res];
            }
            break;
        };
            
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationClearCountResponse *res = payload;
                [self onNotificationClearCountResponse:res];
            }
            break;
        };
            
        case CommandType_DEVICELOG_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationListResponse *res = payload;
                [self onDeviceLogSyncResponse:res];
            }
            break;
        };
            
        case CommandType_ALMOND_COMMAND_RESPONSE: {
            SFIGenericRouterCommand *res = payload;
            [self onAlmondRouterCommandResponse:res network:network];
            break;
        };
            
        case CommandType_DYNAMIC_ALMOND_MODE_CHANGE: {
            DynamicAlmondModeChange *obj = payload;
            [self onDynamicAlmondModeChange:obj network:network];
            break;
        }
            
            
        case CommandType_ALMOND_NAME_AND_MAC_RESPONSE: {
            NSDictionary *dict = payload;
            NSString *name = dict[@"Name"];
            
            NSString *mac_hex = dict[@"MAC"];
            NSString *mac = [SFIAlmondPlus convertMacHexToDecimal:mac_hex];
            
            SFIAlmondPlus *current = [self currentAlmond];
            if ([current.almondplusMAC isEqualToString:mac]) {
                if ([current.almondplusName isEqualToString:name]) {
                    return; // name is the same
                }
                DynamicAlmondNameChangeResponse *res = DynamicAlmondNameChangeResponse.new;
                res.almondplusMAC = mac;
                res.almondplusName = name;
                
                [AlmondListManagement onDynamicAlmondNameChange:res];
            }
            
            break;
        }
            
        default:
            break;
    }
}


- (void)networkDidReceiveDynamicUpdate:(Network *)network response:(id)payload responseType:(enum CommandType)commandType {
    if (network == self.network) {
        self.scoreboard.dynamicUpdateCount++;
        [self markCommandEvent:commandType];
    }
    
    switch (commandType) {
        case CommandType_DYNAMIC_DEVICE_DATA: {
            DeviceListResponse *obj = payload;
            [self onDynamicDeviceListChange:obj network:network];
            break;
        }
        case CommandType_DYNAMIC_DEVICE_VALUE_LIST: {
            DeviceValueResponse *obj = payload;
            [self onDynamicDeviceValueListChange:obj];
            break;
        }
        case CommandType_DYNAMIC_ALMOND_ADD: {
            AlmondListResponse *obj = payload;
            [AlmondListManagement onDynamicAlmondListAdd:obj];
            break;
        }
        case CommandType_DYNAMIC_ALMOND_DELETE: {
            AlmondListResponse *obj = payload;
            [AlmondListManagement onDynamicAlmondListDelete:obj network:network];
            break;
        }
        case CommandType_DYNAMIC_ALMOND_NAME_CHANGE: {
            DynamicAlmondNameChangeResponse *obj = payload;
            [AlmondListManagement onDynamicAlmondNameChange:obj];
            break;
        }
        case CommandType_DYNAMIC_NOTIFICATION_PREFERENCE_LIST: {
            if (self.config.enableNotifications) {
                DynamicNotificationPreferenceList *obj = payload;
                [self onDynamicNotificationPrefListChange:obj];
            }
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Internal Command Dispatch and Notification

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



#pragma mark - Generic Almond Router commmand callbacks

- (void)onAlmondRouterGenericNotification:(GenericCommandResponse *)res network:(Network *)network {
    if (!res) {
        return;
    }
    
    NSString *mac = res.almondMAC;
    
    [network.networkState clearExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:mac];
    
    if (!res.isSuccessful) {
        SFIGenericRouterCommand *routerCommand = [SFIGenericRouterCommand new];
        routerCommand.almondMAC = mac;
        routerCommand.commandSuccess = NO;
        routerCommand.responseMessage = res.reason;
        
        [self postNotification:kSFIDidReceiveGenericAlmondRouterResponse data:routerCommand];
    }
    else {
        SFIGenericRouterCommand *routerCommand = [RouterCommandParser parseRouterResponse:res];
        routerCommand.almondMAC = mac;
        
        [self internalOnGenericRouterCommandResponse:routerCommand];
    }
}

- (void)onAlmondRouterGenericCommandResponse:(GenericCommandResponse *)res network:(Network *)network {
    if (!res) {
        return;
    }
    
    NSString *mac = res.almondMAC;
    
    [network.networkState clearExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:mac];
    
    SFIGenericRouterCommand *routerCommand = [RouterCommandParser parseRouterResponse:res];
    routerCommand.almondMAC = mac;
    
    [self internalOnGenericRouterCommandResponse:routerCommand];
}

- (void)onAlmondRouterCommandResponse:(SFIGenericRouterCommand *)res network:(Network *)network {
    if (!res) {
        return;
    }
    
    NSString *mac = res.almondMAC;
    [network.networkState clearExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:mac];
    [self internalOnGenericRouterCommandResponse:res];
}

- (void)internalOnGenericRouterCommandResponse:(SFIGenericRouterCommand *)routerCommand {
    if (routerCommand == nil) {
        return;
    }
    NSLog(@"internalOnGenericRouterCommandResponse");
    if (routerCommand.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
        // after receiving summary, we update the local wireless connection settings with the current login/password
        SFIRouterSummary *summary = (SFIRouterSummary *) routerCommand.command;
        
        NSLog(@"tryupdatelocalNetwork is getting called");
        [LocalNetworkManagement tryUpdateLocalNetworkSettingsForAlmond:routerCommand.almondMAC withRouterSummary:summary];
    }
    
    [self postNotification:kSFIDidReceiveGenericAlmondRouterResponse data:routerCommand];
}

#pragma mark - Device List Update callbacks

- (void)onDeviceHashResponse:(DeviceDataHashResponse*)res {
    
    
    if (!res) {
        return;
    }
    
    NSString *reportedHash = res.almondHash;
    if (!res.isSuccessful) {
        // We assume, on failure, the Almond is no longer associated with this account and
        // our list of Almonds is out of date. Therefore, issue a request for the Almond list.
        
        
        SFIAlmondPlus *currentAlmond = [self currentAlmond];
        if (currentAlmond.linkType == SFIAlmondPlusLinkType_cloud_local) {
            [AlmondManagement removeCurrentAlmond];
            
            GenericCommand *cmd = [self makeAlmondListCommand];
            [self asyncSendToNetwork:cmd];
        }
        
        return;
    }
    
    SFIAlmondPlus *currentAlmond = [self currentAlmond];
    if (currentAlmond == nil) {
        return;
    }
    
    NSString *currentMac = currentAlmond.almondplusMAC;
    NSString *storedHash = [self.dataManager readHashList:currentMac];
    
    if (reportedHash.length == 0 || [reportedHash isEqualToString:@"null"]) {
        //Hash sent by cloud as null - No Device
        
        [self asyncRequestDeviceList:currentMac];
    }
    else if (storedHash.length > 0 && currentMac.length > 0 && [storedHash isEqualToString:reportedHash]) {
        // Devices list is fresh. Update the device values.
        
        [self tryRequestDeviceValueList:currentMac];
    }
    else {
        //Save hash in file for each almond
        [self.dataManager writeHashList:reportedHash almondMac:currentMac];
        // and update the device list -- on receipt of the device list, then the values will be updated
        [self asyncRequestDeviceList:currentMac];
    }
}

- (void)onDynamicDeviceListChange:(DeviceListResponse *)obj network:(Network *)network {
    
    if (!obj) {
        return;
    }
    
    [network.networkState clearWillFetchDeviceListForAlmond:obj.almondMAC];
    
    if (!obj.isSuccessful) {
        return;
    }
    
    NSString *almondMAC = obj.almondMAC;
    NSMutableArray *newDeviceList = obj.deviceList;
    
    [self processDeviceListChange:newDeviceList mac:almondMAC requestValues:YES partialList:NO];
    [self postNotification:kSFIDidChangeDeviceList data:almondMAC];
}

- (void)onDeviceListResponse:(DeviceListResponse*)res network:(Network*)network {
    
    if (!res) {
        return;
    }
    
    NSString *mac = res.almondMAC;
    [network.networkState clearWillFetchDeviceListForAlmond:mac];
    
    if (!res.isSuccessful) {
        
        return;
    }
    
    NSArray *newDevices = res.deviceList;
    
    // values not included in response, so request them
    BOOL requestValues = (res.deviceValueList == nil);
    [self processDeviceListChange:newDevices mac:mac requestValues:requestValues partialList:NO];
    [self postNotification:kSFIDidChangeDeviceList data:mac];
}


- (void)storeDeviceAndDeviceValueList:(NSArray*)deviceList deviceValueList:(NSArray*)deviceValueList mac:mac{
    
    [self.dataManager writeDeviceList:deviceList almondMac:mac];
    [self.dataManager writeDeviceValueList:deviceValueList almondMac:mac];
    
}

- (void)onDeviceListAndValuesResponse:(DeviceListResponse *)res network:(Network *)network {
    
    
    if (!res) {
        return;
    }
    
    NSString *mac = res.almondMAC;
    [network.networkState clearWillFetchDeviceListForAlmond:mac];
    
    if (!res.isSuccessful) {
        return;
    }
    
    const BOOL partialList = res.updatedDevicesOnly;
    
    switch (res.type) {
        case DeviceListResponseType_deviceList: {
            [self storeDeviceAndDeviceValueList:res.deviceList deviceValueList:res.deviceValueList mac:mac];
            [self postNotification:kSFIDidChangeDeviceValueList data:mac];
            break;
        }
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
        case DeviceListResponseType_websocket_added: {
            NSArray *currentDeviceList = [self.dataManager readDeviceList:mac];
            NSArray *currentValueList = [self.dataManager readDeviceValueList:mac];
            
            for (SFIDevice *device in res.deviceList) {
                currentDeviceList = [SFIDevice addDevice:device list:currentDeviceList];
            }
            NSMutableArray *newDeviceValueList = [NSMutableArray arrayWithArray:currentValueList];
            for (SFIDeviceValue *currentCloudValue in res.deviceValueList) {
                [newDeviceValueList addObject:currentCloudValue];
            }
            [self processDeviceListChange:currentDeviceList mac:mac requestValues:YES partialList:NO];
            [self.dataManager writeDeviceValueList:newDeviceValueList almondMac:mac];
            [self postNotification:kSFIDidChangeDeviceList data:mac];
            
            break;
        };
        case DeviceListResponseType_removed: {
            
            NSArray *currentDeviceList = [self.dataManager readDeviceList:mac];
            NSArray *currentValueList = [self.dataManager readDeviceValueList:mac];
            
            SFIDevice *deviceToBeRemoved=[res.deviceList objectAtIndex:0];
            
            currentDeviceList = [SFIDevice removeDevice:deviceToBeRemoved list:currentDeviceList];
            currentValueList = [SFIDeviceValue removeDeviceValue:deviceToBeRemoved.deviceID list:currentValueList];
            
            [self.dataManager writeDeviceList:currentDeviceList almondMac:mac];
            [self.dataManager writeDeviceValueList:currentValueList almondMac:mac];
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

- (void)onDynamicDeviceValueListChange:(DeviceValueResponse *)obj {
    if (obj == nil) {
        return;
    }
    
    NSString *almondMac = obj.almondMAC;
    
    [self processDeviceValueList:obj.deviceValueList mac:almondMac];
}

- (void)onDeviceValueListChange:(DeviceValueResponse *)obj {
    if (!obj) {
        return;
    }
    
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
            GenericCommand *command = [self makeDeviceHashCommand:currentMAC];
            [self asyncSendToNetwork:command];
        }
        
        // replace the list given to us with the combined new list
        newDeviceValues = newDeviceValueList;
    }
    
    // Update offline storage
    [self.dataManager writeDeviceValueList:newDeviceValues almondMac:currentMAC];
    
    [self postNotification:kSFIDidChangeDeviceValueList data:currentMAC];
}


#pragma mark - Notification Preference List callbacks

- (void)onDeviceNotificationPreferenceChangeResponseCallback:(NotificationPreferenceResponse*)res network:(Network *)network {
    
    //    if (!res.isSuccessful) {
    //        return;
    //    }
    
    GenericCommand *cmd = [network.networkState expirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification"];
    NotificationPreferences *req = cmd.command;
    NSLog(@"onDeviceNotificationPreferenceChangeResponseCallback req :%@", req);
    if (!req) {
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
        [network.networkState clearExpirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification"];
        return;
    }
    [self.dataManager writeNotificationPreferenceList:newPrefs almondMac:almondMac];
    
    [network.networkState clearExpirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification"];
    
    [self postNotification:kSFINotificationPreferencesListDidChange data:res];
}

- (void)onNotificationRegistrationResponseCallback:(NotificationRegistrationResponse *)obj {
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

- (void)onNotificationPrefListChange:(NotificationPreferenceListResponse *)res {
    if (!res) {
        return;
    }
    
    NSString *currentMAC = res.almondMAC;
    if (currentMAC.length == 0) {
        return;
    }
    
    if ([res.notificationDeviceList count] != 0) {
        // Update offline storage
        [self.dataManager writeNotificationPreferenceList:res.notificationDeviceList almondMac:currentMAC];
        [self postNotification:kSFINotificationPreferencesDidChange data:currentMAC];
    }
}

- (void)onDynamicNotificationPrefListChange:(DynamicNotificationPreferenceList *)obj {
    if (obj == nil) {
        return;
    }
    
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

- (void)onNotificationListSyncResponse:(NotificationListResponse *)res network:(Network *)network {
    
    if (!res) {
        return;
    }
    
    NSString *requestId = res.requestId;
    
    DLog(@"asyncRefreshNotifications: recevied request id:'%@'", requestId);
    
    // Remove the guard preventing more refresh notifications
    if (requestId.length == 0) {
        // note: we are only tracking "refresh" requests to prevent more than one of them to be processed at a time.
        // these requests are not the same as "catch up" requests for older sync points that were queued for fetching
        // but not downloaded; see internalTryProcessNotificationSyncPoints.
        
        [network.networkState clearExpirableRequest:ExpirableCommandType_notificationListRequest namespace:@"notification"];
    }
    
    // Store the notifications and stop tracking the pageState that they were associated with
    //
    // As implemented, iteration will continue until a duplicate notification is detected. This procedure
    // ensures that if the system is missing some notifications, it will catch up eventually.
    // Notifications are delivered newest to oldest, making it likely all new ones are fetched in the first call.
    DatabaseStore *store = self.notificationsDb;
    
    NSUInteger newCount = res.newCount;
    NSLog(@"toolkit 801 new count: %d", newCount);
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
    NSLog(@"storedCount == totalCount %ld == %ld ",storedCount,totalCount);
    BOOL allStored = (storedCount == totalCount);
    
    if (allStored) {
        NSLog(@"asyncRefreshNotifications: stored:%li", (long) totalCount);
    }
    else {
        NSLog(@"asyncRefreshNotifications: stored partial notifications:%li of %li", (long) storedCount, (long) totalCount);
    }
    NSLog(@"storedCount isZero");
    if (storedCount == 0) {
        [self setNotificationsBadgeCount:newCount];
        
        // check whether there is queued work to be done
        [self internalTryProcessNotificationSyncPoints];
        [self postNotification:kSFINotificationDidStore data:nil];
        // if nothing stored, then no need to tell the world
        return;
    }
    NSLog(@"AllStore is zero");
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

- (void)onNotificationCountResponse:(NotificationCountResponse *)res {
    
    if (!res) {
        return;
    }
    
    if (res.error) {
        return;
    }
    
    // Store the notifications and stop tracking the pageState that they were associated with
    [self setNotificationsBadgeCount:res.badgeCount];
    
    if (res.badgeCount > 0) {
        [self tryRefreshNotifications];
    }
    
}

- (void)onNotificationClearCountResponse:(NotificationClearCountResponse*)res {
    if (!res) {
        return;
    }
    if (res.error) {
        
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
    if (!self.config.enableNotifications || self.currentConnectionMode== SFIAlmondConnectionMode_local) {
        return;
    }
    
    if (![ConnectionStatus isCloudLoggedIn]) {
        return;
    }
    NSLog(@"internalAsyncFetchNotifications");
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
            return storedCmd.isExpired;
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
    
    [self asyncSendToNetwork:cmd];
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
    
    if (![ConnectionStatus isCloudLoggedIn]) {
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
            return storedCmd.isExpired;
        };
    }
    
    [self asyncSendToNetwork:cmd];
}

#pragma mark - Almond Mode change callbacks

- (void)onAlmondModeChangeCompletion:(NSDictionary*)res network:(Network *)network {
    //    if (!res.success) {
    //        return;
    //    }
    
    [network.networkState confirmPendingModeForAlmond];
    
    NSString *notification = kSFIDidCompleteAlmondModeChangeRequest;
    [self postNotification:notification data:nil];
}

- (void)onAlmondModeResponse:(AlmondModeResponse *)res network:(Network *)network {
    NSLog(@"onAlmondModeResponse ");
    if (res == nil) {
        return;
    }
    
    if (!res.success) {
        return;
    }
    if([res.almondMAC isEqualToString:self.currentAlmond.almondplusMAC]){
        [network.networkState markModeForAlmond:self.currentAlmond.almondplusMAC mode:res.mode];
        NSDictionary *modeNotifyDict =  @{
                                          @"CommandType": @"AlmondModeResponse",
                                          @"Mode" : @(res.mode).stringValue
                                          
                                          };
        self.mode_src = res.mode;
        [self postNotification:kSFIAlmondModeDidChange data:modeNotifyDict];
    }
}

- (void)onDynamicAlmondModeChange:(DynamicAlmondModeChange *)res network:(Network *)network {
    NSLog(@"onAlmondModeResponse::: ");
    if (res == nil) {
        return;
    }
    
    if (!res.success) {
        return;
    }
    NSLog(@"res dict %@",res);
    NSLog(@"res.mode: %d %@", res.mode ,self.currentAlmond.almondplusMAC  );
    //    NSString *modeString = res[@"Mode"];
    if([res.almondMAC isEqualToString:self.currentAlmond.almondplusMAC]){
        NSLog(@"Am I inside onDynamicAlmondModeChange");
        [network.networkState markModeForAlmond:self.currentAlmond.almondplusMAC mode:res.mode];
        
        NSDictionary *modeNotifyDict =  @{
                                          @"CommandType": @"DynamicAlmondModeUpdated",
                                          @"Mode" : @(res.mode).stringValue
                                          
                                          };
        self.mode_src = res.mode;
        [self postNotification:kSFIAlmondModeDidChange data:modeNotifyDict];
    }
}

#pragma mark - Device Log processing and SFIDeviceLogStoreDelegate methods

- (id <SFINotificationStore>)newDeviceLogStore:(NSString *)almondMac deviceId:(sfi_id)deviceId forWifiClients:(BOOL)isForWifiClients {
    DatabaseStore *db = self.deviceLogsDb;
    [db purgeAll];
    
    id <SFIDeviceLogStore> store = [db newDeviceLogStore:almondMac deviceId:deviceId delegate:self];
    [store ensureFetchNotifications:isForWifiClients]; // will callback to self (registered as delegate) to load notifications
    
    [self.network.networkState clearExpirableRequest:ExpirableCommandType_deviceLogRequest namespace:almondMac];
    
    return store;
}

- (void)tryRefreshDeviceLog:(NSString *)almondMac deviceId:(sfi_id)deviceId forWiFiClient:(BOOL)isForWifiClients {
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
        return storedCmd.isExpired;
    };
    
    DatabaseStore *store = self.deviceLogsDb;
    NSString *pageState = [store nextTrackedSyncPoint];
    
    NSDictionary *payload;
    if (isForWifiClients) {
        payload = pageState ? @{
                                @"mac" : almondMac,
                                @"client_id" : @(deviceId),
                                @"requestId" : pageState,
                                @"pageState" : pageState,
                                @"type" : @"wifi_client",
                                } : @{
                                      @"mac" : almondMac,
                                      @"client_id" : @(deviceId),
                                      @"requestId" : almondMac,
                                      @"type" : @"wifi_client",
                                      };
    }else{
        payload = pageState ? @{
                                @"mac" : almondMac,
                                @"device_id" : @(deviceId),
                                @"requestId" : pageState,
                                @"pageState" : pageState,
                                } : @{
                                      @"mac" : almondMac,
                                      @"device_id" : @(deviceId),
                                      @"requestId" : almondMac,
                                      };
    }
    [self internalSendJsonCommandToCloud:payload commandType:CommandType_DEVICELOG_REQUEST precondition:precondition];
}

- (void)deviceLogStoreTryFetchRecords:(id <SFIDeviceLogStore>)deviceLogStore forWiFiClient:(BOOL)isForWifiClients {
    [self tryRefreshDeviceLog:deviceLogStore.almondMac deviceId:deviceLogStore.deviceID forWiFiClient:isForWifiClients];
}

- (void)onDeviceLogSyncResponse:(NotificationListResponse *)res {
    if (!res) {
        return;
    }
    
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
    if (cmd) {
        cmd.networkPrecondition = precondition;
        [self asyncSendToNetwork:cmd];
    }
}
-(void)routerModeOnCurrentAlmond:(NSString *)routerMOde{
    self.currentAlmond.routerMode = routerMOde;
}


@end
