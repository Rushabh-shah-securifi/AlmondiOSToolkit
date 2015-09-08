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

#import <SecurifiToolkit/SecurifiConfigurator.h>
#import <SecurifiToolkit/GenericCommand.h>
#import <SecurifiToolkit/SFIDevice.h>
#import <SecurifiToolkit/SFIDeviceValue.h>
#import <SecurifiToolkit/SFIAlmondPlus.h>
#import <SecurifiToolkit/SFIDeviceKnownValues.h>
#import <SecurifiToolkit/Scoreboard.h>
#import <SecurifiToolkit/AlmondPlusSDKConstants.h>

#import <SecurifiToolkit/CommandTypes.h>
#import <SecurifiToolkit/AffiliationUserRequest.h>
#import <SecurifiToolkit/AffiliationUserComplete.h>
#import <SecurifiToolkit/Signup.h>
#import <SecurifiToolkit/SignupResponse.h>
#import <SecurifiToolkit/AlmondListRequest.h>
#import <SecurifiToolkit/AlmondListResponse.h>
#import <SecurifiToolkit/DeviceDataHashRequest.h>
#import <SecurifiToolkit/DeviceDataHashResponse.h>
#import <SecurifiToolkit/DeviceListRequest.h>
#import <SecurifiToolkit/DeviceListResponse.h>
#import <SecurifiToolkit/DeviceValueRequest.h>
#import <SecurifiToolkit/DeviceValueResponse.h>

#import <SecurifiToolkit/LoginResponse.h>
#import <SecurifiToolkit/LogoutResponse.h>
#import <SecurifiToolkit/LogoutAllResponse.h>

#import <SecurifiToolkit/SFIReachabilityManager.h>
#import <SecurifiToolkit/MobileCommandRequest.h>
#import <SecurifiToolkit/MobileCommandResponse.h>
#import <SecurifiToolkit/GenericCommandRequest.h>
#import <SecurifiToolkit/GenericCommandResponse.h>
#import <SecurifiToolkit/ValidateAccountRequest.h>
#import <SecurifiToolkit/ValidateAccountResponse.h>
#import <SecurifiToolkit/ResetPasswordRequest.h>
#import <SecurifiToolkit/ResetPasswordResponse.h>
#import <SecurifiToolkit/SensorForcedUpdateRequest.h>
#import <SecurifiToolkit/SensorChangeRequest.h>
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
#import <SecurifiToolkit/SFIConnectedDevice.h>
#import <SecurifiToolkit/SFIDevicesList.h>

#import <SecurifiToolkit/MDJSON.h>

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

// Notification posted when a device has been added or removed. Does not post on changes to attributes like device names.
extern NSString *const kSFIDidChangeDeviceList;

extern NSString *const kSFIDidChangeDeviceValueList;

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

// Value used for the method asyncRequestNotificationPreferenceChange:deviceList:action: to enable notifications
extern NSString *const kSFINotificationPreferenceChangeActionAdd;

// Value used for the method asyncRequestNotificationPreferenceChange:deviceList:action: to disable notifications
extern NSString *const kSFINotificationPreferenceChangeActionDelete;


@interface SecurifiToolkit : NSObject

// When YES connections will be made to the Securifi Production cloud servers.
// When NO the development servers will be used.
// Default is YES
// Changes take effect on next connection attempt. Use closeConnection to force a connection change.
@property(nonatomic) BOOL useProductionCloud;

+ (BOOL)isInitialized;

+ (void)initialize:(SecurifiConfigurator *)config;

+ (instancetype)sharedInstance;

// Returns a copy of the configuration currently in effect. Changes to the configuration have no effect on the shared instance.
- (SecurifiConfigurator *)configuration;

- (void)initToolkit;

- (void)shutdownToolkit;

- (void)closeConnection;

- (void)debugUpdateConfiguration:(SecurifiConfigurator *)configurator;

- (void)asyncSendToCloud:(GenericCommand *)command;

// Send a request to affiliate an Almond with the Cloud account. The link code is the code generated on the Almond
// and inputted by the user.
- (sfi_id)asyncSendAlmondAffiliationRequest:(NSString*)linkCode;

// Sends an update to a sensor device property.
// On completion, kSFIDidCompleteMobileCommandRequest is posted
- (sfi_id)asyncChangeAlmond:(SFIAlmondPlus *)almond device:(SFIDevice *)device value:(SFIDeviceKnownValues *)newValue;

