//
//  SecurifiToolkit.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SecurifiToolkit/SecurifiTypes.h>
#import <SecurifiToolkit/NSDate+Convenience.h>
#import <SecurifiToolkit/SFIAlmondPlus.h>
#import <SecurifiToolkit/SecurifiConfigurator.h>
#import <SecurifiToolkit/GenericCommand.h>
#import <SecurifiToolkit/SFIDevice.h>
#import <SecurifiToolkit/SFIDeviceValue.h>
#import <SecurifiToolkit/SFIDeviceKnownValues.h>
#import <SecurifiToolkit/Scoreboard.h>
#import <SecurifiToolkit/AlmondPlusSDKConstants.h>

#import <SecurifiToolkit/CommandTypes.h>
#import <SecurifiToolkit/AffiliationUserComplete.h>
#import <SecurifiToolkit/SignupResponse.h>
#import <SecurifiToolkit/AlmondListResponse.h>
#import <SecurifiToolkit/DeviceDataHashResponse.h>
#import <SecurifiToolkit/DeviceListResponse.h>
#import <SecurifiToolkit/DeviceValueResponse.h>

#import <SecurifiToolkit/LoginResponse.h>
#import <SecurifiToolkit/LogoutResponse.h>
#import <SecurifiToolkit/LogoutAllResponse.h>

#import <SecurifiToolkit/SFIReachabilityManager.h>
#import <SecurifiToolkit/MobileCommandRequest.h>
#import <SecurifiToolkit/MobileCommandResponse.h>
#import <SecurifiToolkit/GenericCommandRequest.h>
#import <SecurifiToolkit/GenericCommandResponse.h>
#import <SecurifiToolkit/ValidateAccountResponse.h>
#import <SecurifiToolkit/ResetPasswordResponse.h>
#import <SecurifiToolkit/SensorForcedUpdateRequest.h>
#import <SecurifiToolkit/ScenesListRequest.h>

#import <SecurifiToolkit/SensorChangeResponse.h>

#import <SecurifiToolkit/DynamicAlmondNameChangeResponse.h>
#import <SecurifiToolkit/UserProfileRequest.h>
#import <SecurifiToolkit/UserProfileResponse.h>
#import <SecurifiToolkit/BaseCommandRequest.h>
#import <SecurifiToolkit/ChangePasswordResponse.h>
#import <SecurifiToolkit/DeleteAccountResponse.h>
#import <SecurifiToolkit/UpdateUserProfileRequest.h>
#import <SecurifiToolkit/UpdateUserProfileResponse.h>
#import <SecurifiToolkit/AlmondAffiliationData.h>
#import <SecurifiToolkit/AlmondAffiliationDataResponse.h>
#import <SecurifiToolkit/AlmondNameChange.h>
#import <SecurifiToolkit/AlmondNameChangeResponse.h>
#import <SecurifiToolkit/UnlinkAlmondResponse.h>
#import <SecurifiToolkit/UserInviteResponse.h>
#import <SecurifiToolkit/DeleteSecondaryUserResponse.h>
#import <SecurifiToolkit/MeAsSecondaryUserResponse.h>
#import <SecurifiToolkit/DeleteMeAsSecondaryUserResponse.h>
#import <SecurifiToolkit/SFICredentialsValidator.h>

#import <SecurifiToolkit/SFIRouterSummary.h>
#import <SecurifiToolkit/SFIWirelessSetting.h>
#import <SecurifiToolkit/SFIWirelessSummary.h>
#import <SecurifiToolkit/SFIWirelessUsers.h>

#import <SecurifiToolkit/SFINotificationDevice.h>
#import <SecurifiToolkit/SFINotification.h>
#import <SecurifiToolkit/SFINotificationStore.h>
#import <SecurifiToolkit/SFIAlmondModeRef.h>

#import <SecurifiToolkit/AlmondVersionChecker.h>

