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
#import <SecurifiToolkit/SensorChangeResponse.h>
#import <SecurifiToolkit/AlmondPlusSDKConstants.h>
#import <SecurifiToolkit/DynamicAlmondNameChangeResponse.h>
#import <SecurifiToolkit/SFIOfflineDataManager.h>

// Notification posted at the conclusion of a Login attempt.
// The payload should contain a LoginResponse indicating success or failure.
// Sent in response to a call to asyncSendLoginWithEmail:password:
extern NSString *const kSFIDidCompleteLoginNotification;

// Notification posted when the client has been logged out
extern NSString *const kSFIDidLogoutNotification;

// Notification posted when Logout All has been received
extern NSString *const kSFIDidLogoutAllNotification;

// Notification posted when the Almond list has been updated
extern NSString *const kSFIDidUpdateAlmondList;

// Notification posted when an Almond's name has changed
extern NSString *const kSFIDidChangeAlmondName;

// Notification posted when the device list has changed
extern NSString *const kSFIDidChangeDeviceList;

extern NSString *const kSFIDidChangeDeviceValueList;

@interface SecurifiToolkit : NSObject

+ (instancetype)sharedInstance;

- (void)initSDK;

- (void)shutdown;

- (void)asyncSendToCloud:(GenericCommand *)command;

- (BOOL)isCloudConnecting;

- (BOOL)isCloudOnline;

- (BOOL)isReachable;

- (BOOL)isLoggedIn;

- (BOOL)hasLoginCredentials;

- (void)asyncSendLoginWithEmail:(NSString*)email password:(NSString*)password;
- (NSString*)loginEmail;

- (void)asyncSendLogout;
- (void)asyncSendLogoutAllWithEmail:(NSString *)email password:(NSString *)password;

- (void)removeCurrentAlmond;
- (void)setCurrentAlmond:(SFIAlmondPlus*)almond colorCodeIndex:(int)assignedColor;

- (SFIAlmondPlus*)currentAlmond;
- (NSString*)currentAlmondName;

- (NSArray*)almondList;

- (void)asyncRequestDeviceHash:(NSString *)almondMac;

- (void)asyncRequestDeviceList:(NSString *)almondMac;

- (void)asyncRequestDeviceValueList:(NSString *)almondMac;

- (void)writeDeviceValueList:(NSArray *)deviceList currentMAC:(NSString *)almondMac;

@end
 
