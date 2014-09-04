//
//  CommandParser.m
//  SecurifiToolkit


//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "CommandParser.h"
#import "GenericCommand.h"

#import <libxml2/libxml/tree.h>
#import "LoginResponse.h"
#import "LogoutResponse.h"
#import "LogoutAllResponse.h"
#import "SignupResponse.h"
#import "SanityResponse.h"
#import "CommandTypes.h"
#import "AffiliationUserComplete.h"
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

#pragma mark Constants

// The following constants are the XML element names and their string lengths for parsing comparison.
// The lengths include the null terminator, to ensure exact matches.
//Common Constant
static const char *kName_UserID =                           "UserID";
static const char *kName_TempPass =                         "TempPass";
static const char *kName_Reason =                           "Reason";
static const char *kName_KeepAlive =                        "KeepAlive";
static const char *kName_AffiliationCode =                  "Code";
static const char *kName_AlmondMAC =                        "AlmondplusMAC";
static const char *kName_AlmondName =                       "AlmondplusName";
//Response
static const char *kName_LoginResponse =                    "LoginResponse";
static const char *kName_SanityResponse =                   "SanityResponse";
//static const char *kName_AffiliationUserResponse =          "AffiliationUserResponse";
static const char *kName_AffiliationUserComplete =          "AffiliationUserCompleteResponse";
static const char *kName_SignupResponse =                   "SignupResponse";
//PY 160913 - Add Constants
static const char *kName_LogoutAllResponse =              "LogoutAllResponse";
//static const char *kName_AlmondPlusMAC =                  "AlmondplusMAC";
static const char *kName_AlmondListResponse =               "AlmondListResponse";
static const char *k_Success =                              "success";
static const char *k_True =                                 "true";
static const char *kName_DeviceDataHashResponse =           "DeviceDataHashResponse";
static const char *kName_Hash =                             "Hash";
static const char *kName_DeviceDataResponse =               "DeviceDataResponse";
static const char *kName_Device =                           "Device";
//static const char *kName_ID =                             "ID";
static const char *kName_DeviceName =                       "DeviceName";
static const char *kName_OZWNode =                          "OZWNode";
static const char *kName_ZigBeeShortID =                    "ZigbeeShortID";
static const char *kName_ZigBeeEUI64 =                      "ZigbeeEUI64";
static const char *kName_DeviceTechnology =                 "DeviceTechnology";
static const char *kName_AssociationTimestamp =             "AssociationTimeStamp";
static const char *kName_DeviceType =                       "DeviceType";
static const char *kName_DeviceTypeName =                   "DeviceTypeName";
static const char *kName_FriendlyDeviceType =               "FriendlyDeviceType";
static const char *kName_DeviceFunction =                   "DeviceFunction";
static const char *kName_AllowNotification =                "AllowNotification";
static const char *kName_ValueCount =                       "ValueCount";

static const char *kName_DeviceValueListResponse =          "DeviceValueListResponse";
static const char *kName_ValueVariables =                   "ValueVariables";
static const char *kName_LastKnownValue =                   "LastKnownValue";
static const char *kName_MobileCommandResponse =            "MobileCommandResponse";
static const char *kName_MobileInternalIndex =              "MobileInternalIndex";
static const char *kName_DeviceMAC =                        "DeviceMAC";
static const char *kName_DynamicDeviceValueList =           "DynamicDeviceValueList";
static const char *kName_DeviceValueList =                  "DeviceValueList"; //To be removed later - Bug in Cloud

//PY 151013 - Almond List - Name and MAC
static const char *kName_AlmondPlus =                       "Almondplus";
//PY 181013 - Reason Code for Login
static const char *kName_ReasonCode =                       "ReasonCode";

//PY 291013 - Generic Command - Router
static const char *kName_GenericCommandResponse =            "GenericCommandResponse";
static const char *kName_GenericCommandNotification =        "GenericCommandNotification";

static const char *kName_ApplicationID =                    "ApplicationID";
static const char *kName_Data =                             "Data";

//PY 011113 - Reactivation link
static const char *kName_ValidateAccountResponse =          "ValidateAccountResponse";
static const char *kName_ResetPasswordResponse =            "ResetPasswordResponse";

//PY121113 - Location
static const char *kName_Location =                         "Location";
static const char *kName_WifiSSID =                         "WifiSSID";
static const char *kName_WifiPassword =                     "WifiPassword";

//PY221113 - 81 command tag changed
static const char *kName_DynamicDeviceData =                "DynamicDeviceData";

//PY201213 - 83 command
//static const char *kName_DynamicAlmondList =                "DynamicAlmondList";
static const char *kName_DynamicAlmondAdd =                 "DynamicAlmondAdd";
//PY241213 - 84 command
static const char *kName_DynamicAlmondDelete =              "DynamicAlmondDelete";
//static const char *kName_Action =                           "Action";

//PY 200114 - SensorChangeResponse
static const char *kName_SensorChangeResponse =             "SensorChangeResponse";

//PY 250214 - LogoutResponse
static const char *kName_LogoutResponse =                   "LogoutResponse";

//PY 280214 - DynamicAlmondNameChange
static const char *kName_DynamicAlmondNameChange =          "DynamicAlmondNameChange";

//static const char *kName_Index =                            "Index";
//static const char *kName_Name =                             "Name";
//static const char *kName_Type =                             "Type";



static const NSUInteger kLength_MaxTag  =                   35;
//static const NSUInteger kLength_LoginResponse =             14;
//static const NSUInteger kLength_UserID =                    7;
//static const NSUInteger kLength_TempPass =                  9;
//static const NSUInteger kLength_Reason =                    7;
//static const NSUInteger kLength_SanityResponse =            15;
//static const NSUInteger kLength_KeepAlive =                 10;
//static const NSUInteger kLength_AffiliationUserResponse =   24;
//static const NSUInteger kLength_AffiliationCode =           5;
//static const NSUInteger kLength_AffiliationUserComplete =   24;
//static const NSUInteger kLength_AlmondMAC =                 13;
//static const NSUInteger kLength_AlmondName =                14;
//static const NSUInteger kLength_SignupResponse =            15;
//PY 160913 - Add Constants
//static const char *kLength_AlmondPlusMAC =                13;
//static const NSUInteger kLength_AlmondListResponse =        18;
//static const NSUInteger kLength_DeviceDataHashResponse =    22;
//static const NSUInteger kLength_Hash =                       4;
//static const NSUInteger kLength_DeviceDataResponse =        18;
//static const NSUInteger kLength_Device =                    6;
//static const NSUInteger kLength_ID =                        2;
//static const NSUInteger kLength_DeviceName =                10;
//static const NSUInteger kLength_OZWNode =                   7;
//static const NSUInteger kLength_ZigBeeShortID =             13;
//static const NSUInteger kLength_ZigBeeEUI64 =               11;
//static const NSUInteger kLength_DeviceTechnology =          16;
//static const NSUInteger kLength_AssociationTimestamp =      20;
//static const NSUInteger kLength_DeviceType =                10;
//static const NSUInteger kLength_DeviceTypeName =            14;
//static const NSUInteger kLength_FriendlyDeviceType =        18;
//static const NSUInteger kLength_DeviceFunction =            14;
//static const NSUInteger kLength_AllowNotification =         17;
//static const NSUInteger kLength_ValueCount =                10;


#pragma mark - Functions

// Function prototypes for SAX callbacks. This sample implements a minimal subset of SAX callbacks.
// Depending on your application's needs, you might want to implement more callbacks.
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int __unused nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

// Forward reference. The structure is defined in full at the end of the file.
static xmlSAXHandler simpleSAXHandlerStruct;

@interface CommandParser ()
@property(nonatomic, readonly) xmlParserCtxtPtr context;
@property(nonatomic) NSMutableArray *tmpAlmondList;
@property(nonatomic) NSMutableArray *tmpDeviceList;
@property(nonatomic) SFIDevice *tmpDevice;
@property(nonatomic) SFIDeviceValue *tmpDeviceValue;
@property(nonatomic) NSMutableArray *deviceValues;
@property(nonatomic) NSMutableArray *knownDeviceValues;
@property(nonatomic) SFIDeviceKnownValues *tmpDeviceKnownValue;
@property(nonatomic) NSString *currentTmpMACValue;
@property(nonatomic) SFIAlmondPlus *tmpAlmond;
@property(nonatomic) BOOL storingCharacters;
@property(nonatomic) NSMutableData *characterBuffer;
@property(nonatomic) BOOL parsingCommand;
@property(nonatomic) CommandType commandType;
@property(nonatomic) CommandType storingCommandType;
@property(nonatomic) id command;
@end