- (sfi_id)asyncChangeAlmond:(SFIAlmondPlus *)almond device:(SFIDevice *)device name:(NSString *)deviceName location:(NSString *)deviceLocation;

// returns the default connection mode
- (enum SFIAlmondConnectionMode)defaultConnectionMode;

// returns the current connection interface used for communicating with the almond
// this mode is a logical AND of the default mode and the per-Almond settings.
- (enum SFIAlmondConnectionMode)connectionModeForAlmond:(NSString *)almondMac;

// configures which connection interface to use for communicating with the almond
// assumes local network settings are already configured for the almond.
- (void)setConnectionMode:(enum SFIAlmondConnectionMode)mode forAlmond:(NSString *)almondMac;

// configure local network settings; if a connection is opened for the almond specified in the settings,
// the connection is torn down and, depending on the current connection mode, restarted.
- (void)setLocalNetworkSettings:(SFIAlmondLocalNetworkSettings *)settings;

// returns the status of the connection interface
- (enum SFIAlmondConnectionStatus)connectionStatusForAlmond:(NSString *)almondMac;

// returns the Local Connection settings for the almond, or nil if none configured
- (SFIAlmondLocalNetworkSettings *)localNetworkSettingsForAlmond:(NSString *)almondMac;

- (void)removeLocalNetworkSettingsForAlmond:(NSString *)almondMac;

- (BOOL)isCloudConnecting;

- (BOOL)isNetworkOnline;

- (BOOL)isCloudOnline;

- (BOOL)isCloudReachable;

- (BOOL)isCloudLoggedIn;

- (BOOL)isAccountActivated;

- (int)minsRemainingForUnactivatedAccount;

- (BOOL)hasLoginCredentials;

- (void)asyncSendLoginWithEmail:(NSString *)email password:(NSString *)password;

- (NSString *)loginEmail;

- (void)asyncSendLogout;

- (void)asyncSendLogoutAllWithEmail:(NSString *)email password:(NSString *)password;

//Current Temperature Format for UI
- (BOOL)isCurrentTemperatureFormatFahrenheit;
- (void)setCurrentTemperatureFormatFahrenheit:(BOOL)format;
- (int)convertTemperatureToCurrentFormat:(int)temperature;
- (NSString*)getTemperatureWithCurrentFormat:(int)temperature;

// Nils out the current Almond selection
- (void)removeCurrentAlmond;

// Specify the currently "viewed" Almond. May perform updates in the background to check on Hash values.
- (void)setCurrentAlmond:(SFIAlmondPlus *)almond;

// Returns the designated "current" Almond, or nil.
- (SFIAlmondPlus *)currentAlmond;

// Fetch the local copy of the Almond's attached to the logon account
- (NSArray *)almondList;

// List of all Almonds that are locally linked only. Almonds that have both cloud and local links would be provided
// by almondList method. Can return nil.
- (NSArray *)localLinkedAlmondList;

// Fetch the locally stored devices list for the Almond
- (NSArray *)deviceList:(NSString *)almondMac;

// Fetch the locally stored values for the Almond's devices
- (NSArray *)deviceValuesList:(NSString *)almondMac;

// Fetch the locally stored values for the Almond's notification preferences
- (NSArray *)notificationPrefList:(NSString *)almondMac;

// Send a command to the cloud requesting a device list for the specified Almond
- (void)asyncRequestDeviceList:(NSString *)almondMac;

// Send a command to the cloud requesting current values for the Almond's devices
- (void)asyncRequestDeviceValueList:(NSString *)almondMac;

// Send a command to the cloud requesting current values for the Almond's devices if device values have not been
// already requested once already on the same network connection
- (BOOL)tryRequestDeviceValueList:(NSString *)almondMac;

// Returns running stats on internals of this toolkit; useful for debugging and development
- (Scoreboard *)scoreboardSnapshot;

- (sfi_id)asyncUpdateAlmondFirmware:(NSString *)almondMAC firmwareVersion:(NSString *)firmwareVersion;

// Issues a command to the specified Almond router to reboot itself
- (sfi_id)asyncRebootAlmond:(NSString *)almondMAC;

- (sfi_id)asyncSendAlmondLogs:(NSString *)almondMAC problemDescription:(NSString *)description;

//PY 150914 - Accounts
// Send a command to the cloud requesting to change the password for cloud account
- (void)asyncRequestChangeCloudPassword:(NSString *)currentPwd changedPwd:(NSString *)changedPwd;

