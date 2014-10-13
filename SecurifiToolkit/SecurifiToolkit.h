//
//  SecurifiToolkit.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SecurifiToolkit/GenericCommand.h>
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
#import <SecurifiToolkit/SFIDevice.h>
#import <SecurifiToolkit/SFIDeviceValue.h>
#import <SecurifiToolkit/SFIAlmondPlus.h>
#import <SecurifiToolkit/SFIDeviceKnownValues.h>
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
#import <SecurifiToolkit/Scoreboard.h>
#import <SecurifiToolkit/SensorChangeResponse.h>
#import <SecurifiToolkit/AlmondPlusSDKConstants.h>
#import <SecurifiToolkit/DynamicAlmondNameChangeResponse.h>
#import <SecurifiToolkit/SFIOfflineDataManager.h>
#import <SecurifiToolkit/UserProfileRequest.h>
#import <SecurifiToolkit/UserProfileResponse.h>
#import <SecurifiToolkit/ChangePasswordRequest.h>
#import <SecurifiToolkit/ChangePasswordResponse.h>
#import <SecurifiToolkit/DeleteAccountRequest.h>
#import <SecurifiToolkit/DeleteAccountResponse.h>
#import <SecurifiToolkit/UpdateUserProfileRequest.h>
#import <SecurifiToolkit/UpdateUserProfileResponse.h>
#import <SecurifiToolkit/AlmondAffiliationData.h>
#import <SecurifiToolkit/AlmondAffiliationDataResponse.h>
#import <SecurifiToolkit/UnlinkAlmondRequest.h>
#import <SecurifiToolkit/UnlinkAlmondResponse.h>
#import <SecurifiToolkit/UserInviteRequest.h>
#import <SecurifiToolkit/UserInviteResponse.h>
#import <SecurifiToolkit/DeleteSecondaryUserRequest.h>
#import <SecurifiToolkit/DeleteSecondaryUserResponse.h>
#import <SecurifiToolkit/AlmondNameChange.h>
#import <SecurifiToolkit/AlmondNameChangeResponse.h>
#import <SecurifiToolkit/MeAsSecondaryUserRequest.h>
#import <SecurifiToolkit/MeAsSecondaryUserResponse.h>
#import <SecurifiToolkit/DeleteMeAsSecondaryUserRequest.h>
#import <SecurifiToolkit/DeleteMeAsSecondaryUserResponse.h>


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

// Notification posted when a device has been added or removed. Does not post on changes to attributes like device names.
extern NSString *const kSFIDidChangeDeviceList;

extern NSString *const kSFIDidChangeDeviceValueList;

// Notification posted when a MobileCommand request has completed. Payload contains the command itself, and
// a boxed NSTimeInterval indicating how long the request-response cycle took.
extern NSString *const kSFIDidCompleteMobileCommandRequest;


@interface SecurifiToolkit : NSObject

// When YES connections will be made to the Securifi Production cloud servers.
// When NO the development servers will be used.
// Default is YES
// Changes take effect on next connection attempt. Use closeConnection to force a connection change.
@property(nonatomic) BOOL useProductionCloud;

+ (instancetype)sharedInstance;

- (void)initToolkit;

- (void)shutdownToolkit;

- (void)closeConnection;

- (void)asyncSendToCloud:(GenericCommand *)command;

// Sends an update to a sensor device property.
// On completion, kSFIDidCompleteMobileCommandRequest is posted
- (void)asyncChangeAlmond:(SFIAlmondPlus*)almond device:(SFIDevice*)device value:(SFIDeviceKnownValues *)newValue;

- (BOOL)isCloudConnecting;

- (BOOL)isCloudOnline;

- (BOOL)isReachable;

- (BOOL)isLoggedIn;

-(BOOL) isAccountActivated;
-(int) minsRemainingForUnactivatedAccount;

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

// Synchronously locally store the device list
- (void)writeDeviceValueList:(NSArray *)deviceList currentMAC:(NSString *)almondMac;

// Send a command to the cloud requesting a device list for the specified Almond
- (void)asyncRequestDeviceList:(NSString *)almondMac;

// Send a command to the cloud requesting current values for the Almond's devices
- (void)asyncRequestDeviceValueList:(NSString *)almondMac;

// Send a command to the cloud requesting current values for the Almond's devices if device values have not been
// already requested once already on the same network connection
- (BOOL)tryRequestDeviceValueList:(NSString *)almondMac;

// Returns running stats on internals of this toolkit; useful for debugging and development
- (Scoreboard*)scoreboardSnapshot;

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
- (void)asyncRequestDelSecondaryUser:(NSString*)almondMAC email:(NSString*)emailID;

// Send a command to the cloud requesting to change the name of current Almond
- (void)asyncRequestChangeAlmondName:(NSString*)changedAlmondName almondMAC:(NSString*)almondMAC;

// Send a command to the cloud requesting to remove the user as secondary user from the current Almond from cloud account
- (void)asyncRequestDelMeAsSecondaryUser:(NSString*)almondMAC;
@end
 