@implementation CommandParser

- (id) parseXML:(NSData *)xmlData
{
    @try{
        self.characterBuffer = [[NSMutableData alloc] init];
        _context = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, (__bridge void *)(self), NULL, 0, NULL);

        NSUInteger length = [xmlData length];
        xmlParseChunk(self.context, (const char *)[xmlData bytes], (int) length, 0);
        xmlParseChunk(self.context, NULL, 0, 1);// 1 to end parsing

        self.characterBuffer = nil;
    }
    @catch (NSException *e)
    {
        // [SNLog Log:@"Method Name: %s Error: %@", __PRETTY_FUNCTION__, e.reason];
    }
    //// NSLog(@"Returning LoginResponse object ");
    //// NSLog(@"object data \n UserID: %@  tempPass: %@ ",[self.command userID], [self.command tempPass]);
    self.characterBuffer=nil;
    xmlFreeParserCtxt(self.context);
    
    GenericCommand *obj = [[GenericCommand alloc] init];
    switch (self.commandType) {
        case CommandType_LOGIN_RESPONSE:
        case CommandType_CLOUD_SANITY_RESPONSE:
        case CommandType_KEEP_ALIVE:
        case CommandType_AFFILIATION_USER_COMPLETE:
        case CommandType_SIGNUP_RESPONSE:
        case CommandType_ALMOND_LIST_RESPONSE:
        case CommandType_DEVICE_DATA_HASH_RESPONSE:
        case CommandType_DEVICE_DATA_RESPONSE:
        case CommandType_DEVICE_VALUE_LIST_RESPONSE:
        case CommandType_DYNAMIC_DEVICE_VALUE_LIST:
        case CommandType_LOGOUT_ALL_RESPONSE:
        case CommandType_LOGOUT_RESPONSE:
        case CommandType_RESET_PASSWORD_RESPONSE:
        case CommandType_MOBILE_COMMAND_RESPONSE:
        case CommandType_VALIDATE_RESPONSE:
        case CommandType_GENERIC_COMMAND_RESPONSE:
        case CommandType_SENSOR_CHANGE_RESPONSE:
        case CommandType_GENERIC_COMMAND_NOTIFICATION:
        case CommandType_DYNAMIC_DEVICE_DATA:
        case CommandType_DYNAMIC_ALMOND_ADD:
        case CommandType_DYNAMIC_ALMOND_DELETE:
        case CommandType_DYNAMIC_ALMOND_NAME_CHANGE:
            obj.command = self.command;
            obj.commandType = self.commandType;
            break;

        default: {
            // do nothing
            break;
        }
    }

    return obj;
}

- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length {
    //// NSLog(@"Buffer : %@",[characterBuffer bytes]);
    [self.characterBuffer appendBytes:charactersFound length:(NSUInteger) length];
}

- (NSString *)currentString {
    // Create a string with the character data using UTF-8 encoding. UTF-8 is the default XML data encoding.
    NSString *currentString = [[NSString alloc] initWithData:self.characterBuffer encoding:NSUTF8StringEncoding];
    [self.characterBuffer setLength:0];
    return currentString;
}

#pragma mark SAX Parsing Callbacks



/*
 static const char *kName_Category = "";
 static const NSUInteger kLength_Category = 9;
 static const char *kName_Itms = "itms";
 static const NSUInteger kLength_Itms = 5;
 static const char *kName_Artist = "artist";
 static const NSUInteger kLength_Artist = 7;
 static const char *kName_Album = "album";
 static const NSUInteger kLength_Album = 6;
 static const char *kName_ReleaseDate = "releasedate";
 static const NSUInteger kLength_ReleaseDate = 12;
 */

/*
 This callback is invoked when the parser finds the beginning of a node in the XML. For this application,
 out parsing needs are relatively modest - we need only match the node name. An "item" node is a record of
 data about a song. In that case we create a new Song object. The other nodes of interest are several of the
 child nodes of the Song currently being parsed. For those nodes we want to accumulate the character data
 in a buffer. Some of the child nodes use a namespace prefix.
 */
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar __unused *URI,
        int __unused nb_namespaces, const xmlChar __unused **namespaces, int nb_attributes, int __unused nb_defaulted, const xmlChar **attributes) {

    CommandParser *parser = (__bridge CommandParser *)ctx;
    // The second parameter to strncmp is the name of the element, which we known from the XML schema of the feed.
    // The third parameter to strncmp is the number of characters in the element name, plus 1 for the null terminator.
    //// NSLog(@"localName: %s current string: %@ size: %lu", localname ,[parser currentString] ,(unsigned long)[[parser currentString] length]);
    if (prefix == NULL && !strncmp((const char *)localname, kName_LoginResponse, kLength_MaxTag)) {
        LoginResponse *loginResponse = [[LoginResponse alloc]init];
        parser.command = loginResponse;
        parser.storingCommandType= CommandType_LOGIN_RESPONSE;

        //// NSLog(@"localName: %s", localname);
        //// NSLog(@"Attribute Count : %d",nb_attributes);
        //// NSLog(@"LoginResponse Attribute : %s",attributes[0]);

        //Parse attribute value
        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';
        //// NSLog(@"Value %s",val);

        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }
        parser.parsingCommand = YES;
    } else if (prefix == NULL && !strncmp((const char *)localname, kName_SanityResponse, kLength_MaxTag))
    {
        SanityResponse *sanityResponse = [[SanityResponse alloc]init];
        parser.command = sanityResponse;
        //// NSLog(@"localName: %s", localname);
        parser.parsingCommand = YES;
        parser.storingCommandType=CommandType_CLOUD_SANITY_RESPONSE;

    } else if (prefix == NULL && !strncmp((const char *)localname, kName_KeepAlive, kLength_MaxTag))
    {
        parser.command = nil;
        //// NSLog(@"localName: %s", localname);
        parser.parsingCommand = YES;
        parser.storingCharacters = YES;
        parser.storingCommandType=CommandType_KEEP_ALIVE;
    }
    else if (prefix == NULL && !strncmp((const char *)localname, kName_AffiliationUserComplete, kLength_MaxTag))
    {
        //PY 301013 - Revised Affiliation Process
        AffiliationUserComplete *affUserResponse= [[AffiliationUserComplete alloc]init];
        parser.command = affUserResponse;

        // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];

        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';

        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }

        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_AFFILIATION_USER_COMPLETE;
    }
        //    else if (prefix == NULL && !strncmp((const char *)localname, kName_AffiliationUserResponse, kLength_MaxTag))
        //    {
        //        AffiliationUserRequest *affUserResponse= [[AffiliationUserRequest alloc]init];
        //        parser.command = (AffiliationUserRequest *)affUserResponse;
        //
        //       // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];
        //        parser.parsingCommand = YES;
        //        parser.storingCommandType = AFFILIATION_CODE_RESPONSE;
        //    }
        //    else if (prefix == NULL && !strncmp((const char *)localname, kName_AffiliationUserResponse, kLength_MaxTag))
        //    {
        //        AffiliationUserRequest *affUserResponse= [[AffiliationUserRequest alloc]init];
        //        parser.command = (AffiliationUserRequest *)affUserResponse;
        //
        //        // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];
        //        parser.parsingCommand = YES;
        //        parser.storingCommandType = AFFILIATION_CODE_RESPONSE;
        //    }
    else if (prefix == NULL && !strncmp((const char *)localname, kName_SignupResponse, kLength_MaxTag))
    {
        SignupResponse *signupRes= [[SignupResponse alloc]init];
        parser.command = signupRes;
        // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];

        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';
        //// NSLog(@"Value %s",val);

        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }

        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_SIGNUP_RESPONSE;
    }
        //PY 250214 - Logout Response
    else if (prefix == NULL && !strncmp((const char *)localname, kName_LogoutResponse, kLength_MaxTag))
    {
        LogoutResponse *logoutResponse= [[LogoutResponse alloc]init];
        parser.command = logoutResponse;

        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';

        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }

        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_LOGOUT_RESPONSE;
    }
        //PY 250214 - Logout All Response
    else if (prefix == NULL && !strncmp((const char *)localname, kName_LogoutAllResponse, kLength_MaxTag))
    {
        LogoutAllResponse *logoutResponse= [[LogoutAllResponse alloc]init];
        parser.command = logoutResponse;

        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';

        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }

        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_LOGOUT_ALL_RESPONSE;
    }
        //PY160913 - Almond List Response
    else if(prefix == NULL && !strncmp((const char *)localname, kName_AlmondListResponse, kLength_MaxTag)){
        AlmondListResponse *almondListResponse = [[AlmondListResponse alloc]init];
        parser.command = almondListResponse;
        // [SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];

        //To get Success attribute
        NSString *successKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* successVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,successKey,successVal ];


        //To get Count attribute
        attributes += 5;

