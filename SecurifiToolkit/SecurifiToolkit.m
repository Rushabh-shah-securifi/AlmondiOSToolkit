//
//  SecurifiToolkit.m
//  SecurifiToolkit

//  Created by Nirav Uchat on 7/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.

//git testing
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "Network.h"
#import "NetworkState.h"
#import "Login.h"
#import "LoginTempPass.h"
#import "LogoutAllRequest.h"
#import "KeyChainWrapper.h"
#import "ChangePasswordRequest.h"
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
#import "ScanNowParser.h"
#import "SceneParser.h"
#import "RuleParser.h"
#import "DeviceParser.h"
#import "DataBaseManager.h"
#import "RouterParser.h"
#import "BrowsingHistoryDataBase.h"
#import "ConnectionStatus.h"
#import "CreateJSON.h"
#import "HTTPRequest.h"
#import "KeyChainAccess.h"
#import "AlmondManagement.h"
#import "CompleteDB.h"
#import "LocalNetworkManagement.h"
#import "WebSocketEndpoint.h"
#import "NotificationAccessAndRefreshCommands.h"
#import "NotificationPreferenceListCallbacks.h"
#import <SecurifiToolkit/ClientParser.h>
#import "AlmondPlan.h"
#import "SubscriptionParser.h"
#import "AlmondPropertiesParser.h"

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


@interface SecurifiToolkit () <NetworkDelegate>
@property(nonatomic, readonly) SFIReachabilityManager *cloudReachability;
@property(nonatomic, readonly) dispatch_queue_t networkCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t networkDynamicCallbackQueue;
@property(nonatomic, readonly) dispatch_queue_t commandDispatchQueue;
@property(nonatomic, strong) RuleParser *ruleParser;
@property(nonatomic, strong) SceneParser *sceneParser;
@property(nonatomic, strong) ClientParser *clientParser;
@property(nonatomic,strong) ScanNowParser *scanNowParser;
@property(nonatomic, strong) DeviceParser *deviceParser;
@property(nonatomic, strong) RouterParser *routerParser;
@property(nonatomic) SubscriptionParser *subscriptionParser;
@property(nonatomic) AlmondPropertiesParser *almondPropertiesParser;
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
    self.almondProperty = [[AlmondProperties alloc]init];
    self.subscription = [NSMutableDictionary new];
    
    self.ruleParser =[[RuleParser alloc]init];
    self.sceneParser =[[SceneParser alloc]init];
    self.clientParser =[[ClientParser alloc]init];
    self.scanNowParser = [[ScanNowParser alloc]init];
    self.deviceParser = [[DeviceParser alloc]init];
    self.routerParser = [[RouterParser alloc]init];
    self.subscriptionParser = [[SubscriptionParser alloc]init];
    self.almondPropertiesParser = [[AlmondPropertiesParser alloc]init];
    
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
        [AlmondManagement onDynamicAlmondModeChange:res network:endpoint];
    
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
    SFIAlmondPlus *current = [AlmondManagement currentAlmond];
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

-(void)writeConnectionModeToDefaults:(enum SFIAlmondConnectionMode)mode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:mode forKey:kPREF_DEFAULT_CONNECTION_MODE];
}

- (void)setConnectionMode:(enum SFIAlmondConnectionMode)mode{
    [self writeConnectionModeToDefaults:mode];
    [self tryShutdownAndStartNetworks];
    [self postNotification:kSFIDidChangeAlmondConnectionMode data:nil];
}

