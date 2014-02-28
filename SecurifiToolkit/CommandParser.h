//
//  CommandParser.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml2/libxml/tree.h>
#import "LoginResponse.h"
#import "LogoutResponse.h"
#import "LogoutAllResponse.h"
#import "SignupResponse.h"
#import "SanityResponse.h"
#import "CommandTypes.h"
#import "AffiliationUserRequest.h"
#import "AffiliationUserComplete.h"
#import "SignupResponse.h"
#import "AlmondListResponse.h"
#import "DeviceDataHashResponse.h"
#import "DeviceListResponse.h"
#import "SFIDevice.h"
#import "DeviceValueResponse.h"
#import "SFIDeviceValue.h"
#import "SFIDeviceKnownValues.h"
#import "MobileCommandResponse.h"
#import "GenericCommandResponse.h"
#import "SFIAlmondPlus.h"
#import "ValidateAccountResponse.h"
#import "ResetPasswordResponse.h"
#import "SensorChangeResponse.h"
#import "DynamicAlmondNameChangeResponse.h"
@class LoginResponse, LogoutAllResponse;

@interface CommandParser : NSObject {
    
@private
    // Reference to the libxml parser context
    xmlParserCtxtPtr context;
    BOOL storingCharacters;
    unsigned int storingCommanfType;
    NSMutableData *characterBuffer;
    BOOL done;
    BOOL parsingCommand;
    id command;
    unsigned int commandType;
    
   
    /*
    LoginResponse *loginResponse;
    LogoutResponse *logoutResponse;
    LogoutAllResponse *logoutAllResponse;
    SignupResponse *signupResponse;
    AffiliationResponse *affiliationResponse;
     */
}
@property(nonatomic, retain) NSMutableArray         *tmpAlmondList;
@property(nonatomic, retain) NSMutableArray         *tmpDeviceList;
@property (nonatomic,retain) SFIDevice              *tmpDevice;
@property (nonatomic,retain) SFIDeviceValue         *tmpDeviceValue;
@property(nonatomic, retain) NSMutableArray         *deviceValues;
@property(nonatomic, retain) NSMutableArray         *knownDeviceValues;
@property(nonatomic, retain) SFIDeviceKnownValues   *tmpDeviceKnownValue;
@property(nonatomic, retain) NSString               *currentTmpMACValue;

//PY 151013 - Almond List - Name and MAC
@property(nonatomic, retain) SFIAlmondPlus          *tmpAlmond;


- (id) parseXML:(NSData *)xmlData;

/*
@property LoginResponse *loginResponse;
@property LogoutAllResponse *logoutResponse;
@property LogoutAllResponse *logoutAllResponse;
@property SignupResponse *signupResponse;
@property AffiliationResponse *affiliationResponse;
*/

@property (nonatomic, strong) id command;
 @property BOOL storingCharacters;
@property (nonatomic, strong) NSMutableData *characterBuffer;
@property BOOL done;
//@property BOOL parsingASong;
@property BOOL parsingCommand;
@property unsigned int commandType;
@property unsigned int storingCommandType;
//@property (nonatomic, strong) Song *currentSong;
//@property (nonatomic, strong) NSURLConnection *rssConnection;
//@property (nonatomic, strong) NSDateFormatter *parseFormatter;
@end