//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];

        if([successKey isEqualToString:@"success"] && [successVal isEqualToString:@"true"]){
            [parser.command setIsSuccessful:1];
            [parser.command setDeviceCount:(unsigned int) [countVal intValue]];
            parser.tmpAlmondList = [[NSMutableArray alloc]init]; //Create AlmondPlusMAC List
        }else{
            [parser.command setIsSuccessful:0];
            [parser.command setDeviceCount:0];
        }

        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_ALMOND_LIST_RESPONSE;
    }
        //PY170913 - Device Hash Response
    else if(prefix == NULL && !strncmp((const char *)localname, kName_DeviceDataHashResponse, kLength_MaxTag)){
        DeviceDataHashResponse *deviceDataHashResponse = [[DeviceDataHashResponse alloc]init];
        parser.command = deviceDataHashResponse;
        // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];

        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';


        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:YES];
        }else{
            [parser.command setIsSuccessful:NO];
        }

        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_DEVICE_DATA_HASH_RESPONSE;
    }
        //PY170913 - Device Data Response
    else if(prefix == NULL && !strncmp((const char *)localname, kName_DeviceDataResponse, kLength_MaxTag)){
        DeviceListResponse *deviceDataResponse = [[DeviceListResponse alloc]init];
        parser.command = deviceDataResponse;
        // [SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];

        //To get Success attribute
        NSString *successKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* successVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,successKey,successVal];


        //To get Count attribute
        attributes += 5;