// for changing network settings
// ensures a local connection for the specified almond is shutdown and, if needed, restarted
- (void)tryShutdownAndStartNetworks{
    if (!self.config.enableLocalNetworking) {
        return;
    }
    //FORCED_DISCONNECT state is added here to make sure that toggle between cloud network and local network does not break;
    [self tearDownNetwork];
    [self asyncInitNetwork];
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

- (SFIAlmondConnectionStatus)connectionStatusFromNetworkState:(ConnectionStatusType)status {
    switch (status) {
        case (ConnectionStatusType)NO_NETWORK_CONNECTION:
            return SFIAlmondConnectionStatus_disconnected;
        case (ConnectionStatusType)IS_CONNECTING_TO_NETWORK:
            return SFIAlmondConnectionStatus_connecting;
        case (ConnectionStatusType)CONNECTED_TO_NETWORK:
            return SFIAlmondConnectionStatus_connected;
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
        NSLog(@"onReachability is called when app is in foreground");
        if([ConnectionStatus getConnectionStatus] == (ConnectionStatusType*)NO_NETWORK_CONNECTION && self.currentConnectionMode == SFIAlmondConnectionMode_cloud){
            NSLog(@"onReachability is called from inside the case");
        
            NSLog(@"%d is the cloud reachability", self.isCloudReachable);
            
            [self asyncInitNetwork];
        }
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
    [self tryShutdownAndStartNetworks];
}


// Initialize the SDK. Can be called repeatedly to ensure the SDK is set-up.
- (void) asyncInitNetwork {
    __weak SecurifiToolkit *block_self = self;
    
    if (block_self.isShutdown) {
        DLog(@"INIT SDK. SDK is already shutdown. Returning.");
        return;
    }
    
    ConnectionStatusType state = [ConnectionStatus getConnectionStatus];
    switch (state) {
        case AUTHENTICATED:
        case CONNECTED_TO_NETWORK:{
            NSLog(@"INIT SDK. connection established already. Returning.");
            return;
        };
        case IS_CONNECTING_TO_NETWORK: {
            NSLog(@"INIT SDK. connection already initializing. Returning.");
            return;
        };
        case NO_NETWORK_CONNECTION:
        default: {
            NSLog(@"INIT SDK. connection needs establishment. Passing thru");
        };
    }
    
    NSLog(@"setupnetwork is called from asyncinitnetwork");
    [block_self setUpNetwork];
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

-(void)cleanUp{
    NSLog(@"%@ is the scenes list after cleanup", self.devices);
    if(self.devices!=nil && self.devices.count>0)
        [self.devices removeAllObjects];
     if(self.scenesArray!=nil && self.scenesArray.count>0)
        [self.scenesArray removeAllObjects];
     if(self.clients!=nil && self.clients.count>0)
        [self.clients removeAllObjects];
     if(self.ruleList!=nil && self.ruleList.count>0)
        [self.ruleList removeAllObjects];
    self.almondProperty = [AlmondProperties new];
}


-(void)removeObjectFromArray:(NSMutableArray *)array{
        array = nil;
        if(array==nil ){
            NSLog(@"i am not crashing");
            [array removeAllObjects];
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
    }
    
    BOOL success = [self.network submitCommand:command];
    
    NSLog(@"boolean value is %d",success);
    if (success) {
        NSLog(@"[Generic cmd: %d] send success", command.commandType);
    }else {
        NSLog(@"[Generic cmd: %d] send error", command.commandType);
    }
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
        [self requestAlmondList];
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

- (void)requestAlmondList {
    NSMutableDictionary *dataValueAlmondList = [NSMutableDictionary new];
    [dataValueAlmondList setValue:GET_ALMOND_LIST forKey:COMMAND_TYPE];
    [self asyncSendRequest:CommandType_ALMOND_LIST commandString:GET_ALMOND_LIST payloadData:dataValueAlmondList];
}


- (void)onLogoutResponse {
    //clear almond subscriptions
    [self.subscription removeAllObjects];
    
    [self tearDownLoginSession];
    [self tearDownNetwork];
    [self postNotification:kSFIDidLogoutNotification data:nil];
}


- (void)onLogoutAllResponse:(LoginResponse *)res {
    if (res.isSuccessful) {
        DLog(@"SDK received success on Logout All");
        [self tearDownLoginSession];
        NSLog(@"I am called");
        [self tearDownNetwork];
    }
    
    [self postNotification:kSFIDidLogoutAllNotification data:res];
}

-(void) sendTempPassLoginCommand{
    __weak SecurifiToolkit *block_self = self;
    GenericCommand *cmd;
    BOOL cmdSendSuccess;
    // Send logon credentials
    block_self.network.loginStatus = NetworkLoginStatusInProcess;
    NSLog(@"%s: sending temp pass credentials", __PRETTY_FUNCTION__);
    cmd = [self makeTempPassLoginCommand];
    cmdSendSuccess = [block_self.network submitCommand:cmd];
    if (!cmdSendSuccess) {
        NSLog(@"%s: failed on sending login command", __PRETTY_FUNCTION__);
    }
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


- (void)onDeleteAccountResponse:(DeleteAccountResponse *)res {
    if (res.isSuccessful) {
        DLog(@"SDK received success on Delete Account");
        // treat it like a logout; clean up and tear down state
        [self onLogoutResponse];
    }
}


- (NSArray *)notificationPrefList:(NSString *)almondMac {
    return [self.dataManager readNotificationPreferenceList:almondMac];
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


#pragma mark - Account related commands
- (void) asyncSendRequest:(CommandType*)commandType commandString:(NSString*)commandString payloadData:(NSMutableDictionary*)data{
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = commandType;
    cmd.command = [CreateJSON withCommandString:commandString getJSONStringfromDictionary:data];
    [self asyncSendToNetwork:cmd];
}


#pragma mark - Network management
-(struct PopUpSuggestions) suggestionsFromNetworkStateAndConnectiontype {
    NSString *title;
    NSString *subTitle1, *subTitle2;
    SFIAlmondConnectionMode mode1=0, mode2=0;
    BOOL presentLocalNetworkSettings = false;
    SecurifiToolkit* toolKit = [SecurifiToolkit sharedInstance];
    
    if([ConnectionStatus getConnectionStatus]==AUTHENTICATED){
        if([toolKit currentConnectionMode] == SFIAlmondConnectionMode_cloud){
            
            SFIAlmondLocalNetworkSettings *settings = [LocalNetworkManagement getCurrentLocalAlmondSettings];
            
            NSArray* localAlmonds = [AlmondManagement localLinkedAlmondList];
            NSLog(@"%@ is the local almond mac name",settings.almondplusMAC);
            if (settings){
                for(SFIAlmondPlus* localAlmond in localAlmonds){
                    if([settings.almondplusMAC isEqualToString:localAlmond.almondplusMAC]){
                        [AlmondManagement writeCurrentAlmond:localAlmond];
                        break;
                    }
                }
                title = NSLocalizedString(@"alert.message-Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                subTitle1 = NSLocalizedString(@"switch_local", @"Switch to Local Connection");
                mode1 = SFIAlmondConnectionMode_local;
            }else{
                title = NSLocalizedString(@"alert msg offline Local connection not supported.", @"Local connection settings are missing.");
                subTitle1 = NSLocalizedString(@"Add Local Connection Settings", @"Add Local Connection Settings");
                presentLocalNetworkSettings = YES;
                mode1 = SFIAlmondConnectionMode_local;
            }
        }else{
            title = NSLocalizedString(@"alert.message-Connected to your Almond via local.", @"Connected to your Almond via local.");
            subTitle1 = NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection");
            mode1 = SFIAlmondConnectionMode_cloud;
        }
    }else if([ConnectionStatus getConnectionStatus]==NO_NETWORK_CONNECTION || [ConnectionStatus getConnectionStatus] == IS_CONNECTING_TO_NETWORK){
        if([toolKit currentConnectionMode] == SFIAlmondConnectionMode_cloud){
            title = NSLocalizedString(@"Alert view fail-Cloud connection to your Almond failed. Tap retry or switch to local connection.", @"Cloud connection to your Almond failed. Tap retry or switch to local connection.");
            subTitle1 = NSLocalizedString(@"switch_local", @"Switch to Local Connection");
            subTitle2 = @"Retry Cloud Connection";//NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection");
            mode1 = SFIAlmondConnectionMode_local;
            mode2 = SFIAlmondConnectionMode_cloud;
        }else{
            title = NSLocalizedString(@"local_conn_failed_retry", "Local connection to your Almond failed. Tap retry or switch to cloud connection.");
            subTitle1 = NSLocalizedString(@"alert title offline Local Retry Local Connection", @"Retry Local Connection");
            subTitle2 = NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection");
            mode1 = SFIAlmondConnectionMode_local;
            mode2 = SFIAlmondConnectionMode_cloud;
        }
    }
    
    struct PopUpSuggestions data;
    data.title = title;
    data.subTitle1 = subTitle1;
    data.subTitle2 = subTitle2;
    data.mode1 = mode1;
    data.mode2 = mode2;
    data.presentLocalNetworkSettings = presentLocalNetworkSettings;
    
    return data;
}

-(void) setUpNetwork{
    enum SFIAlmondConnectionMode mode = [self currentConnectionMode];
    Network *network = nil;
    NetworkConfig *networkConfig = nil;
    [self tearDownNetwork];
    switch (mode) {
        case SFIAlmondConnectionMode_cloud:{
            NSLog(@"entering the cloud mode");
            networkConfig = [NetworkConfig cloudConfig:self.config useProductionHost:self.useProductionCloud];
        }
        break;
        case SFIAlmondConnectionMode_local:{
            SFIAlmondPlus* almond = [AlmondManagement currentAlmond];
            NSLog(@"Entering the local mode %@",almond.almondplusMAC);
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
    if (!almondMac) {
        return NO;
    }
    if (!self.config.enableLocalNetworking) {
        return NO;
    }
    
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



#pragma mark - NetworkDelegate methods
- (void)networkConnectionDidEstablish:(Network *)network {
    if (network == self.network) {
        self.scoreboard.connectionCount++;
    }
    
    if([self currentConnectionMode] == SFIAlmondConnectionMode_local)
        [ConnectionStatus setConnectionStatusTo:(ConnectionStatusType)AUTHENTICATED];
    BOOL isCloudConnection = [self currentConnectionMode] == (SFIAlmondConnectionMode)SFIAlmondConnectionMode_cloud ?YES : NO;
    
    if(isCloudConnection){
        BOOL hasLoginCredentials = [KeyChainAccess hasLoginCredentials];
        if(hasLoginCredentials){
            [self sendTempPassLoginCommand];
        }else{
            // This event is very important because it will prompt the UI not to wait for events and immediately show a logon screen
            // We probably should track things down and find a way to remove a dependency on this event in the UI.
            [self postNotification:kSFIDidLogoutNotification data:nil];
            return;
        }
    }else{
        SFIAlmondPlus* plus = [AlmondManagement currentAlmond];
        [self asyncSendToNetwork:[GenericCommand requestSensorDeviceList:plus.almondplusMAC] ];
        [self asyncSendToNetwork:[GenericCommand requestAlmondClients:plus.almondplusMAC] ];
        [self asyncSendToNetwork:[GenericCommand requestSceneList:plus.almondplusMAC] ];
        [self asyncSendToNetwork:[GenericCommand requestAlmondRules:plus.almondplusMAC]];
        [self asyncSendToNetwork:[GenericCommand requestAlmondProperties:plus.almondplusMAC]];
        [self asyncSendToNetwork:[GenericCommand requestScanNow:plus.almondplusMAC]];
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
            
        case CommandType_GENERIC_COMMAND_RESPONSE: {
            GenericCommandResponse *res = payload;
            [AlmondManagement onAlmondRouterGenericCommandResponse:res network:network];
            break;
        }
            
        case CommandType_GENERIC_COMMAND_NOTIFICATION: {
            GenericCommandResponse *res = payload;
            [AlmondManagement onAlmondRouterGenericNotification:res network:network];
            break;
        }
            
        case CommandType_ALMOND_MODE_CHANGE_RESPONSE: {
            [AlmondManagement onAlmondModeChangeCompletion:payload network:network];
            break;
        }
            
        case CommandType_ALMOND_MODE_RESPONSE: {
            NSLog(@"almond mode payload %@",payload);
            AlmondModeResponse *res = payload;
            [AlmondManagement onAlmondModeResponse:res network:network];
            break;
        }
            
        case CommandType_NOTIFICATION_REGISTRATION_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationRegistrationResponse *res = payload;
                [NotificationPreferenceListCallbacks onNotificationRegistrationResponseCallback:res];
            }
            break;
        }
            
        case CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE: {
            NSLog(@"toolkit - CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE");
            if (self.config.enableNotifications) {
                NotificationPreferenceListResponse *res = payload;
                [NotificationPreferenceListCallbacks onNotificationPrefListChange:res];
            }
            break;
        }
            
        case CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE: {
            NSLog(@"toolkit - CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE");
            if (self.config.enableNotifications) {
                NotificationPreferenceResponse *res = payload;
                [NotificationPreferenceListCallbacks onDeviceNotificationPreferenceChangeResponseCallback:res network:network];

            }
            break;
        }
            
        case CommandType_NOTIFICATIONS_SYNC_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationListResponse *res = payload;
                NSLog(@"CommandType_NOTIFICATIONS_SYNC_RESPONSE");
                [NotificationPreferenceListCallbacks onNotificationListSyncResponse:res network:network];
            }
            break;
        };
            
        case CommandType_NOTIFICATIONS_COUNT_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationCountResponse *res = payload;
                [NotificationPreferenceListCallbacks onNotificationCountResponse:res];
            }
            break;
        };
            
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationClearCountResponse *res = payload;
                [NotificationPreferenceListCallbacks onNotificationClearCountResponse:res];
            }
            break;
        };
            
        case CommandType_DEVICELOG_RESPONSE: {
            if (self.config.enableNotifications) {
                NotificationListResponse *res = payload;
                [DeviceLogsProcessing onDeviceLogSyncResponse:res];
            }
            break;
        };
            
        case CommandType_ALMOND_DYNAMIC_RESPONSE:{
            [AlmondManagement onAlmondDynamicResponse:payload];
        }
            
        case CommandType_ALMOND_LIST:{
            
            NSDictionary* response = [NSJSONSerialization JSONObjectWithData:payload
                                                                     options:kNilOptions
                                                                       error:nil];
            [AlmondManagement processTheAlmondManagementCommand:response withNetwork:network];
            
            int a=10;
            printf("%d is the value of the format specifier",a);
            break;
        }
            
        case CommandType_ALMOND_COMMAND_RESPONSE: {
            SFIGenericRouterCommand *res = payload;
            [AlmondManagement onAlmondRouterCommandResponse:res network:network];
            break;
        };
            
        case CommandType_DYNAMIC_ALMOND_MODE_CHANGE: {
            DynamicAlmondModeChange *obj = payload;
            [AlmondManagement onDynamicAlmondModeChange:obj network:network];
            break;
        }
        
        case CommandType_ALMOND_NAME_AND_MAC_RESPONSE: {
            NSDictionary *dict = payload;
            NSString *name = dict[@"Name"];
            NSString *mac_hex = dict[@"MAC"];
            NSString *mac = [SFIAlmondPlus convertMacHexToDecimal:mac_hex];
            NSLog(@"Came here CommandType_ALMOND_NAME_AND_MAC_RESPONSE %@ mac is %@",[AlmondManagement currentAlmond].almondplusMAC, mac);
            
            SFIAlmondPlus *current = [AlmondManagement currentAlmond];
            NSLog(@"Came here CommandType_ALMOND_NAME_AND_MAC_RESPONSE Inside CurrentAlmond equals %@",current.almondplusName);
            if ([current.almondplusName isEqualToString:name]) {
                NSLog(@"Came here CommandType_ALMOND_NAME_AND_MAC_RESPONSE Returning %@",current.almondplusName);
                return; // name is the same
            }
            DynamicAlmondNameChangeResponse *res = DynamicAlmondNameChangeResponse.new;
            res.almondplusMAC = current.almondplusMAC;
            res.almondplusName = name;
            [AlmondManagement onDynamicAlmondNameChange:res];
            break;
        }
        case CommandType_SUBSCRIPTIONS:{//only in cloud
            NSDictionary *dict = [payload objectFromJSONData];
            NSLog(@"dict: %@, payload: %@", dict, payload);
            self.subscription = [AlmondPlan getSubscriptions:dict[@"Almonds"]];
        }
            
        default:
            break;
    }
}
- (void)asyncRequestChangeAlmondName:(NSString *)changedAlmondName almondMAC:(NSString *)almondMAC {
    AlmondNameChange *req = [AlmondNameChange new];
    req.almondMAC = almondMAC;
    req.changedAlmondName = changedAlmondName;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_MOBILE_COMMAND;
    cmd.command = req;
    [self asyncSendToNetwork:cmd];
//    [self asyncSendToCloud:cmd];
}

- (void)networkDidReceiveDynamicUpdate:(Network *)network response:(id)payload responseType:(enum CommandType)commandType {
    if (network == self.network) {
        self.scoreboard.dynamicUpdateCount++;
        [self markCommandEvent:commandType];
    }
    switch (commandType) {
        case CommandType_DYNAMIC_ALMOND_NAME_CHANGE: {
            DynamicAlmondNameChangeResponse *obj = payload;
            [AlmondManagement onDynamicAlmondNameChange:obj];
            break;
        }
        case CommandType_DYNAMIC_NOTIFICATION_PREFERENCE_LIST: {
            if (self.config.enableNotifications) {
                DynamicNotificationPreferenceList *obj = payload;
                [NotificationPreferenceListCallbacks onDynamicNotificationPrefListChange:obj];
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



@end
