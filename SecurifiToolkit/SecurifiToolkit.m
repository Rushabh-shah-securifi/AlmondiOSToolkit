//
//  SecurifiToolkit.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SecurifiToolkit.h"
#import "SingleTon.h"
#import "LoginTempPass.h"
#import "PrivateCommandTypes.h"

#define SDK_UNINITIALIZED 0
#define NETWORK_DOWN   1
#define NOT_LOGGED_IN   2
#define LOGGED_IN       3
#define LOGGING  4
#define INITIALIZING  5
#define CLOUD_CONNECTION_ENDED  6

@interface SecurifiToolkit ()
@property (nonatomic, readonly) dispatch_queue_t backgroundQueue;
@property (nonatomic, readonly) dispatch_queue_t reconnectQueue;
@property (nonatomic, readonly) dispatch_queue_t singleTonQueue;
@property (nonatomic, readonly) SingleTon *networkSingleton;
@property BOOL initializing; // when TRUE an op is already in progress to set up a network
@end

@implementation SecurifiToolkit

#pragma mark - Lifecycle methods

+ (instancetype)sharedInstance {
    static dispatch_once_t once_predicate;
    static SecurifiToolkit *singleton = nil;

    dispatch_once(&once_predicate, ^{
        singleton = [SecurifiToolkit new];
    });

    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        _backgroundQueue = dispatch_queue_create("command_queue", DISPATCH_QUEUE_SERIAL);
        _reconnectQueue = dispatch_queue_create("network_reconnect_queue", DISPATCH_QUEUE_SERIAL);
        _singleTonQueue = dispatch_queue_create("network_reconnect_queue", DISPATCH_QUEUE_CONCURRENT);

        // Listen for loss of connection
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReachabilityDidChange:) name:kSFIReachabilityChangedNotification object:nil];

        // Listen for network events so that we can spawn 'reconnect' operations
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkDown:) name:NETWORK_DOWN_NOTIFIER object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFIReachabilityChangedNotification object:nil];
}

- (void)setupNetworkSingleton {
    SingleTon *old = self.networkSingleton;
    [old shutdown];
    _networkSingleton = [SingleTon newSingleton:self.singleTonQueue];
}

#pragma mark - Initialization and state

- (NSInteger)getConnectionState {
    SingleTon *singleTon = self.networkSingleton;
    if (singleTon) {
        return [singleTon connectionState];
    }
    else {
        return SDK_UNINITIALIZED;
    }
}

- (void)initSDK {
    NSLog(@"INIT SDK");

    if (self.initializing == NO) {
        self.initializing = YES;

        [self setupNetworkSingleton];
        SingleTon *singleTon = self.networkSingleton;

        //Start a Async task of sending Sanity command and TempPassCommand
        //Async task will send command and will generate respective events
        dispatch_async(self.backgroundQueue, ^(void) {
            [self internalInitSdk:singleTon];
        });
    }
}