//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];
        
        if([successKey isEqualToString:@"success"] && [successVal isEqualToString:@"true"]){
            [parser.command setIsSuccessful:1];
            //Set count
            [parser.command setDeviceCount:(unsigned int) [countVal intValue]];
            parser.tmpDeviceList = [[NSMutableArray alloc]init]; //Create Device List
        }else{
            [parser.command setIsSuccessful:0];
            [parser.command setDeviceCount:0];
        }
        
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_DEVICE_DATA_RESPONSE;
    }else if (!strncmp((const char *)localname, kName_Device, kLength_MaxTag)
              && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
    {
        //Get ID from attribute
        NSString *deviceIDKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* deviceIDVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,deviceIDKey,deviceIDVal];
        
        parser.tmpDevice = [[SFIDevice alloc]init];
        if([deviceIDKey isEqualToString:@"ID"]){
            [parser.tmpDevice setDeviceID:(unsigned int) [deviceIDVal intValue]];
        }else{
            //Not possible: (no device id comes from cloud)
            [parser.tmpDevice setDeviceID:0];
        }
        
    }
    //PY190913 - Device Value Response
    else if(prefix == NULL && !strncmp((const char *)localname, kName_DeviceValueListResponse, kLength_MaxTag)){
        DeviceValueResponse *deviceValueResponse = [[DeviceValueResponse alloc]init];
        parser.command = deviceValueResponse;
        // [SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];
        
        
        //To get Count attribute
//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];
        //Set count
        [parser.command setDeviceCount:(unsigned int) [countVal intValue]];
        parser.deviceValues = [[NSMutableArray alloc]init]; //Create Device Value List
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_DEVICE_VALUE_LIST_RESPONSE;
    }else if (!strncmp((const char *)localname, kName_Device, kLength_MaxTag)
              && (parser.storingCommandType == CommandType_DEVICE_VALUE_LIST_RESPONSE))
    {
        //Get ID from attribute
        NSString *deviceIDKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* deviceIDVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,deviceIDKey,deviceIDVal];
        
        parser.tmpDeviceValue = [[SFIDeviceValue alloc]init];
        if([deviceIDKey isEqualToString:@"ID"]){
            [parser.tmpDeviceValue setDeviceID:(unsigned int) [deviceIDVal intValue]];
        }else{
            //Not possible: (no device id comes from cloud)
            [parser.tmpDeviceValue setDeviceID:0];
        }
        
    }else if (!strncmp((const char *)localname, kName_ValueVariables, kLength_MaxTag)
              && (parser.storingCommandType == CommandType_DEVICE_VALUE_LIST_RESPONSE))
    {
        //Get Value Variable Count
//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];

        [parser.tmpDeviceValue setValueCount:(unsigned int) [countVal intValue]];
        //Create Device Known Value List
        parser.knownDeviceValues = [[NSMutableArray alloc]init];
        
    }else if(!strncmp((const char *)localname, kName_LastKnownValue, kLength_MaxTag)
             && (parser.storingCommandType == CommandType_DEVICE_VALUE_LIST_RESPONSE)){
        //Get Attributes -Index,  Name,  Type
        // NSLog(@"localName: %s No of Attributes: %d", localname, nb_attributes);
        
        //To get Index attribute
        NSString *indexKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* indexVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,indexKey,indexVal];
        
        
        //To get Name attribute
        attributes += 5;
        
        NSString *nameKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* nameVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,nameKey,nameVal];
        
        NSString *typeKey = nil;
        NSString* typeVal = nil;
        if(nb_attributes == 3){
            //To get Type attribute
            attributes += 5;
            typeKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
            typeVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
            // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,typeKey,typeVal];
        }
        
        // Create a new instance of DeviceKnownValue
        parser.tmpDeviceKnownValue = [[SFIDeviceKnownValues alloc]init];
        //Save Index
        if([indexKey isEqualToString:@"Index"]){
            [parser.tmpDeviceKnownValue setIndex:(unsigned int) [indexVal intValue]];
        }
        //Save Name
        if([nameKey isEqualToString:@"Name"]){
            SFIDevicePropertyType propertyType = [SFIDeviceKnownValues nameToPropertyType:nameVal];
            [parser.tmpDeviceKnownValue setValueName:nameVal];
            [parser.tmpDeviceKnownValue setPropertyType:propertyType];
        }
        //Save Type
        if([typeKey isEqualToString:@"Type"]){
            [parser.tmpDeviceKnownValue setValueType:typeVal];
        }
        parser.storingCharacters = YES;
        
    }
    //PY200913 - Mobile Command Response
    else if(prefix == NULL && !strncmp((const char *)localname, kName_MobileCommandResponse, kLength_MaxTag)){
        MobileCommandResponse *mobileCommandResponse = [[MobileCommandResponse alloc]init];
        parser.command = mobileCommandResponse;
        // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];
        
        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';
        
        
        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }
        
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_MOBILE_COMMAND_RESPONSE;
    }
    //PY 230913 - Device Value List Response - 82
    else if(prefix == NULL && !strncmp((const char *)localname, kName_DynamicDeviceValueList, kLength_MaxTag)){
        DeviceValueResponse *deviceValueResponse = [[DeviceValueResponse alloc]init];
        parser.command = deviceValueResponse;
        // [SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];
        
        //To get Count attribute
//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];
        //Set count
        [parser.command setDeviceCount:(unsigned int) [countVal intValue]];
        parser.deviceValues = [[NSMutableArray alloc]init]; //Create Device Value List
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_DYNAMIC_DEVICE_VALUE_LIST;
    }
    //To be removed later
    else if(prefix == NULL && !strncmp((const char *)localname, kName_DeviceValueList, kLength_MaxTag)){
        DeviceValueResponse *deviceValueResponse = [[DeviceValueResponse alloc]init];
        parser.command = deviceValueResponse;
        // [SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];
        
        //To get Count attribute
//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];
        //Set count
        [parser.command setDeviceCount:(unsigned int) [countVal intValue]];
        parser.deviceValues = [[NSMutableArray alloc]init]; //Create Device Value List
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_DYNAMIC_DEVICE_VALUE_LIST;
    }
    else if (!strncmp((const char *)localname, kName_Device, kLength_MaxTag)
              && (parser.storingCommandType == CommandType_DYNAMIC_DEVICE_VALUE_LIST))
    {
        //Get ID from attribute
        NSString *deviceIDKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* deviceIDVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,deviceIDKey,deviceIDVal];
        
        parser.tmpDeviceValue = [[SFIDeviceValue alloc]init];
        if([deviceIDKey isEqualToString:@"ID"]){
            [parser.tmpDeviceValue setDeviceID:(unsigned int) [deviceIDVal intValue]];
        }else{
            //Not possible: (no device id comes from cloud)
            [parser.tmpDeviceValue setDeviceID:0];
        }
        
    }else if (!strncmp((const char *)localname, kName_ValueVariables, kLength_MaxTag)
              && (parser.storingCommandType == CommandType_DYNAMIC_DEVICE_VALUE_LIST))
    {
        //Get Value Variable Count
//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];

        [parser.tmpDeviceValue setValueCount:(unsigned int) [countVal intValue]];
        //Create Device Known Value List
        parser.knownDeviceValues = [[NSMutableArray alloc]init];
        
    }else if(!strncmp((const char *)localname, kName_LastKnownValue, kLength_MaxTag)
             && (parser.storingCommandType == CommandType_DYNAMIC_DEVICE_VALUE_LIST)){
        //Get Attributes -Index,  Name,  Type
        // [SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];
        
        //To get Index attribute
        NSString *indexKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* indexVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,indexKey,indexVal];
        
        
        //To get Name attribute
        attributes += 5;
        
        NSString *nameKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* nameVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,nameKey,nameVal];
        
        NSString *typeKey = nil;
        NSString* typeVal = nil;
        if(nb_attributes == 3){
            //To get Type attribute
            attributes += 5;
            typeKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
            typeVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
            // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,typeKey,typeVal];
        }
        
        // Create a new instance of DeviceKnownValue
        parser.tmpDeviceKnownValue = [[SFIDeviceKnownValues alloc]init];
        //Save Index
        if([indexKey isEqualToString:@"Index"]){
            [parser.tmpDeviceKnownValue setIndex:(unsigned int) [indexVal intValue]];
        }
        //Save Name
        if([nameKey isEqualToString:@"Name"]){
            SFIDevicePropertyType propertyType = [SFIDeviceKnownValues nameToPropertyType:nameVal];
            [parser.tmpDeviceKnownValue setPropertyType:propertyType];
            [parser.tmpDeviceKnownValue setValueName:nameVal];
        }
        //Save Type
        if([typeKey isEqualToString:@"Type"]){
            [parser.tmpDeviceKnownValue setValueType:typeVal];
        }
        parser.storingCharacters = YES;
        
    }
    else if (!strncmp((const char *)localname, kName_DeviceMAC,kLength_MaxTag)){
        //DeviceMAC is outside <DeviceValueList> node
        parser.storingCharacters = YES;
        parser.parsingCommand = YES;
    }
    //PY 151013 - Almond List - Name and MAC
    else if (!strncmp((const char *)localname, kName_AlmondPlus,kLength_MaxTag)  && (parser.storingCommandType == CommandType_ALMOND_LIST_RESPONSE)){
        parser.storingCharacters = YES;
        parser.parsingCommand = YES;
        //Get ID from attribute
        NSString *almondIDKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* almondIDVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,almondIDKey,almondIDVal];
        
        parser.tmpAlmond = [[SFIAlmondPlus alloc]init];
        if([almondIDKey isEqualToString:@"Index"]){
            [parser.tmpAlmond setIndex:[almondIDVal intValue]];
        }else{
            //Not possible: (no device id comes from cloud)
            [parser.tmpAlmond setIndex:0];
        }
    }
    //PY 291013 - Generic Command - Router
    else if (prefix == NULL && !strncmp((const char *)localname, kName_GenericCommandResponse, kLength_MaxTag))
    {
        GenericCommandResponse *genericRes= [[GenericCommandResponse alloc]init];
        parser.command = genericRes;
        // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];
        
        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';
        //// NSLog(@"Value %s",val);
        
        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }
        
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_GENERIC_COMMAND_RESPONSE;
    }
    //PY 301013 - Generic Command Notification - Router
    else if (prefix == NULL && !strncmp((const char *)localname, kName_GenericCommandNotification, kLength_MaxTag))
    {
        GenericCommandResponse *genericRes= [[GenericCommandResponse alloc]init];
        parser.command = genericRes;
        // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];
        
        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';
        //// NSLog(@"Value %s",val);
        
        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }
        
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_GENERIC_COMMAND_NOTIFICATION;
    }
    //PY 011113 - Validate Account Response
    else if (prefix == NULL && !strncmp((const char *)localname, kName_ValidateAccountResponse, kLength_MaxTag))
    {
        ValidateAccountResponse *validateRes= [[ValidateAccountResponse alloc]init];
        parser.command = validateRes;
        // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];
        
        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';
        
        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }
        
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_VALIDATE_RESPONSE;
    }
    //PY 011113 - Reset Password Response
    else if (prefix == NULL && !strncmp((const char *)localname, kName_ResetPasswordResponse, kLength_MaxTag))
    {
        ResetPasswordResponse *resetPwdRes= [[ResetPasswordResponse alloc]init];
        parser.command = resetPwdRes;
        // [SNLog Log:@"Method Name: %s localName: %s",__PRETTY_FUNCTION__, localname];
        
        const char *begin = (const char *)attributes[0 + 3];
        const char *end = (const char *)attributes[0 + 4];
        long vlen = end - begin;
        char val[vlen + 1];
        strncpy(val, begin, vlen);
        val[vlen] = '\0';
        //// NSLog(@"Value %s",val);
        
        if (!strncmp((const char *)attributes[0], k_Success, 8) && !strncmp(val, k_True, 5)){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }
        
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_RESET_PASSWORD_RESPONSE;
    }
    
    //PY 221113 - 81 Command - Tag Changed to DynamicDeviceData from DeviceDataResponse
    else if(prefix == NULL && !strncmp((const char *)localname, kName_DynamicDeviceData, kLength_MaxTag)){
        DeviceListResponse *deviceDataResponse = [[DeviceListResponse alloc]init];
        parser.command = deviceDataResponse;
        // [SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];
        
        //To get Success attribute
        NSString *successKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* successVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,successKey,successVal];
        
        
        //To get Count attribute
        attributes += 5;
        
//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];
        
        if([successKey isEqualToString:@"success"] && [successVal isEqualToString:@"true"]){
            [parser.command setIsSuccessful:1];
            //Set count
            [parser.command setDeviceCount:(unsigned int) [countVal intValue]];
            parser.tmpDeviceList = [[NSMutableArray alloc]init]; //Create Device List
        }else{
            [parser.command setIsSuccessful:0];
            [parser.command setDeviceCount:0];
        }
        
        parser.parsingCommand = YES;
        //Set is as DeviceDataResponse so that the structure can be repeated.
        //Again set it to Dynamic Device Data when end tag is encountered
        parser.storingCommandType = CommandType_DEVICE_DATA_RESPONSE;
    }
    //PY 201213 - Almond List ADD - 83
    else if(prefix == NULL && !strncmp((const char *)localname, kName_DynamicAlmondAdd, kLength_MaxTag)){
        AlmondListResponse *almondListResponse = [[AlmondListResponse alloc]init];
        parser.command = almondListResponse;
        // [SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];
        
        //To get Success attribute
        NSString *successKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* successVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,successKey,successVal];
        
        
        //To get Count attribute
        attributes += 5;
        
//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];
        