// Send a command to the cloud requesting to delete cloud account
- (void)asyncRequestDeleteCloudAccount:(NSString *)password;

// Send a command to the cloud requesting to unlink the current Almond from cloud account
- (void)asyncRequestUnlinkAlmond:(NSString *)almondMAC password:(NSString *)password;

// Send a command to the cloud requesting to invite secondary user to the current Almond from cloud account
- (void)asyncRequestInviteForSharingAlmond:(NSString *)almondMAC inviteEmail:(NSString *)inviteEmailID;

// Send a command to the cloud requesting to remove another secondary user from the current Almond from cloud account
- (void)asyncRequestDeleteSecondaryUser:(NSString *)almondMAC email:(NSString *)emailID;

// Send a command to the cloud requesting to change the name of current Almond
- (void)asyncRequestChangeAlmondName:(NSString *)changedAlmondName almondMAC:(NSString *)almondMAC;

// Send a command to the cloud requesting to
- (void)asyncRequestMeAsSecondaryUser;

// Send a command to the cloud requesting to remove the user as secondary user from the current Almond from cloud account
- (void)asyncRequestDeleteMeAsSecondaryUser:(NSString *)almondMAC;

typedef NS_ENUM(unsigned int, SecurifiToolkitAlmondRouterRequest) {
    SecurifiToolkitAlmondRouterRequest_summary = 1,         // router summary information
    SecurifiToolkitAlmondRouterRequest_settings,            // detailed router settings
    SecurifiToolkitAlmondRouterRequest_connected_device,    // legacy: connected wifi clients (use SecurifiToolkitAlmondRouterRequest_wifi_clients)
    SecurifiToolkitAlmondRouterRequest_blocked_device,      // legacy: blocked wifi clients (use SecurifiToolkitAlmondRouterRequest_wifi_clients)
    SecurifiToolkitAlmondRouterRequest_wifi_clients,        // connected and blocked devices
};

// Sends commands directly to the specified Almond, requesting summary and settings information
- (void)asyncAlmondStatusAndSettingsRequest:(NSString *)almondMac request:(enum SecurifiToolkitAlmondRouterRequest)requestType;

// Sends commands directly to the specified Almond, requesting summary and settings information
- (void)asyncAlmondSummaryInfoRequest:(NSString *)almondMac;

- (sfi_id)asyncUpdateAlmondWirelessSettings:(NSString *)almondMAC wirelessSettings:(SFIWirelessSetting *)settings;

- (sfi_id)asyncSetAlmondWirelessUsersSettings:(NSString *)almondMAC blockedDeviceMacs:(NSArray *)deviceMAC;

- (void)asyncRequestRegisterForNotification:(NSString *)deviceToken;

- (void)asyncRequestNotificationPreferenceList:(NSString *)almondMAC;

// Send a command to change the notification mode for the specific almond
- (sfi_id)asyncRequestAlmondModeChange:(NSString *)almondMac mode:(SFIAlmondMode)newMode;

- (SFIAlmondMode)modeForAlmond:(NSString *)almondMac;

// Send a command to configure notifications for the specified devices. This is the way to set per-device preferences
// for receiving notifications. Each device Index is configured separately.
// Supported actions are:
// kSFINotificationPreferenceChangeActionAdd;
// kSFINotificationPreferenceChangeActionDelete;
- (void)asyncRequestNotificationPreferenceChange:(NSString *)almondMAC deviceList:(NSArray *)deviceList forAction:(NSString *)action;

- (NSInteger)countUnviewedNotifications;

- (id <SFINotificationStore>)newNotificationStore;

// makes a copy of the notifications database; used for debugging
- (BOOL)copyNotificationStoreTo:(NSString *)filePath;

// Initiates a process to synchronize the on-board Notifications database with the cloud.
// If a request is already in flight, this call fails fast and silently.
// Posts kSFINotificationDidStore when new notifications have been fetched.
- (void)tryRefreshNotifications;

// Called after all Notifications/Activity have been viewed. The Clear command is sent to the cloud to reset the
// global state shared across all logged-in devices.
- (void)tryClearNotificationCount;

// Called to synchronize the badge count as specified in a Push Notification payload. The badge count reflects then
// latest known global "new notification" count.
- (NSInteger)notificationsBadgeCount;

- (void)setNotificationsBadgeCount:(NSInteger)count;

- (id <SFINotificationStore>)newDeviceLogStore:(NSString *)almondMac deviceId:(sfi_id)deviceId;


@end
 
