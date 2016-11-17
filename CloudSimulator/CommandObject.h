////  CommandObject.h
//  SecurifiToolkit
//
//  Created by Masood on 29/09/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Login/Login.h"
#import "LoginResponse.h"
#import "CloudEndpoint.h"
#import "dummyCloudEndpoint.h"
#import "Network.h"
#import "AlmondNameChange.h"
#import "AlmondListResponse.h"
#import "AlmondListRequest.h"
#import "SFIAlmondPlus.h"
#import "DeviceDataHashResponse.h"
#import "DeviceListResponse.h"
#import "LogoutAllResponse.h"
#import "DeviceValueResponse.h"
#import "SFIDeviceKnownValues.h"
#import "SFIDeviceValue.h"
#import "SFIDevice.h"
#import "MobileCommandRequest.h"
#import "MobileCommandResponse.h"
#import "AlmondNameChange.h"
#import "AlmondNameChangeResponse.h"
#import "SensorChangeRequest.h"
#import "SensorChangeResponse.h"
#import "SensorForcedUpdateRequest.h"
#import "DeviceDataHashResponse.h"
#import "DeviceValueRequest.h"
#import "SensorChangeResponse.h"
#import "NotificationPreferenceListRequest.h"
#import "NotificationPreferenceListResponse.h"
#import "SFINotificationUser.h"
#import "SFINotificationDevice.h"
#import "AlmondModeRequest.h"
#import "AlmondModeResponse.h"
#import "AlmondModeChangeRequest.h"
#import "AlmondModeChangeResponse.h"
#import "GenericCommand.h"
#import "GenericCommandRequest.h"
#import "GenericCommandResponse.h"
#import "ValidateAccountRequest.h"
#import "ValidateAccountResponse.h"
#import "ResetPasswordRequest.h"
#import "ResetPasswordResponse.h"
#import "AffiliationUserComplete.h"
#import "AffiliationUserRequest.h"
#import "Signup.h"
#import "SignupResponse.h"
#import "AlmondNameChange.h"
#import "AlmondNameChangeResponse.h"
#import "ChangePasswordRequest.h"
#import "ChangePasswordResponse.h"
#import "DeleteAccountRequest.h"
#import "DeleteAccountResponse.h"
#import "UserInviteRequest.h"
#import "UserInviteResponse.h"
#import "AlmondAffiliationData.h"
#import "AlmondAffiliationDataResponse.h"
#import "UserProfileRequest.h"
#import "UserProfileResponse.h"
#import "UpdateUserProfileRequest.h"
#import "UpdateUserProfileResponse.h"
#import "MeAsSecondaryUserRequest.h"
#import "MeAsSecondaryUserResponse.h"
#import "DeleteMeAsSecondaryUserRequest.h"
#import "DeleteMeAsSecondaryUserResponse.h"
#import "DeleteSecondaryUserRequest.h"
#import "DeleteSecondaryUserResponse.h"
#import "UnlinkAlmondRequest.h"
#import "UnlinkAlmondResponse.h"
#import "NotificationListRequest.h"
#import "NotificationListResponse.h"
#import "DynamicAlmondModeChange.h"
#import "LoginTempPass.h"
#import "ScenesListRequest.h"
#import "MDJSON.h"
#import "SFINotification.h"
#import "NotificationRegistrationResponse.h"
#import "NotificationDeleteRegistrationResponse.h"

@interface CommandObject : NSObject



@property(nonatomic) BOOL isTrueDictInitialized;
@property(nonatomic) NSDictionary* trueResponseDict;

+ (instancetype)sharedInstance;
-(void)initializeTrueResponseDictionary;
-(NSMutableArray *)addDeviceData;
-(NSMutableArray *)addDeviceValues;
-(NSMutableArray *)dynamicDeviceValueUpdate:(MobileCommandRequest*)mobilerequest;
-(NSString *)encodeGenericData:(NSString *) dataIncomming;