- (void)internalInitSdk:(SingleTon*)singleTon {
    singleTon.connectionState = INITIALIZING;

    GenericCommand *sanityCommand = [[GenericCommand alloc] init];
    sanityCommand.commandType = CLOUD_SANITY;
    sanityCommand.command = nil;

    NSError *error;
    id ret = [self internalSendToCloud:sanityCommand error:&error];
    if (ret == nil || error) {
        singleTon.connectionState = NETWORK_DOWN;
        NSLog(@"Error init sdk after sending cmd: %@", error.localizedDescription);
        self.initializing = NO;
        return;
    }

    NSLog(@"Method Name: %s SESSION STARTED TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
    NSLog(@"initSDK - Send Sanity Successful");

    //Send Temppass command
    @try {
        //todo store password in keychain, not user defaults
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if ([prefs objectForKey:PASSWORD] && [prefs objectForKey:USERID]) {
            GenericCommand *cloudCommand = [[GenericCommand alloc] init];
            LoginTempPass *loginCommand = [[LoginTempPass alloc] init];

            loginCommand.UserID = [prefs objectForKey:USERID];
            loginCommand.TempPass = [prefs objectForKey:PASSWORD];

            cloudCommand.commandType = LOGIN_TEMPPASS_COMMAND;
            cloudCommand.command = loginCommand;

            NSError *error_2;
            id ret_2 = [self internalSendToCloud:cloudCommand error:&error_2];
            if (ret_2 == nil || error_2) {
                NSLog(@"Error init sdk: %@", error_2.localizedDescription);
                singleTon.connectionState = NETWORK_DOWN;
            }
            else {
                NSLog(@"initSDK - Temp login sent");
                singleTon.connectionState = LOGGING;
            }
        }
        else {
            NSLog(@"TempPass not found in preferences");
            //// [SNLog Log:@"Method Name: %s TempPass not found in preferences", __PRETTY_FUNCTION__];
            //Send notification so that App can display Login / Password screen
            //[SecurifiToolkit initSDKCloud];
            singleTon.connectionState = NOT_LOGGED_IN;
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFIER object:self userInfo:nil];
        }
    }
    @catch (NSException *e) {
        singleTon.connectionState = NETWORK_DOWN;
        NSLog(@" Exception throw on init sdk. Network down: %@", e.reason);
    }

    self.initializing = NO;
}

