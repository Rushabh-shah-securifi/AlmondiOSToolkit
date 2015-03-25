//
//  SecurifiToolkit.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
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
#import <SecurifiToolkit/LoginResponse.h>
#import <SecurifiToolkit/Login.h>
#import <SecurifiToolkit/AffiliationUserRequest.h>
#import <SecurifiToolkit/AffiliationUserComplete.h>
#import <SecurifiToolkit/Signup.h>
#import <SecurifiToolkit/SignupResponse.h>
#import <SecurifiToolkit/Logout.h>
#import <SecurifiToolkit/LogoutResponse.h>
#import <SecurifiToolkit/LogoutAllRequest.h>
#import <SecurifiToolkit/LogoutAllResponse.h>
#import <SecurifiToolkit/AlmondListRequest.h>
#import <SecurifiToolkit/AlmondListResponse.h>
#import <SecurifiToolkit/DeviceDataHashRequest.h>
#import <SecurifiToolkit/DeviceDataHashResponse.h>
#import <SecurifiToolkit/DeviceListRequest.h>
#import <SecurifiToolkit/DeviceListResponse.h>
#import <SecurifiToolkit/DeviceValueRequest.h>
#import <SecurifiToolkit/DeviceValueResponse.h>

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

@class SecurifiConfigurator;
@class AlmondModeChangeRequest;
@class NotificationPreferences;

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

// Notification posted when an Almond's name has changed
extern NSString *const kSFIDidChangeAlmondName;

// Notification posted when a request for an Almond mode change has completed
extern NSString *const kSFIDidCompleteAlmondModeChangeRequest;

// Notification posted when an Almond Mode has changed;
// payload contains an instance of SFIAlmondMode
extern NSString *const kSFIAlmondModeDidChange;

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
- (SecurifiConfigurator*)configuration;

- (void)initToolkit;

- (void)shutdownToolkit;

- (void)closeConnection;

- (void)asyncSendToCloud:(GenericCommand *)command;

// Sends an update to a sensor device property.
// On completion, kSFIDidCompleteMobileCommandRequest is posted
- (sfi_id)asyncChangeAlmond:(SFIAlmondPlus*)almond device:(SFIDevice*)device value:(SFIDeviceKnownValues *)newValue;

- (BOOL)isCloudConnecting;

- (BOOL)isCloudOnline;

- (BOOL)isReachable;

- (BOOL)isLoggedIn;

- (BOOL)isAccountActivated;
- (int)minsRemainingForUnactivatedAccount;

- (BOOL)hasLoginCredentials;

- (void)asyncSendLoginWithEmail:(NSString*)email password:(NSString*)password;
- (NSString*)loginEmail;

- (void)asyncSendLogout;
- (void)asyncSendLogoutAllWithEmail:(NSString *)email password:(NSString *)password;

// Nils out the current Almond selection
- (void)removeCurrentAlmond;

// Specify the currently "viewed" Almond. May perform updates in the background to check on Hash values.
- (void)setCurrentAlmond:(SFIAlmondPlus *)almond;

// Returns the designated "current" Almond, or nil.
- (SFIAlmondPlus*)currentAlmond;

// Fetch the local copy of the Almond's attached to the logon account
- (NSArray*)almondList;

// Fetch the locally stored devices list for the Almond
- (NSArray*)deviceList:(NSString*)almondMac;

// Fetch the locally stored values for the Almond's devices
- (NSArray*)deviceValuesList:(NSString*)almondMac;

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
- (Scoreboard*)scoreboardSnapshot;

// Issues a command to the specified Almond router to reboot itself
- (sfi_id)asyncRebootAlmond:(NSString*)almondMAC;

//PY 150914 - Accounts
// Send a command to the cloud requesting to change the password for cloud account
- (void)asyncRequestChangeCloudPassword:(NSString*)currentPwd changedPwd:(NSString*)changedPwd;

// Send a command to the cloud requesting to delete cloud account
- (void)asyncRequestDeleteCloudAccount:(NSString*)password;

// Send a command to the cloud requesting to unlink the current Almond from cloud account
- (void)asyncRequestUnlinkAlmond:(NSString*)almondMAC password:(NSString*)password;

// Send a command to the cloud requesting to invite secondary user to the current Almond from cloud account
- (void)asyncRequestInviteForSharingAlmond:(NSString*)almondMAC inviteEmail:(NSString*)inviteEmailID;

// Send a command to the cloud requesting to remove another secondary user from the current Almond from cloud account
- (void)asyncRequestDeleteSecondaryUser:(NSString *)almondMAC email:(NSString*)emailID;

// Send a command to the cloud requesting to change the name of current Almond
- (void)asyncRequestChangeAlmondName:(NSString*)changedAlmondName almondMAC:(NSString*)almondMAC;

// Send a command to the cloud requesting to
- (void)asyncRequestMeAsSecondaryUser;

// Send a command to the cloud requesting to remove the user as secondary user from the current Almond from cloud account
- (void)asyncRequestDeleteMeAsSecondaryUser:(NSString*)almondMAC;

- (sfi_id)asyncUpdateAlmondWirelessSettings:(NSString *)almondMAC wirelessSettings:(SFIWirelessSetting *)settings;

- (sfi_id)asyncSetAlmondWirelessUsersSettings:(NSString *)almondMAC blockedDeviceMacs:(NSArray *)deviceMAC;

- (void)asyncRequestRegisterForNotification:(NSString*)deviceToken;

- (void)asyncRequestNotificationPreferenceList:(NSString*)almondMAC;

// Send a command to change the notification mode for the specific almond
- (sfi_id)asyncRequestAlmondModeChange:(NSString *)almondMAC mode:(SFIAlmondMode)newMode;

- (SFIAlmondMode)modeForAlmond:(NSString*)almondMac;

// Send a command to configure notifications for the specified devices. Supported actions are:
// kSFINotificationPreferenceChangeActionAdd;
// kSFINotificationPreferenceChangeActionDelete;
- (void)asyncRequestNotificationPreferenceChange:(NSString *)almondMAC deviceList:(NSArray *)deviceList forAction:(NSString*)action;

// Stores a notification record that originally entered the system as an Apple Push Notification
- (BOOL)storePushNotification:(SFINotification *)notification;

// an array of all SFINotification, newest to oldest
- (NSArray *)notifications;

- (void)markNotificationViewed:(SFINotification *)notification;

- (NSInteger)countUnviewedNotifications;

- (id <SFINotificationStore>)newNotificationStore;

// makes a copy of the notifications database; used for debugging
- (BOOL)copyNotificationStoreTo:(NSString*)filePath;

// Synchronizes the on-board Notifications database with the cloud
- (void)asyncRefreshNotifications;

@end
 