//        NSString *actionKey;
//        NSString *actionVal = nil;
//        //To get Action attribute
//         if(nb_attributes == 3){
//             attributes += 5;
//             actionKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
//             actionVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
//             // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,actionKey,actionVal];
//         }
        
        if([successKey isEqualToString:@"success"] && [successVal isEqualToString:@"true"]){
            [parser.command setIsSuccessful:1];
            //Set count
            [parser.command setDeviceCount:(unsigned int) [countVal intValue]];
//            [parser.command setAction:actionVal];
            parser.tmpAlmondList = [[NSMutableArray alloc]init]; //Create AlmondPlusMAC List
        }else{
            [parser.command setIsSuccessful:0];
            [parser.command setDeviceCount:0];
//             [parser.command setAction:nil];
        }
        
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_DYNAMIC_ALMOND_ADD;
    }
    //PY - Almond List ADD - 83 - Name and MAC
    else if (!strncmp((const char *)localname, kName_AlmondPlus,kLength_MaxTag)  && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_ADD)){
        parser.storingCharacters = YES;
        parser.parsingCommand = YES;
        //Get ID from attribute
        NSString *almondIDKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* almondIDVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,almondIDKey,almondIDVal];
        
        parser.tmpAlmond = [[SFIAlmondPlus alloc]init];
        if([almondIDKey isEqualToString:@"Index"]){
            [parser.tmpAlmond setIndex:[almondIDVal intValue]];
        }else{
            //Not possible: (no device id comes from cloud)
            [parser.tmpAlmond setIndex:0];
        }
    }
    //PY 241213 - Almond List DELETE - 84
    else if(prefix == NULL && !strncmp((const char *)localname, kName_DynamicAlmondDelete, kLength_MaxTag)){
        AlmondListResponse *almondListResponse = [[AlmondListResponse alloc]init];
        parser.command = almondListResponse;
        // [SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];
        
        //To get Success attribute
        NSString *successKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* successVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,successKey,successVal];
        
        
        //To get Count attribute
        attributes += 5;
        
//        NSString *countKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* countVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,countKey,countVal];
        
        if([successKey isEqualToString:@"success"] && [successVal isEqualToString:@"true"]){
            [parser.command setIsSuccessful:1];
            //Set count
            [parser.command setDeviceCount:(unsigned int) [countVal intValue]];
            parser.tmpAlmondList = [[NSMutableArray alloc]init]; //Create AlmondPlusMAC List
        }else{
            [parser.command setIsSuccessful:0];
            [parser.command setDeviceCount:0];
        }
        
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_DYNAMIC_ALMOND_DELETE;
    }
    //PY - Almond List  DELETE - 84 - Name and MAC
    else if (!strncmp((const char *)localname, kName_AlmondPlus,kLength_MaxTag)  && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_DELETE)){
        parser.storingCharacters = YES;
        parser.parsingCommand = YES;
        //Get ID from attribute
        NSString *almondIDKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* almondIDVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        // [SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,almondIDKey,almondIDVal];
        
        parser.tmpAlmond = [[SFIAlmondPlus alloc]init];
        if([almondIDKey isEqualToString:@"Index"]){
            [parser.tmpAlmond setIndex:[almondIDVal intValue]];
        }else{
            //Not possible: (no device id comes from cloud)
            [parser.tmpAlmond setIndex:0];
        }
    }
    //PY 200114 - Sensor Change Response
    else if(prefix == NULL && !strncmp((const char *)localname, kName_SensorChangeResponse, kLength_MaxTag)){
        SensorChangeResponse *sensorChangeResponse = [[SensorChangeResponse alloc]init];
        parser.command = sensorChangeResponse;
        //[SNLog Log:@"Method Name: %s localName: %s No of Attributes: %d",__PRETTY_FUNCTION__, localname, nb_attributes];
        
        //To get Success attribute
        NSString *successKey = [NSString stringWithCString:(const char*)attributes[0] encoding:NSUTF8StringEncoding];
        NSString* successVal = [[NSString alloc] initWithBytes:(const void*)attributes[3] length:(attributes[4] - attributes[3]) encoding:NSUTF8StringEncoding];
        //[SNLog Log:@"Method Name: %s Attributes %@ Value %@",__PRETTY_FUNCTION__,successKey,successVal];
        
        
        if([successKey isEqualToString:@"success"] && [successVal isEqualToString:@"true"]){
            [parser.command setIsSuccessful:1];
        }else{
            [parser.command setIsSuccessful:0];
        }
        
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_SENSOR_CHANGE_RESPONSE;
    }
    //PY 2080214 - Dynamic Name Change Response
    else if(prefix == NULL && !strncmp((const char *)localname, kName_DynamicAlmondNameChange, kLength_MaxTag)){
        DynamicAlmondNameChangeResponse *almondNameChangeResponse = [[DynamicAlmondNameChangeResponse alloc]init];
        parser.command = almondNameChangeResponse;
        parser.parsingCommand = YES;
        parser.storingCommandType = CommandType_DYNAMIC_ALMOND_NAME_CHANGE;
    }
    else if (parser.parsingCommand && (prefix == NULL && (
                                                          (!strncmp((const char *)localname, kName_LoginResponse, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_UserID, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_TempPass, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_AffiliationCode, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_AlmondMAC, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_AlmondName, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_Hash, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_DeviceName, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_OZWNode, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_ZigBeeShortID, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_ZigBeeEUI64, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_DeviceTechnology, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_AssociationTimestamp, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_DeviceType, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_DeviceTypeName, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_FriendlyDeviceType, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_DeviceFunction, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_AllowNotification, kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_ValueCount,kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_MobileInternalIndex,kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_ReasonCode,kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_ApplicationID,kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_Data,kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_Location,kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_WifiPassword,kLength_MaxTag))
                                                          || (!strncmp((const char *)localname, kName_WifiSSID,kLength_MaxTag))
                                                          )  ))
    {
        //// NSLog(@"Storing Character for : %s",localname);
        parser.storingCharacters = YES;
    }else{
        // [SNLog Log:@"Method Name: %s NOT Storing Character for %s",__PRETTY_FUNCTION__, localname];
    }
}