#import <SecurifiToolkit/SFIGenericRouterCommand.h>
#import <SecurifiToolkit/SFIBlockedContent.h>
#import <SecurifiToolkit/SFIBlockedDevice.h>
#import "Client.h"
#import <SecurifiToolkit/SFIDevicesList.h>

#import <SecurifiToolkit/MDJSON.h>

#import "Device.h"
#import "DeviceKnownValues.h"
#import "Client.h"
#import "SFIOfflineDataManager.h"
#import "DatabaseStore.h"
#import "NetworkConfig.h"
#import "WebSocketEndpoint.h"
#import "DynamicAlmondModeChange.h"
#import "DeviceLogsProcessing.h"
#import "AlmondProperties.h"

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
#define ALMOND_AFFILIATION_DATA                             @"AlmondAffiliationData"
#define GET_ALMOND_LIST                                     @"GetAlmondList"
#define COMMAND_TYPE                                        @"CommandType"
#define ALMOND_LIST_RESPONSE                                @"AlmondListResponse"
#define USER_PROFILE_REQUEST                                @"UserProfileRequest"
#define GET_WIRELESS_SUMMARY_COMMAND @"<root><AlmondRouterSummary action=\"get\">1</AlmondRouterSummary></root>"
#define GET_WIRELESS_SETTINGS_COMMAND @"<root><AlmondWirelessSettings action=\"get\">1</AlmondWirelessSettings></root>"
#define GET_CONNECTED_DEVICE_COMMAND @"<root><AlmondConnectedDevices action=\"get\">1</AlmondConnectedDevices></root>"
#define GET_BLOCKED_DEVICE_COMMAND @"<root><AlmondBlockedMACs action=\"get\">1</AlmondBlockedMACs></root>"
#define APPLICATION_ID @"1001"

@class SecurifiConfigurator;
@class AlmondModeChangeRequest;
@class NotificationPreferences;
@class SFIAlmondLocalNetworkSettings;

// Notification posted at the conclusion of a Login attempt.
// The payload should contain a LoginResponse indicating success or failure.
// Sent in response to a call to asyncSendLoginWithEmail:password:
extern NSString *const kSFIDidCompleteLoginNotification;

// Notification posted when the client has been logged out
extern NSString *const kSFIDidLogoutNotification;

// Notification posted when Logout All has been received
extern NSString *const kSFIDidLogoutAllNotification;

// Posted when the current Almond selection is changed
extern NSString *const kSFIDidChangeCurrentAlmond;

// Notification posted when the Almond list has been updated
extern NSString *const kSFIDidUpdateAlmondList;

// Notification posted when the connection mode is changed
extern NSString *const kSFIDidChangeAlmondConnectionMode;

// Notification posted when an Almond's name has changed
extern NSString *const kSFIDidChangeAlmondName;

// Notification posted when a request for an Almond mode change has completed
extern NSString *const kSFIDidCompleteAlmondModeChangeRequest;

// Notification posted when an Almond Mode has changed;
// payload contains an instance of SFIAlmondMode
extern NSString *const kSFIAlmondModeDidChange;

// Notification posted when a response to a generic Almond Router command is received
extern NSString *const kSFIDidReceiveGenericAlmondRouterResponse;

// Notification posted when a MobileCommand request has completed. Payload contains the command itself, and
// a boxed NSTimeInterval indicating how long the request-response cycle took.
extern NSString *const kSFIDidCompleteMobileCommandRequest;

// Notification posted when registration for notifications succeeded
extern NSString *const kSFIDidRegisterForNotifications;

// Notification posted when registration for notifications failed
extern NSString *const kSFIDidFailToRegisterForNotifications;

// Notification posted when deregistration for notifications succeeded
extern NSString *const kSFIDidDeregisterForNotifications;

// Notification posted when deregistration for notifications failed
extern NSString *const kSFIDidFailToDeregisterForNotifications;

// Notification posted when a Push/Cloud notification has arrived
extern NSString *const kSFINotificationDidStore;
extern NSString *const kSFINotificationBadgeCountDidChange;
extern NSString *const kSFINotificationDidMarkViewed;