/*PY 190913 To Establish cloud connection without trying to login - Useful for Logout command*/
- (void)initSDKCloud {
    NSLog(@"Init SDK Cloud");

    if (self.initializing == NO) {
        self.initializing = YES;

        [self setupNetworkSingleton];

        SingleTon *socket = self.networkSingleton;

        GenericCommand *sanityCommand = [[GenericCommand alloc] init];
        sanityCommand.commandType = CLOUD_SANITY;
        sanityCommand.command = nil;

        [self asyncSendToCloud:sanityCommand completion:^(BOOL success, NSError *error2) {
            if (success) {
                NSLog(@"Failed to init SDK cloud: %@", error2.description);
                [socket setConnectionState:NETWORK_DOWN];
            }
            else {
                NSLog(@"Method Name: %s SESSION STARTED - SANITY TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                [socket setConnectionState:NOT_LOGGED_IN];
            }

            self.initializing = NO;
        }];
    }
}

#pragma mark - Command dispatch

typedef void (^SendCompletion)(BOOL success, NSError *error);

- (void)asyncSendToCloud:(id)command completion:(SendCompletion)callback {
    dispatch_async(self.backgroundQueue, ^() {
        NSError *outError;
        id ret = [self internalSendToCloud:command error:&outError];
        BOOL success = (ret != nil);

        if (!success) {
            if (self.networkSingleton.disableNetworkDownNotification == NO) {
                NSLog(@"Posting NETWORK_DOWN_NOTIFIER, ret=%@, error=%@", ret, outError.localizedDescription);
                [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
            }
        }

        if (callback) {
            callback(success, outError);
        }
    });
}

- (void)asyncSendToCloud:(GenericCommand*)command {
    [self asyncSendToCloud:command completion:^(BOOL success, NSError *error2) {
        if (success) {
            NSLog(@"[Generic cmd: %d] send success", command.commandType);
        }
        else {
            NSLog(@"[Generic cmd: %d] send error%@", command.commandType, error2.localizedDescription);
        }
    }];
}

- (id)internalSendToCloud:(id)sender error:(NSError **)outError {
    @synchronized (self) {
        SingleTon *socket = self.networkSingleton;

        do {
            if (socket.sendCommandFail == YES) {
                // [SNLog Log:@"Method Name: %s Break send loop and return error",__PRETTY_FUNCTION__];
                NSMutableDictionary *details = [NSMutableDictionary dictionary];
                [details setValue:@"Securifi - Send Error" forKey:NSLocalizedDescriptionKey];
                *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];
                return nil;
            }
        }
        while (socket.isStreamConnected != YES && socket.sendCommandFail != YES);

        GenericCommand *obj = (GenericCommand *) sender;

        NSString *commandPayload;
        unsigned int commandLength;
        unsigned int commandType;
        NSData *sendCommandPayload;

        @try {
            switch (obj.commandType) {
                case LOGIN_COMMAND: {
                    /* Check if User is already logged in [ if he has received loginResponse command */
                    if (socket.isLoggedIn == YES) {
                        //Post Callback that you are logged in
                        LoginResponse *object = [[LoginResponse alloc] init];
                        object.isSuccessful = NO;
                        object.userID = nil;
                        object.tempPass = nil;
                        [object setReason:@"Already Loggedin"];

                        NSDictionary *data = @{@"data" : object};

                        //Send Object
                        //NSLog(@"Before Notification");
                        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFIER object:self userInfo:data];

                        return @"Yes";
                    }
                    else {
                        // [SNLog Log:@"Method Name: %s Sending LOGIN COMMAND",__PRETTY_FUNCTION__];
                        Login *ob1 = (Login *) obj.command;
                        commandPayload = [NSString stringWithFormat:FRESH_LOGIN_REQUEST_XML, ob1.UserID, ob1.Password];


                        commandType = (uint32_t) htonl(LOGIN_COMMAND);

                        sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                        commandLength = (uint32_t) htonl([sendCommandPayload length]);
                    }

                    break;
                }
                case LOGIN_TEMPPASS_COMMAND: {
                    // [SNLog Log:@"Method Name: %s Sending LOGIN_TEMPPASS_COMMAND",__PRETTY_FUNCTION__];
                    LoginTempPass *ob1 = (LoginTempPass *) obj.command;
                    commandPayload = [NSString stringWithFormat:LOGIN_REQUEST_XML, ob1.UserID, ob1.TempPass];

                    //Cloud has switch for both command as LOGIN_COMMAND
                    commandType = (uint32_t) htonl(LOGIN_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case LOGOUT_COMMAND: {
                    // [SNLog Log:@"Method Name: %s Sending LOGOUT COMMAND",__PRETTY_FUNCTION__];
//                    Logout *ob1 = (Logout *)obj.command;
                    commandPayload = LOGOUT_REQUEST_XML;
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    //Cloud has switch for both command as LOGIN_COMMAND
                    commandType = (uint32_t) htonl(LOGOUT_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    //PY 250214 - Logout Response will be received now
                    //Remove preferences
//                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                    
//                    // [SNLog Log:@"Method Name: %s TempPass - %@ \n UserID - %@",__PRETTY_FUNCTION__,[prefs objectForKey:tmpPwdKey], [prefs objectForKey:usrIDKey]];
//                    [prefs removeObjectForKey:tmpPwdKey];
//                    [prefs removeObjectForKey:usrIDKey];
//                    [prefs synchronize];
//                    // [SNLog Log:@"Method Name: %s After delete\n",__PRETTY_FUNCTION__];
//                    // [SNLog Log:@"Method Name: %s TempPass - %@ \n UserID - %@",__PRETTY_FUNCTION__,[prefs objectForKey:tmpPwdKey], [prefs objectForKey:usrIDKey]];
//                    
//                    [socket setConnectionState:NOT_LOGGED_IN];
//                    
//                    //PY 160913 - Reconnect to cloud
//                    id ret = [[SecurifiToolkit sharedInstance] initSDKCloud];
//                    if (ret == nil)
//                    {
//                        // [SNLog Log:@"Method Name: %s APP Delegate : SDKInit Error",__PRETTY_FUNCTION__];
//                    }
//                    

                    break;
                }
                case SIGNUP_COMMAND: {
                    // [SNLog Log:@"Method Name: %s Sending SIGNUP Command",__PRETTY_FUNCTION__];
                    Signup *ob1 = (Signup *) obj.command;
                    commandPayload = [NSString stringWithFormat:SIGNUP_REQUEST_XML, ob1.UserID, ob1.Password];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(SIGNUP_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case CLOUD_SANITY: {
                    // [SNLog Log:@"Method Name: %s Sending CLOUD_SANITY Command",__PRETTY_FUNCTION__];
                    commandPayload = CLOUDSANITY_REQUEST_XML;//[NSString stringWithFormat:CLOUDSANITY_REQUEST_XML];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(CLOUD_SANITY);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case AFFILIATION_CODE_REQUEST: {
                    // [SNLog Log:@"Method Name: %s Sending Affiliation Code request",__PRETTY_FUNCTION__];
                    AffiliationUserRequest *affiliationObj = (AffiliationUserRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:AFFILIATION_CODE_REQUEST_XML, affiliationObj.Code];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(AFFILIATION_CODE_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case LOGOUT_ALL_COMMAND: {
                    //PY 160913 - Logout all command
                    // [SNLog Log:@"Method Name: %s Sending Logout request",__PRETTY_FUNCTION__];
                    //            <root>
                    //            <LogoutAll>
                    //            <EmailID>validemail@mycompany.com</EmailID>
                    //            <Password>originalpassword</Password>
                    //            </LogoutAll>
                    //            </root>

                    LogoutAllRequest *logoutAllObj = (LogoutAllRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:LOGOUT_ALL_REQUEST_XML, logoutAllObj.UserID, logoutAllObj.Password];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(LOGOUT_ALL_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case ALMOND_LIST: {
                    //PY 160913 - almond list command
                    // [SNLog Log:@"Method Name: %s Sending almond list request",__PRETTY_FUNCTION__];
                    // <root></root>

                    //AlmondListRequest *logoutAllObj = (AlmondListRequest *)obj.command;
                    commandPayload = ALMOND_LIST_REQUEST_XML; //[NSString stringWithFormat:];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(ALMOND_LIST);


                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case DEVICEDATA_HASH: {
                    //PY 170913 - Device Hash command
                    // [SNLog Log:@"Method Name: %s Sending Device Hash request",__PRETTY_FUNCTION__];
                    //            <root><DeviceDataHash>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceDataHash></root>

                    DeviceDataHashRequest *deviceDataHashObj = (DeviceDataHashRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_DATA_HASH_REQUEST_XML, deviceDataHashObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(DEVICEDATA_HASH);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case DEVICEDATA: {
                    //PY 170913 - Device Data command
                    // [SNLog Log:@"Method Name: %s Sending Device Data request",__PRETTY_FUNCTION__];
                    //            <root><DeviceData>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceData></root>

                    DeviceListRequest *deviceDataObj = (DeviceListRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_DATA_REQUEST_XML, deviceDataObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(DEVICEDATA);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case DEVICE_VALUE: {
                    //PY 190913 - Device Value command
                    // [SNLog Log:@"Method Name: %s Sending DeviceValue request",__PRETTY_FUNCTION__];
                    //            <root><DeviceValue>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceValue></root>

                    DeviceValueRequest *deviceValueObj = (DeviceValueRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_VALUE_REQUEST_XML, deviceValueObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(DEVICE_VALUE);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case MOBILE_COMMAND: {
                    //PY 200913 - Mobile command
                    // [SNLog Log:@"Method Name: %s Sending MobileCommand request",__PRETTY_FUNCTION__];
                    /* <root><MobileCommand>
                     * <AlmondplusMAC>251176214925585</AlmondplusMAC>
                     * <Device ID=”6”>
                     * <NewValue Index=”1”>NewTextValue</NewValue>
                     * </Device>
                     * <MobileInternalIndex>324</MobileInternalIndex>
                     * </MobileCommand></root>
                     */

                    MobileCommandRequest *mobileCommandObj = (MobileCommandRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:MOBILE_COMMAND_REQUEST_XML, mobileCommandObj.almondMAC, mobileCommandObj.deviceID, mobileCommandObj.indexID, mobileCommandObj.changedValue, mobileCommandObj.internalIndex];
                    NSLog(@"Command length %lu", (unsigned long) [commandPayload length]);


                    //PY 290114: Replacing the \" (backslash quotes) in the string to just " (quotes).
                    //When we are using string obfuscation the decoded string has the \ escape character with it.
                    //The cloud is unable to handle it and rejects the command.
                    //Add this line to any XML  string with has \" in it. For example: <Device ID=\"%@\">
                    commandPayload = [self stringByRemovingEscapeCharacters:commandPayload];

                    commandType = (uint32_t) htonl(MOBILE_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    NSLog(@"Payload Command length %lu", (unsigned long) [sendCommandPayload length]);
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case GENERIC_COMMAND_REQUEST: {
                    //PY 291013 - Generic command
//                    <root>
//                    <GenericCommandRequest>
//                    <AlmondplusMAC>251176214925585</AlmondplusMAC>
//                    <ApplicationID></ApplicationID>
//                    <MobileInternalIndex>1</MobileInternalIndex>
//                    <Data>
//                    [Base64Encoded]
//                    <root><Reboot>1</Reboot></root>[Base64Encoded]
//                    </Data>
//                    </GenericCommandRequest>
//                    </root>
                    // [SNLog Log:@"Method Name: %s Sending GenricCommand request",__PRETTY_FUNCTION__];

                    GenericCommandRequest *genericCommandObj = (GenericCommandRequest *) obj.command;

                    //Encode data to Base64
                    NSData *dataToEncode = [genericCommandObj.data dataUsingEncoding:NSUTF8StringEncoding];
                    NSData *encodedData = [dataToEncode base64EncodedDataWithOptions:0];
                    NSString *encodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];

                    commandPayload = [NSString stringWithFormat:GENERIC_COMMAND_REQUEST_XML, genericCommandObj.almondMAC, genericCommandObj.applicationID, genericCommandObj.mobileInternalIndex, encodedString];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(GENERIC_COMMAND_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                    //PY 011113 - Reactivation email command
                case VALIDATE_REQUEST: {
                    // [SNLog Log:@"Method Name: %s Sending VALIDATE request",__PRETTY_FUNCTION__];
                    /*
                     <root>
                     <ValidateAccountRequest>
                     <EmailID>xyz@abc.com</EmailID>
                     </ValidateAccountRequest>
                     </root>
                     */

                    ValidateAccountRequest *validateObj = (ValidateAccountRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:VALIDATE_REQUEST_XML, validateObj.email];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(VALIDATE_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case RESET_PASSWORD_REQUEST: {
                    // [SNLog Log:@"Method Name: %s Sending RESET_PASSWORD request",__PRETTY_FUNCTION__];
                    /*
                     <root>
                     <ResetPasswordRequest>
                     <EmailID>xyz@abc.com</EmailID>
                     </ResetPasswordRequest>
                     </root>
                     */

                    ResetPasswordRequest *resetPwdObj = (ResetPasswordRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:RESET_PWD_REQUEST_XML, resetPwdObj.email];
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    commandType = (uint32_t) htonl(RESET_PASSWORD_REQUEST);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                    //PY 150114 - Forced Data Update
                case DEVICE_DATA_FORCED_UPDATE_REQUEST: {
                    // [SNLog Log:@"Method Name: %s Sending DEVICE_DATA_FORCED_UPDATE_REQUEST request",__PRETTY_FUNCTION__];
                    /*
                    <root><DeviceDataForcedUpdate>
                    <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    <MobileInternalIndex>1234</MobileInternalIndex>
                    </DeviceDataForcedUpdate></root>
                     */

                    SensorForcedUpdateRequest *forcedUpdateObj = (SensorForcedUpdateRequest *) obj.command;
                    commandPayload = [NSString stringWithFormat:SENSOR_FORCED_UPDATE_REQUEST_XML, forcedUpdateObj.almondMAC, forcedUpdateObj.mobileInternalIndex];
                    //commandLength = (uint32_t)htonl([commandPayload length]);


                    //Send as Command 61
                    commandType = (uint32_t) htonl(MOBILE_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }
                case SENSOR_CHANGE_REQUEST: {
                    //PY 200114 - Sensor name and location change
                    //[SNLog Log:@"Method Name: %s Sending SENSOR_CHANGE_REQUEST request",__PRETTY_FUNCTION__];

                    /*
                     <root><SensorChange>
                     <AlmondplusMAC>251176214925585</AlmondplusMAC>
                     <Device ID=”6”>
                     <NewName optional>MyGreatSensor</NewName>
                     <NewLocation optional>Buckingham Palace</NewLocation>
                     </Device>
                     <MobileInternalIndex>324</MobileInternalIndex>
                     </SensorChange></root>
                     */

                    SensorChangeRequest *sensorChangeObj = (SensorChangeRequest *) obj.command;

                    if (sensorChangeObj.changedName != nil && sensorChangeObj.changedLocation == nil) {
                        commandPayload = [NSString stringWithFormat:SENSOR_CHANGE_NAME_REQUEST_XML, sensorChangeObj.almondMAC, sensorChangeObj.deviceID, sensorChangeObj.changedName, sensorChangeObj.mobileInternalIndex];
                    }
                    else if (sensorChangeObj.changedLocation != nil && sensorChangeObj.changedName == nil) {
                        commandPayload = [NSString stringWithFormat:SENSOR_CHANGE_LOCATION_REQUEST_XML, sensorChangeObj.almondMAC, sensorChangeObj.deviceID, sensorChangeObj.changedLocation, sensorChangeObj.mobileInternalIndex];
                    }
                    else {
                        commandPayload = [NSString stringWithFormat:SENSOR_CHANGE_REQUEST_XML, sensorChangeObj.almondMAC, sensorChangeObj.deviceID, sensorChangeObj.changedName, sensorChangeObj.changedLocation, sensorChangeObj.mobileInternalIndex];
                    }
                    //commandLength = (uint32_t)htonl([commandPayload length]);

                    //PY 290114: Replacing the \" (backslash quotes) in the string to just " (quotes).
                    //When we are using string obfuscation the decoded string has the \ escape character with it.
                    //The cloud is unable to handle it and rejects the command.
                    //Add this line to any XML  string with has \" in it. For example: <Device ID=\"%@\">
                    commandPayload = [self stringByRemovingEscapeCharacters:commandPayload];

                    NSLog(@"Command Payload %@: ", commandPayload);

                    //Send as Command 61
                    commandType = (uint32_t) htonl(MOBILE_COMMAND);

                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t) htonl([sendCommandPayload length]);

                    break;
                }

                default:
                    break;
            }
            //isLoggedin might be set to 1 if we miss the TCP termination callback
            //Check on each write if it fails set isLoggedin to

            NSLog(@"@Payload being sent: %@", sendCommandPayload);

            NSStreamStatus type;
            do {
                type = [socket.outputStream streamStatus];
                // [SNLog Log:@"Method Name: %s Socket in opening state.. wait..",__PRETTY_FUNCTION__];
            } while (type == 1);

            [socket.outputStream streamStatus];

            // [SNLog Log:@"Method Name: %s Out of stream type check loop : %d",__PRETTY_FUNCTION__,type];

            if (socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [socket.outputStream write:(uint8_t *) &commandLength maxLength:4]) {
                    socket.isLoggedIn = NO;
                    NSMutableDictionary *details = [NSMutableDictionary dictionary];
                    [details setValue:@"Securifi Length - Send Error" forKey:NSLocalizedDescriptionKey];
                    *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];

                    if ([socket disableNetworkDownNotification] == NO) {
                        //PUSH Notify NetworkDOWN
                        // [SNLog Log:@"Method Name: %s From First Write ",__PRETTY_FUNCTION__];

                        [socket setSendCommandFail:YES];
                        [socket setIsStreamConnected:NO];

//                        [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
                    }
                    return nil;
                }
            }

            //stream status
            if (socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [socket.outputStream write:(uint8_t *) &commandType maxLength:4]) {
                    socket.isLoggedIn = NO;
                    NSMutableDictionary *details = [NSMutableDictionary dictionary];
                    [details setValue:@"Securifi Command Type - Send Error" forKey:NSLocalizedDescriptionKey];
                    *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];

                    if ([socket disableNetworkDownNotification] == NO) {
                        // [SNLog Log:@"Method Name: %s From Second Write ",__PRETTY_FUNCTION__];

                        [socket setSendCommandFail:YES];
                        [socket setIsStreamConnected:NO];

                        //PUSH Notify NetworkDOWN
//                        [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
                        //Start reconnnect thread and return nil
                        //[NSThread detachNewThreadSelector:@selector(reconnect) toTarget:[SingleTon getObject] withObject:nil];
                    }
                    return nil;
                }
            }

            if (socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                if (-1 == [socket.outputStream write:[sendCommandPayload bytes] maxLength:[sendCommandPayload length]]) {
                    socket.isLoggedIn = NO;
                    NSMutableDictionary *details = [NSMutableDictionary dictionary];
                    [details setValue:@"Securifi Payload - Send Error" forKey:NSLocalizedDescriptionKey];
                    *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];

                    if ([socket disableNetworkDownNotification] == NO) {
                        // [SNLog Log:@"Method Name: %s From Third Write ",__PRETTY_FUNCTION__];

                        [socket setSendCommandFail:YES];
                        [socket setIsStreamConnected:NO];

                        //PUSH Notify NetworkDOWN
//                        [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
                        //Start reconnnect thread and return nil
                        //[NSThread detachNewThreadSelector:@selector(reconnect) toTarget:[SingleTon getObject] withObject:nil];
                    }
                    return nil;
                }
            }

            if (socket.outputStream != nil && socket.outputStream.streamStatus != NSStreamStatusError) {
                NSLog(@"Method Name: %s Command send to cloud: TIME => %f ", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                return @"yes";
            }
            else {
                NSLog(@"Output stream is nil");
                return nil;
            }
        }
        @catch (NSException *e) {
            // [SNLog Log:@"Method Name: %s Exception : %@",__PRETTY_FUNCTION__,e.reason];
            @throw;
        }
    }//synchronized
}

- (NSString *)stringByRemovingEscapeCharacters:(NSString *)inputString {
    NSMutableString *s = [NSMutableString stringWithString:inputString];
    [s replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    //[s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

#pragma mark - Network reconnection handling

- (void)onReachabilityDidChange:(id)notification {
    if ([[SFIReachabilityManager sharedManager] isReachable]) {
        NSLog(@"changed to reachable");
        [[SecurifiToolkit sharedInstance] initSDK];
    }
}

- (void)onNetworkDown:(id)notification {
    if (!self.initializing) {
        dispatch_async(self.reconnectQueue, ^{
            // Run on a separate thread that can be put to sleep in reconnect.
            [NSThread detachNewThreadSelector:@selector(reconnect) toTarget:self withObject:nil];
        });
    }
}

- (void)reconnect {
    if (self.initializing == NO) {
        self.initializing = YES;

        unsigned int attempt_count = 1;
        while (attempt_count < 5) {
            [self setupNetworkSingleton];

            SingleTon *singleTon = self.networkSingleton;
            [self internalInitSdk:singleTon];

            if ([self getConnectionState] != NETWORK_DOWN && [self getConnectionState] != INITIALIZING) {
                break;
            }

            sleep(attempt_count + 2);
            attempt_count += 1;
        } // end attempts to reconnect

        NSInteger state = [self getConnectionState];

        switch (state) {
            case INITIALIZING: {
                NSLog(@"reconnect state: %ld (initializing)", (long)state);
                break;
            }
            case NETWORK_DOWN: {
                NSLog(@"reconnect state: %ld (network down)", (long)state);
                break;
            }
            default: {
                NSLog(@"reconnect state: %ld", (long)state);
                [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_UP_NOTIFIER object:self userInfo:nil];
                break;
            }
        }

        self.initializing = NO;
    }
}

@end