/*
 This callback is invoked when the parse reaches the end of a node. At that point we finish processing that node,
 if it is of interest to us. For "item" nodes, that means we have completed parsing a Song object. We pass the song
 to a method in the superclass which will eventually deliver it to the delegate. For the other nodes we
 care about, this means we have all the character data. The next step is to create an NSString using the buffer
 contents and store that with the current Song object.
 */
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar __unused *URI) {
    CommandParser *parser = (__bridge CommandParser *)ctx;
    if (parser.parsingCommand == NO) return;
    //// NSLog(@"Prefix in endElementSAX : %s",prefix);
    //// NSLog(@"LocalName in endElementSAX : %s",localname);
    if (prefix == NULL) {
        
        //        if (!strncmp((const char *)localname, kName_UserID, kLength_MaxTag)
        //            && (parser.storingCommandType == CommandType_AFFILIATION_CODE_RESPONSE))
        //        {
        //            [parser.command setUserID:[parser currentString]];
        //            // [SNLog Log:@"Method Name: %s AFF response Object Data  UserID: %@", __PRETTY_FUNCTION__,[parser.command UserID]];
        //        }
        //        else if (!strncmp((const char *)localname, kName_AffiliationCode, kLength_MaxTag)
        //                 && (parser.storingCommandType == CommandType_AFFILIATION_CODE_RESPONSE))
        //        {
        //            [parser.command setCode:[parser currentString]];
        //            // [SNLog Log:@"Method Name: %s AFF response Object Data  Code: %@", __PRETTY_FUNCTION__,[parser.command Code]];
        //        }
        //        else if (!strncmp((const char *)localname, kName_AffiliationUserResponse, kLength_MaxTag) && (parser.storingCommandType == CommandType_AFFILIATION_CODE_RESPONSE)) {
        //            // [SNLog Log:@"Method Name: %s Affiliation command parsing done", __PRETTY_FUNCTION__];
        //            parser.commandType = AFFILIATION_CODE_RESPONSE;
        //            parser.parsingCommand = NO;
        //        }
        //else
        if (!strncmp((const char *)localname, kName_AlmondMAC, kLength_MaxTag)
            && (parser.storingCommandType == CommandType_AFFILIATION_USER_COMPLETE))
        {
    
            [parser.command setAlmondplusMAC:[parser currentString]];
            // [SNLog Log:@"Method Name: %s AFF response Object Data  Almond MAC: %@", __PRETTY_FUNCTION__,[parser.command almondplusMAC]];
        }
        else if (!strncmp((const char *)localname, kName_AlmondName, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_AFFILIATION_USER_COMPLETE))
        {
            [parser.command setAlmondplusName:[parser currentString]];
            // [SNLog Log:@"Method Name: %s AFF response Object Data  Name: %@", __PRETTY_FUNCTION__,[parser.command almondplusName]];
        }
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_AFFILIATION_USER_COMPLETE))
        {
            [parser.command setReason:[parser currentString]];
        }
        //PY200114
        else if (!strncmp((const char *)localname, kName_ReasonCode, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_AFFILIATION_USER_COMPLETE))
        {
            [parser.command setReasonCode:[[parser currentString] intValue]];
        }
        //PY121113
        else if (!strncmp((const char *)localname, kName_WifiSSID, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_AFFILIATION_USER_COMPLETE))
        {
            [parser.command setWifiSSID:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_WifiPassword, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_AFFILIATION_USER_COMPLETE))
        {
            [parser.command setWifiPassword:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_AffiliationUserComplete, kLength_MaxTag) && (parser.storingCommandType == CommandType_AFFILIATION_USER_COMPLETE)) {
            // [SNLog Log:@"Method Name: %s Affiliation command parsing done", __PRETTY_FUNCTION__];
            parser.commandType = CommandType_AFFILIATION_USER_COMPLETE;
            parser.parsingCommand = NO;
        }
        else if (!strncmp((const char *)localname, kName_UserID, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_LOGIN_RESPONSE)) {
            //// NSLog(@"UserID : %@",[parser currentString]);
            [parser.command setUserID:[parser currentString]];
            // [SNLog Log:@"Method Name: %s Object Data  UserID: %@", __PRETTY_FUNCTION__,[parser.command userID]];
        }
        else if (!strncmp((const char *)localname, kName_TempPass, kLength_MaxTag) && (parser.storingCommandType == CommandType_LOGIN_RESPONSE)) {
            //// NSLog(@"TempPass : %@",[parser currentString]);
            [parser.command setTempPass:[parser currentString]];
            // [SNLog Log:@"Method Name: %s TempPass Data  TempPass: %@", __PRETTY_FUNCTION__,[parser.command tempPass]];
        }
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_LOGIN_RESPONSE))
        {
            [parser.command setReason:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_ReasonCode, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_LOGIN_RESPONSE))
        {
            [parser.command setReasonCode:[[parser currentString] intValue]];
        }
        else if (!strncmp((const char *)localname, kName_LoginResponse, kLength_MaxTag)) {
            //[parser finishedCurrentSong];
            // [SNLog Log:@"Method Name: %s Command Parsing done", __PRETTY_FUNCTION__];
            parser.commandType = CommandType_LOGIN_RESPONSE;
            //[parser.command setReason:@"Success"];
            parser.parsingCommand = NO;
        }
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_CLOUD_SANITY_RESPONSE))
        {
            parser.commandType = CommandType_CLOUD_SANITY_RESPONSE;
            [parser.command setReason:[parser currentString]];
            parser.parsingCommand = NO;
        }
        else if (!strncmp((const char *)localname, kName_KeepAlive, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_KEEP_ALIVE))
        {
            parser.commandType = CommandType_KEEP_ALIVE;
            parser.parsingCommand = NO;
        }
        //SINGUP_RESPONSE PARSING
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag) && (parser.storingCommandType == CommandType_SIGNUP_RESPONSE)) {
            [parser.command setReason:[parser currentString]];
        }
        //PY 181013 - Signup Reason Code
        else if (!strncmp((const char *)localname, kName_ReasonCode, kLength_MaxTag) && (parser.storingCommandType == CommandType_SIGNUP_RESPONSE)) {
            [parser.command setReasonCode:[[parser currentString] intValue]];
        }
        else if (!strncmp((const char *)localname, kName_SignupResponse, kLength_MaxTag)) {
            // [SNLog Log:@"Method Name: %s Signup Command Parsing done", __PRETTY_FUNCTION__];
            parser.commandType = CommandType_SIGNUP_RESPONSE;
            parser.parsingCommand = NO;
        }
        //Device Data Hash Response
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DEVICE_DATA_HASH_RESPONSE))
        {
            [parser.command setReason:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_Hash, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_HASH_RESPONSE))
        {
            [parser.command setAlmondHash:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_DeviceDataHashResponse, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_HASH_RESPONSE))
        {
            // [SNLog Log:@"Method Name: %s Device Hash Command Parsing done", __PRETTY_FUNCTION__];
            parser.commandType = CommandType_DEVICE_DATA_HASH_RESPONSE;
            parser.parsingCommand = NO;
            
        }
        //Device Data Response - START
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.command setReason:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_Device, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDeviceList addObject:parser.tmpDevice];
            
        }else if (!strncmp((const char *)localname, kName_DeviceName, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setDeviceName:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_OZWNode, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setOZWNode:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_ZigBeeShortID, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setZigBeeShortID:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_ZigBeeEUI64, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setZigBeeEUI64:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_DeviceTechnology, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setDeviceTechnology:(unsigned int) [[parser currentString] intValue]];
            
        }else if (!strncmp((const char *)localname, kName_AssociationTimestamp, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setAssociationTimestamp:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_DeviceType, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setDeviceType:(SFIDeviceType) [[parser currentString] intValue]];
            
        }else if (!strncmp((const char *)localname, kName_DeviceTypeName, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setDeviceTypeName:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_FriendlyDeviceType, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setFriendlyDeviceType:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_DeviceFunction, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setDeviceFunction:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_AllowNotification, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setAllowNotification:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_ValueCount, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setValueCount:(unsigned int) [[parser currentString] intValue]];
        }
        //PY 121113
        else if (!strncmp((const char *)localname, kName_Location, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.tmpDevice setLocation:[parser currentString]];
            
        }
        else if (!strncmp((const char *)localname, kName_DeviceDataResponse, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.command setDeviceList:parser.tmpDeviceList];
            // [SNLog Log:@"Method Name: %s Device Data Command Parsing done Size: %d ", __PRETTY_FUNCTION__ , [parser.tmpDeviceList count]];
            //PY 230913
            if(parser.currentTmpMACValue!=nil){
                 [parser.command setAlmondMAC:parser.currentTmpMACValue];
                //parser.commandType = DEVICEDATA_CLOUD_RESPONSE;
                parser.currentTmpMACValue = nil;
            }
            
            parser.commandType = CommandType_DEVICE_DATA_RESPONSE;
            parser.parsingCommand = NO;
            
        }
        //Device Data Response - END
        //PY 221113 - Command 81
        else if (!strncmp((const char *)localname, kName_DynamicDeviceData, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DEVICE_DATA_RESPONSE))
        {
            [parser.command setDeviceList:parser.tmpDeviceList];
            // [SNLog Log:@"Method Name: %s Device Data Command Parsing done Size: %d ", __PRETTY_FUNCTION__ , [parser.tmpDeviceList count]];
            //PY 230913 - Device Data Command 81
            if(parser.currentTmpMACValue!=nil){
                // [SNLog Log:@"Method Name: %s Cloud Initiated", __PRETTY_FUNCTION__];
                [parser.command setAlmondMAC:parser.currentTmpMACValue];
                parser.currentTmpMACValue = nil;
            }
            parser.parsingCommand = NO;
            parser.commandType = CommandType_DYNAMIC_DEVICE_DATA;
        }
        
        //Device Value Response - START
        //PY 190913 - Device Value List
        else if (!strncmp((const char *)localname, kName_LastKnownValue, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DEVICE_VALUE_LIST_RESPONSE))
        {
            // // NSLog(@"Last known value: %@ " , [parser currentString]);
            NSString *currentValue = [parser currentString];
            
            // [SNLog Log:@"Method Name: %s Last known value: %@ " , __PRETTY_FUNCTION__, currentValue];
            [parser.tmpDeviceKnownValue setValue:currentValue];
            [parser.knownDeviceValues addObject:parser.tmpDeviceKnownValue];
            
        }else if (!strncmp((const char *)localname, kName_ValueVariables, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_VALUE_LIST_RESPONSE))
        {
            [parser.tmpDeviceValue setKnownValues:parser.knownDeviceValues];
            
        }
        else if (!strncmp((const char *)localname, kName_Device, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DEVICE_VALUE_LIST_RESPONSE))
        {
            [parser.deviceValues addObject:parser.tmpDeviceValue];
            
        }
        else if (!strncmp((const char *)localname, kName_DeviceValueListResponse, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DEVICE_VALUE_LIST_RESPONSE))
        {
            [parser.command setDeviceValueList:parser.deviceValues];
            parser.commandType = CommandType_DEVICE_VALUE_LIST_RESPONSE;
            parser.parsingCommand = NO;

            if (parser.currentTmpMACValue != nil) {
                [parser.command setAlmondMAC:parser.currentTmpMACValue];
                parser.currentTmpMACValue = nil;
            }
        }
        
        //Device Value Response - END
        //Mobile Command Response - START
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_MOBILE_COMMAND_RESPONSE))
        {
            [parser.command setReason:[parser currentString]];
            
        }else if (!strncmp((const char *)localname, kName_MobileInternalIndex, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_MOBILE_COMMAND_RESPONSE))
        {
            [parser.command setMobileInternalIndex:(unsigned int) [[parser currentString] intValue]];
            
        }else if (!strncmp((const char *)localname, kName_MobileCommandResponse, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_MOBILE_COMMAND_RESPONSE))
        {
            //[parser.command setDeviceValueList:parser.deviceValues];
            //// NSLog(@"Device Value Command Parsing done Size: %d " , [parser.deviceValues count]);
            parser.commandType = CommandType_MOBILE_COMMAND_RESPONSE;
            parser.parsingCommand = NO;
            
        }
        
        //Mobile Command Response - END
        
        //PY 230913
        //CLOUD Initiated Commands - 81 and 82
        else if (!strncmp((const char *)localname, kName_DeviceMAC, kLength_MaxTag))
        {
            parser.currentTmpMACValue = [parser currentString];
            // [SNLog Log:@"Method Name: %s Device Data - 81 or 82 - MAC Value: %@", __PRETTY_FUNCTION__, parser.currentTmpMACValue];
            
        }
        //Device Value Response Command 82 - START
        //PY 190913 - Device Value List
        else if (!strncmp((const char *)localname, kName_LastKnownValue, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_DEVICE_VALUE_LIST))
        {
            // // NSLog(@"Last known value: %@ " , [parser currentString]);
            NSString *currentValue = [parser currentString];
            
            // [SNLog Log:@"Method Name: %s Last known value: %@ " , __PRETTY_FUNCTION__, currentValue];
            [parser.tmpDeviceKnownValue setValue:currentValue];
            [parser.knownDeviceValues addObject:parser.tmpDeviceKnownValue];
            
        }else if (!strncmp((const char *)localname, kName_ValueVariables, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DYNAMIC_DEVICE_VALUE_LIST))
        {
            [parser.tmpDeviceValue setKnownValues:parser.knownDeviceValues];
            
        }
        else if (!strncmp((const char *)localname, kName_Device, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_DEVICE_VALUE_LIST))
        {
            [parser.deviceValues addObject:parser.tmpDeviceValue];
            
        }else if (!strncmp((const char *)localname, kName_DynamicDeviceValueList, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_DYNAMIC_DEVICE_VALUE_LIST))
        {
            [parser.command setDeviceValueList:parser.deviceValues];
            // [SNLog Log:@"Method Name: %s Device Value Command Parsing done Size: %d " , __PRETTY_FUNCTION__, [parser.deviceValues count]];
            if(parser.currentTmpMACValue!=nil){
                // [SNLog Log:@"Method Name: %s Cloud Initiated", __PRETTY_FUNCTION__];
                [parser.command setAlmondMAC:parser.currentTmpMACValue];
                parser.currentTmpMACValue = nil;
            }
            parser.commandType = CommandType_DYNAMIC_DEVICE_VALUE_LIST;
            parser.parsingCommand = NO;
            
        }
        //To be removed later
        else if (!strncmp((const char *)localname, kName_DeviceValueList, kLength_MaxTag)
                && (parser.storingCommandType == CommandType_DYNAMIC_DEVICE_VALUE_LIST))
        {
            [parser.command setDeviceValueList:parser.deviceValues];
            // [SNLog Log:@"Method Name: %s Device Value Command Parsing done Size: %d " , __PRETTY_FUNCTION__, [parser.deviceValues count]];
            if(parser.currentTmpMACValue!=nil){
                // [SNLog Log:@"Method Name: %s Cloud Initiated", __PRETTY_FUNCTION__];
                [parser.command setAlmondMAC:parser.currentTmpMACValue];
                parser.currentTmpMACValue = nil;
            }
            parser.commandType = CommandType_DYNAMIC_DEVICE_VALUE_LIST;
            parser.parsingCommand = NO;
            
        }
        //Device Value Response - Command 82 - END
        //PY 151013 - Almond List - Name and MAC
        //Almond List Response
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_ALMOND_LIST_RESPONSE))
        {
            parser.commandType = CommandType_ALMOND_LIST_RESPONSE;
            [parser.command setReason:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_AlmondListResponse, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_ALMOND_LIST_RESPONSE))
        {
            parser.commandType = CommandType_ALMOND_LIST_RESPONSE;
            [parser.command setAlmondPlusMACList:parser.tmpAlmondList];
            parser.parsingCommand = NO;
        }
        
        else if (!strncmp((const char *)localname, kName_AlmondMAC, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_ALMOND_LIST_RESPONSE))
        {
            
            [parser.tmpAlmond setAlmondplusMAC:[parser currentString]];
            
        }
        else if (!strncmp((const char *)localname, kName_AlmondName, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_ALMOND_LIST_RESPONSE))
        {
            [parser.tmpAlmond setAlmondplusName:[parser currentString]];
            
        }
        else if (!strncmp((const char *)localname, kName_AlmondPlus, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_ALMOND_LIST_RESPONSE))
        {
            //Add to array
            [parser.tmpAlmondList addObject:parser.tmpAlmond];
            
        }
        //PY 291013 - Generic Command Response - Router - START
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_GENERIC_COMMAND_RESPONSE))
        {
            parser.commandType = CommandType_GENERIC_COMMAND_RESPONSE;
            [parser.command setReason:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_GenericCommandResponse, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_GENERIC_COMMAND_RESPONSE))
        {
            parser.commandType = CommandType_GENERIC_COMMAND_RESPONSE;
            parser.parsingCommand = NO;
        }else if (!strncmp((const char *)localname, kName_AlmondMAC, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_GENERIC_COMMAND_RESPONSE))
        {
            [parser.command setAlmondMAC:[parser currentString]];
        }else if (!strncmp((const char *)localname, kName_ApplicationID, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_GENERIC_COMMAND_RESPONSE))
        {
            [parser.command setApplicationID:[parser currentString]];
        }else if (!strncmp((const char *)localname, kName_MobileInternalIndex, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_GENERIC_COMMAND_RESPONSE))
        {
            [parser.command setMobileInternalIndex:(unsigned int) [[parser currentString] intValue]];
        }else if (!strncmp((const char *)localname, kName_Data, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_GENERIC_COMMAND_RESPONSE))
        {
            [parser.command setGenericData:[parser currentString]];
        }
        //PY 291013 - Generic Command Response - Router - END
        //PY 301013 - Generic Command Notification - Router - START
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_GENERIC_COMMAND_NOTIFICATION))
        {
            parser.commandType = CommandType_GENERIC_COMMAND_NOTIFICATION;
            [parser.command setReason:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_GenericCommandNotification, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_GENERIC_COMMAND_NOTIFICATION))
        {
            parser.commandType = CommandType_GENERIC_COMMAND_NOTIFICATION;
            parser.parsingCommand = NO;
        }else if (!strncmp((const char *)localname, kName_AlmondMAC, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_GENERIC_COMMAND_NOTIFICATION))
        {
            [parser.command setAlmondMAC:[parser currentString]];
        }else if (!strncmp((const char *)localname, kName_ApplicationID, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_GENERIC_COMMAND_NOTIFICATION))
        {
            [parser.command setApplicationID:[parser currentString]];
        }else if (!strncmp((const char *)localname, kName_MobileInternalIndex, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_GENERIC_COMMAND_NOTIFICATION))
        {
            [parser.command setMobileInternalIndex:(unsigned int) [[parser currentString] intValue]];
        }else if (!strncmp((const char *)localname, kName_Data, kLength_MaxTag)
                  && (parser.storingCommandType == CommandType_GENERIC_COMMAND_NOTIFICATION))
        {
            [parser.command setGenericData:[parser currentString]];
        }
        //PY 301013 - Generic Command Notification - Router - END
        
        //PY 011113 - Validate Account Response
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag) && (parser.storingCommandType == CommandType_VALIDATE_RESPONSE)) {
            [parser.command setReason:[parser currentString]];
        }else if (!strncmp((const char *)localname, kName_ReasonCode, kLength_MaxTag) && (parser.storingCommandType == CommandType_VALIDATE_RESPONSE)) {
            [parser.command setReasonCode:[[parser currentString] intValue]];
        }else if (!strncmp((const char *)localname, kName_ValidateAccountResponse, kLength_MaxTag)) {
            // [SNLog Log:@"Method Name: %s Validate Account Command Parsing done", __PRETTY_FUNCTION__];
            parser.commandType = CommandType_VALIDATE_RESPONSE;
            parser.parsingCommand = NO;
        }
        
        //PY 011113 - Reset Password Response
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag) && (parser.storingCommandType == CommandType_RESET_PASSWORD_RESPONSE)) {
            [parser.command setReason:[parser currentString]];
        }else if (!strncmp((const char *)localname, kName_ReasonCode, kLength_MaxTag) && (parser.storingCommandType == CommandType_RESET_PASSWORD_RESPONSE)) {
            [parser.command setReasonCode:[[parser currentString] intValue]];
        }else if (!strncmp((const char *)localname, kName_ResetPasswordResponse, kLength_MaxTag)) {
            // [SNLog Log:@"Method Name: %s Reset Password Command Parsing done", __PRETTY_FUNCTION__];
            parser.commandType = CommandType_RESET_PASSWORD_RESPONSE;
            parser.parsingCommand = NO;
        }
        
        //PY 201213 - Dynamic Almond List - ADD - Command 83 - START
        else if (!strncmp((const char *)localname, kName_DynamicAlmondAdd, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_ADD))
        {
            parser.commandType = CommandType_DYNAMIC_ALMOND_ADD;
            [parser.command setAlmondPlusMACList:parser.tmpAlmondList];
            parser.parsingCommand = NO;
        }
        
        else if (!strncmp((const char *)localname, kName_AlmondMAC, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_ADD))
        {
            
            [parser.tmpAlmond setAlmondplusMAC:[parser currentString]];
            
        }
        else if (!strncmp((const char *)localname, kName_AlmondName, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_ADD))
        {
            [parser.tmpAlmond setAlmondplusName:[parser currentString]];
            
        }
        else if (!strncmp((const char *)localname, kName_AlmondPlus, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_ADD))
        {
            //Add to array
            [parser.tmpAlmondList addObject:parser.tmpAlmond];
            
        }
        //PY 201213 - Dynamic Almond List - ADD - Command 83 - END
        
        //PY 201213 - Dynamic Almond List - DELETE - Command 84 - START
        else if (!strncmp((const char *)localname, kName_DynamicAlmondDelete, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_DELETE))
        {
            parser.commandType = CommandType_DYNAMIC_ALMOND_DELETE;
            [parser.command setAlmondPlusMACList:parser.tmpAlmondList];
            parser.parsingCommand = NO;
        }
        
        else if (!strncmp((const char *)localname, kName_AlmondMAC, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_DELETE))
        {
            
            [parser.tmpAlmond setAlmondplusMAC:[parser currentString]];
            
        }
        else if (!strncmp((const char *)localname, kName_AlmondName, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_DELETE))
        {
            [parser.tmpAlmond setAlmondplusName:[parser currentString]];
            
        }
        else if (!strncmp((const char *)localname, kName_AlmondPlus, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_DELETE))
        {
            //Add to array
            [parser.tmpAlmondList addObject:parser.tmpAlmond];
            
        }
        //PY 201213 - Dynamic Almond List - DELETE - Command 84 - END
        //PY 200114 - Change Sensor Response
        else if (!strncmp((const char *)localname, kName_MobileInternalIndex, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_SENSOR_CHANGE_RESPONSE))
        {
            [parser.command setMobileInternalIndex:(unsigned int) [[parser currentString] intValue]];
            
        }else if (!strncmp((const char *)localname, kName_SensorChangeResponse, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_SENSOR_CHANGE_RESPONSE))
        {
            parser.commandType = CommandType_SENSOR_CHANGE_RESPONSE;
            parser.parsingCommand = NO;
        }
         //PY 250214 - Logout Response
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_LOGOUT_RESPONSE))
        {
            [parser.command setReason:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_ReasonCode, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_LOGOUT_RESPONSE))
        {
            [parser.command setReasonCode:[[parser currentString] intValue]];
        }
        else if (!strncmp((const char *)localname, kName_LogoutResponse, kLength_MaxTag)) {
            parser.commandType = CommandType_LOGOUT_RESPONSE;
            parser.parsingCommand = NO;
        }
        //PY 250214 - Logout ALL Response
        else if (!strncmp((const char *)localname, kName_Reason, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_LOGOUT_ALL_RESPONSE))
        {
            [parser.command setReason:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_ReasonCode, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_LOGOUT_ALL_RESPONSE))
        {
            [parser.command setReasonCode:[[parser currentString] intValue]];
        }
        else if (!strncmp((const char *)localname, kName_LogoutAllResponse, kLength_MaxTag)) {
            parser.commandType = CommandType_LOGOUT_ALL_RESPONSE;
            parser.parsingCommand = NO;
        }
        
        //PY 280214 - Dynamic Almond Name Change Response
        else if (!strncmp((const char *)localname, kName_AlmondMAC, kLength_MaxTag)
            && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_NAME_CHANGE))
        {
            
            [parser.command setAlmondplusMAC:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_AlmondName, kLength_MaxTag)
                 && (parser.storingCommandType == CommandType_DYNAMIC_ALMOND_NAME_CHANGE))
        {
            [parser.command setAlmondplusName:[parser currentString]];
        }
        else if (!strncmp((const char *)localname, kName_DynamicAlmondNameChange, kLength_MaxTag)) {
            parser.commandType = CommandType_DYNAMIC_ALMOND_NAME_CHANGE;
            parser.parsingCommand = NO;
        }

    }
    
    parser.storingCharacters = NO;
}

/*
 This callback is invoked when the parser encounters character data inside a node. The parser class determines how to use the character data.
 */
static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
    
    CommandParser *parser = (__bridge CommandParser *)ctx;
    // A state variable, "storingCharacters", is set when nodes of interest begin and end.
    // This determines whether character data is handled or ignored.
    if (parser.storingCharacters == NO) return;
    //// NSLog(@"length character Found: %d",len);
    [parser appendCharacters:(const char *)ch length:len];
}

/*
 A production application should include robust error handling as part of its parsing implementation.
 The specifics of how errors are handled depends on the application.
 */
static void errorEncounteredSAX(void __unused *ctx, const char *msg, ...) {
    //Handle errors as appropriate for your application.
    va_list arglist;
    
    printf( "Error: " );
    va_start( arglist, msg );
    vprintf( msg, arglist );
    va_end( arglist );
    //// NSLog(@"Error : %s",msg);
    NSCAssert(NO, @"Unhandled error encountered during SAX parse.");
}

// The handler struct has positions for a large number of callback functions. If NULL is supplied at a given position,
// that callback functionality won't be used. Refer to libxml documentation at http://www.xmlsoft.org for more information
// about the SAX callbacks.
static xmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    startElementSAX,            /* startElementNs */
    endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};
@end