// Preferences for device notifications have changed; payload is Almond MAC address
extern NSString *const kSFINotificationPreferencesDidChange;

//Preference for individual device has changed
extern NSString *const kSFINotificationPreferencesListDidChange;

// Value used for the method asyncRequestNotificationPreferenceChange:deviceList:action: to enable notifications
extern NSString *const kSFINotificationPreferenceChangeActionAdd;

// Value used for the method asyncRequestNotificationPreferenceChange:deviceList:action: to disable notifications
extern NSString *const kSFINotificationPreferenceChangeActionDelete;

struct PopUpSuggestions {
    __unsafe_unretained NSString* title;
    __unsafe_unretained NSString* subTitle1;
    __unsafe_unretained NSString* subTitle2;
     int mode1;
     int mode2;
    BOOL presentLocalNetworkSettings;
};

@interface SecurifiToolkit : NSObject

@property(atomic) BOOL isShutdown;
@property(nonatomic, readonly) Scoreboard *scoreboard;
@property(nonatomic, readonly) SecurifiConfigurator *config;
@property(nonatomic, readonly) SFIOfflineDataManager *dataManager;

@property(nonatomic, readonly) DatabaseStore *notificationsDb;
@property(nonatomic, readonly) id <SFINotificationStore> notificationsStore;
@property(nonatomic, strong) Network *network;
//@property(nonatomic, readonly) DatabaseStore *notificationsDb;
// When YES connections will be made to the Securifi Production cloud servers.
// When NO the development servers will be used.
// Default is YES
// Changes take effect on next connection attempt. Use closeConnection to force a connection change.
@property(nonatomic) BOOL useProductionCloud;
@property(nonatomic) BOOL isAppInForeGround;
@property(atomic) NSMutableArray *scenesArray;
@property(atomic) NSMutableArray *clients;
@property(atomic) NSMutableArray *devices;
@property(atomic) NSMutableArray *ruleList;
@property(atomic) NSMutableDictionary *iotScanResults;
@property(atomic) NSDictionary *genericDevices;
@property(atomic) NSDictionary *genericIndexes;
@property(nonatomic)NSString *routerMode;
@property(nonatomic, readonly) DatabaseStore *deviceLogsDb;
@property(nonatomic) NSMutableDictionary *subscription;
@property(nonatomic) AlmondProperties *almondProperty;
@property(nonatomic)NSInteger lastScanTime;


-(Network*) createNetworkWithConfig:(NetworkConfig *)config;
-(void)createNetworkInstanceAndChangeDelegate:(SFIAlmondPlus*)plus webSocketEndPoint:(WebSocketEndpoint*)endpoint res:(DynamicAlmondModeChange *)res;

- (void)tearDownLoginSession;

- (void)postNotification:(NSString *)notificationName data:(id)payload;

- (void)purgeStoredData;

- (void)tryShutdownAndStartNetworks;

-(void) asyncInitCloud;

-(void)setUpNetwork;

-(void) tearDownNetwork;

+ (BOOL)isInitialized;

+ (void)initialize:(SecurifiConfigurator *)config;

+ (instancetype)sharedInstance;

// Returns a copy of the configuration currently in effect. Changes to the configuration have no effect on the shared instance.
- (SecurifiConfigurator *)configuration;

- (void) asyncInitNetwork;

- (void)shutdownToolkit;

- (void)closeConnection;

- (void)debugUpdateConfiguration:(SecurifiConfigurator *)configurator;

//- (sfi_id)asyncSendAlmondAffiliationRequest:(NSString *)linkCode;

- (void)asyncSendToNetwork:(GenericCommand *)command;

//This is the generic class to send request
- (void) asyncSendRequest:(CommandType*)commandNumber commandString:(NSString*)commandString fieldValues:(NSArray*)array;