-(SFINotification*)createnotification:(long )notificationId externalIDa:(NSString*)externalID almondMACa:(NSString*)almondMAC timea:(NSTimeInterval)time devicenamea:(NSString*)devicename deviceida:(unsigned int)deviceID devicetypea:(unsigned int)devicetype valueindexa:(unsigned int)valueindex valuetypea:(unsigned int)valuetype valuea:(NSString*)value vieweda:(BOOL)viewed debugcountera:(long)debugcounter;
-(void) storeDeviceData:(unsigned int)deviceType_dummy deviceType:(int)devicetype deviceID:(int)deviceid OZWNode:(NSString *)ozwnode zigBeeEUI64:(NSString *) zigbeeeui64 zigBeeShortID:(NSString*)zigbeeshortid associationTimestamp:(NSString*)associationtimestamp deviceTechnology:(int)devicetechnology notificationMode:(int)notificationmode almondMAC:(NSString*)almondmac allowNotification:(NSString*)allownotification location:(NSString*)location valueCount:(int)valuecount deviceFunction:(NSString*)devicefunction deviceTypeName:(NSString*)devicetypename friendlyDeviceType:(NSString*)friendlydevicetype deviceName:(NSString*)devicename listarray:(NSMutableArray*)Listarray;
-(SFIDeviceKnownValues *) createKnownValuesWithIndex:(int)index PropertyType_:(int)propertytype valuetype_:(NSString *)valuetype valuename_:(NSString *)valuename value_:(NSString *)value;
-(SFIDeviceValue *)createDeviceValue:(unsigned int)valueCount deviceID:(unsigned int)deviceid isPresent:(BOOL)ispresent knownValueArray:(NSArray *)knownvaluearray;
-(LoginResponse*) createLoginResponseWithUserID:(NSString*)userID tempPass:(NSString*)temppass reason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful;
-(LogoutAllResponse*) logoutAllResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful;
-(SignupResponse*) signupResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful;
-(ValidateAccountResponse*) validateAccountResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful;
-(ResetPasswordResponse*) resetPasswordResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful;
-(AffiliationUserComplete*) AffiliationUserCompleteWithAlmondPlusName:(NSString*)almondPlusName almondPlusMAC:(NSString*)almondPlusMAC reason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful wifiSSID:(NSString*)wifiSSID wifiPassword:(NSString*)wifiPassword;
-(AlmondListResponse *)almondListResponseWithAction:(NSString *)action deviceCount:(unsigned int)deviceCount almondPlusMACList:(NSMutableArray *)almondPlusMACList isSuccessful:(BOOL)isSuccessful reason:(NSString *)reason;
-(SFIAlmondPlus*) createAlmondPlusWithAlmondPlusName:(NSString*)almondPlusName almondPlusMAC:(NSString*)almondPlusMAC index:(int)index colorCodeIndex:(int)colorCodeIndex userCount:(int)userCount accessEmailIDs:(NSMutableArray*)accessEmailIDs isExpanded:(BOOL)isExpanded ownerEmailID:(NSString*)ownerEmailID linkType:(unsigned int)linkType;
-(DeviceDataHashResponse*) deviceDataHashResponseWithAlmondHash:(NSString*)almondHash isSuccessful:(BOOL)isSuccessful reason:(NSString*)reason;
-(DeviceListResponse *)deviceListResponseWithAlmondMAC:(NSString *)almondMAC deviceCount:(unsigned int)deviceCount deviceList:(NSMutableArray *)deviceList isSuccessful:(BOOL)isSuccessful reason:(NSString *)reason;
-(DeviceValueResponse *)deviceValueResponseWithAlmondMAC:(NSString *)almondMAC deviceCount:(unsigned int)deviceCount deviceValueList:(NSMutableArray *)deviceValueList isSuccessful:(BOOL)isSuccessful reason:(NSString *)reason;
-(MobileCommandResponse*) mobileCommandRespWithisSuccessful:(BOOL)isSuccessful reason:(NSString*)reason mobileInternalIndex:(unsigned int)mobileInternalIndex;
-(AlmondNameChangeResponse*) almondNameChangeResponseWithinternalIndex:(NSString*) internalIndex isSuccessful:(BOOL)isSuccessful;
-(SensorChangeResponse*) sensorChangeResponseWithinternalIndex:(unsigned int) mobileInternalIndex isSuccessful:(BOOL)isSuccessful;
-(AlmondModeChangeResponse*) almondModeChangeResponseWithReason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful;
-(NotificationPreferenceListResponse*) notificationPreferenceListResponseWithAlmondMAC:(NSString *)almondMAC reason:(NSString*)reason reasonCode:(int)reasoncode isSuccessful:(BOOL)isSuccessful preferenceCount:(int)preferenceCount notificationUser:(SFINotificationUser *)notificationUser notificationDeviceList:(NSMutableArray *)notificationDeviceList;
-(SFINotificationDevice*) notificationDeviceWithDeviceID:(int)deviceID valueIndex:(int)valueIndex notificationMode:(SFINotificationMode)notificationMode;
-(SFINotificationUser*) notificationUserWithUserID:(NSString *)userID preferenceCount:(int)preferenceCount notificationDeviceList:(NSArray *)notificationDeviceList;
-(NSString *)encodeGenericDataForString:(NSString *)str ;
-(GenericCommandResponse*) genericCommandResponseWithAlmondMAC:(NSString*)almondMAC reason:(NSString*)reason mobileInternalIndex:(unsigned int)mobileInternalIndex isSuccessful:(BOOL)isSuccessful applicationID:(NSString*)applicationID genericData:(NSString*)genericData;
-(ChangePasswordResponse*) changePasswordResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason;
-(DeleteAccountResponse*) deleteAccountResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason;
-(UserInviteResponse*) userInviteResponseWithisSuccessful:(BOOL)isSuccessful internalIndex:(NSString*)internalIndex reasonCode:(int)reasoncode reason:(NSString*)reason;
-(AlmondAffiliationDataResponse*) almondAffiliationDataResponseWithisSuccessful:(BOOL)isSuccessful almondCount:(int)almondCount reason:(NSString*)reason almondList:(NSMutableArray *)almondList;
-(UpdateUserProfileResponse*) updateUserProfileResponseWithisSuccessful:(BOOL)isSuccessful internalIndex:(NSString*)internalIndex reasonCode:(int)reasoncode reason:(NSString*)reason;
-(UserProfileResponse*) userProfileResponseWithisSuccessful:(BOOL)isSuccessful firstName:(NSString*)firstName lastName:(NSString*)lastName addressLine1:(NSString*)addressLine1 addressLine2:(NSString*)addressLine2 addressLine3:(NSString*)addressLine3 country:(NSString*)country zipCode:(NSString*)zipCode reasonCode:(int)reasoncode reason:(NSString*)reason;
-(MeAsSecondaryUserResponse*) meAsSecondaryUserResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason almondCount:(int)almondCount almondList:(NSMutableArray *)almondList ;
-(DeleteSecondaryUserResponse*) deleteSecondaryUserResponseWithisSuccessful:(BOOL)isSuccessful internalIndex:(NSString*)internalIndex reasonCode:(int)reasoncode reason:(NSString*)reason;
-(DeleteMeAsSecondaryUserResponse*) deleteMeAsSecondaryUserResponseWithisSuccessful:(BOOL)isSuccessful internalIndex:(NSString*)internalIndex reasonCode:(int)reasoncode reason:(NSString*)reason;
-(UnlinkAlmondResponse*) unlinkAlmondResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason;
-(NotificationRegistrationResponse*) notificationRegistrationResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason;
-(NotificationDeleteRegistrationResponse*) notificationDeleteRegistrationResponseWithisSuccessful:(BOOL)isSuccessful reasonCode:(int)reasoncode reason:(NSString*)reason;
-(AlmondModeResponse *)almondModeResponseForUserId:(NSString*)userId AlmondMAC:(NSString *)almondMAC success:(BOOL)success reasonCode:(unsigned int)reasonCode reason:(NSString *)reason mode:(unsigned int)mode;
-(NotificationListResponse*) notificationListResponseWithPageState:(NSString *)pageState requestId:(NSString *)requestId notifications:(NSArray *)notifications newCount:(NSInteger)newCount;
-(NSData *) encodeDynamicCreateSceneWithDict:(NSDictionary *)mainDict;
-(NSData *) encodeDynamicUpdateSceneWithDict:(NSDictionary *)mainDict;
-(NSData *) encodeDynamicDeleteSceneWithDict:(NSDictionary *)mainDict;
-(NSData *) encodeDynamicActivateSceneWithDict:(NSDictionary *)mainDict;
-(NSData *) encodeUpdateClientWithDict:(NSDictionary *)mainDict;
-(NSData *) encodeRemoveClientWithDict:(NSDictionary *)mainDict;
@end
