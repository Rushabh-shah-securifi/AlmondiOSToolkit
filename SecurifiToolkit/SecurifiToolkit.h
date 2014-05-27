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

@interface SecurifiToolkit : NSObject

+(id)initSDK;
+(id)initSDKCloud;
+(id)sendtoCloud:(id)sender error:(NSError **)outError;
+(BOOL)isLoggedin;
+(NSInteger) getConnectionState;
@end
 