//sending request with the payload value of NSmutabledictionary
- (void) asyncSendRequest:(CommandType*)commandType commandString:(NSString*)commandString payloadData:(NSMutableDictionary*)data;

// returns the desired connection mode; this mode is ignored in some cases when the Almond does not support it
// caller should use currentConnectionMode for actual one being used
// default mode indicates  the desired system setting and is useful to the UI in some cases
- (enum SFIAlmondConnectionMode)currentConnectionMode;

// configures which connection interface to use for communicating with the almond
// assumes local network settings are already configured for the almond.
- (void)setConnectionMode:(enum SFIAlmondConnectionMode)mode;

//// configure local network settings; if a connection is opened for the almond specified in the settings,
//// the connection is torn down and, depending on the current connection mode, restarted.
//- (void)setLocalNetworkSettings:(SFIAlmondLocalNetworkSettings *)settings;

- (enum SFIAlmondConnectionStatus)connectionStatusFromNetworkState:(enum ConnectionStatusType)status;

//// returns the Local Connection settings for the almond, or nil if none configured
//- (SFIAlmondLocalNetworkSettings *)localNetworkSettingsForAlmond:(NSString *)almondMac;

//- (void)tryUpdateLocalNetworkSettingsForAlmond:(NSString *)almondMac withRouterSummary:(const SFIRouterSummary *)summary;

//- (void)removeLocalNetworkSettingsForAlmond:(NSString *)almondMac;

-(struct PopUpSuggestions) suggestionsFromNetworkStateAndConnectiontype;

- (BOOL)isNetworkOnline;
//- (BOOL)isCloudLoggedIn;

- (BOOL)isCloudReachable;

- (BOOL)isCloudLoggedIn;

- (BOOL)isAccountActivated;

- (int)minsRemainingForUnactivatedAccount;

- (NSString *)loginEmail;

- (void)onLogoutResponse;

- (void)asyncSendLogout;


- (SFIAlmondPlus *)cloudAlmond:(NSString*)almondMac;

//mode_src for almond mode
@property int mode_src;

// Fetch the locally stored values for the Almond's notification preferences
- (NSArray *)notificationPrefList:(NSString *)almondMac;

// Send a command to the cloud requesting current values for the Almond's devices if device values have not been
// already requested once already on the same network connection
- (BOOL)tryRequestDeviceValueList:(NSString *)almondMac;

// Returns running stats on internals of this toolkit; useful for debugging and development
- (Scoreboard *)scoreboardSnapshot;

typedef NS_ENUM(unsigned int, SecurifiToolkitAlmondRouterRequest) {
    SecurifiToolkitAlmondRouterRequest_summary = 1,         // router summary information
    SecurifiToolkitAlmondRouterRequest_settings,            // detailed router settings
    SecurifiToolkitAlmondRouterRequest_connected_device,    // legacy: connected wifi clients (use SecurifiToolkitAlmondRouterRequest_wifi_clients)
    SecurifiToolkitAlmondRouterRequest_blocked_device,      // legacy: blocked wifi clients (use SecurifiToolkitAlmondRouterRequest_wifi_clients)
    SecurifiToolkitAlmondRouterRequest_wifi_clients,        // connected and blocked devices
};


// Sends commands directly to the specified Almond, requesting summary and settings information
- (void)asyncAlmondSummaryInfoRequest:(NSString *)almondMac;

- (sfi_id)asyncUpdateAlmondWirelessSettings:(NSString *)almondMAC wirelessSettings:(SFIWirelessSetting *)settings;

- (BOOL)useLocalNetwork:(NSString *)almondMac;

- (void)onDeviceListAndValuesResponse:(DeviceListResponse *)res network:(Network *)network;

-(void)cleanUp;

- (void)requestAlmondList;

- (void)initializeHelpScreenUserDefaults;

- (void)setScreenDefault:(NSString *)screen;

- (BOOL)isScreenShown:(NSString *)screen;

- (void)connectMesh;

- (void)shutDownMesh;

@end
