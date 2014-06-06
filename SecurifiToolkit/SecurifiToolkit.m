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

//todo remove me or push into a property
dispatch_queue_t bgQueue;

#define SDK_UNINITIALIZED 0
#define NETWORK_DOWN   1
#define NOT_LOGGED_IN   2
#define LOGGED_IN       3
#define LOGGING  4
#define INITIALIZING  5
#define CLOUD_CONNECTION_ENDED  6

@implementation SecurifiToolkit


+ (id)initSDK {
    NSLog(@"INIT SDK");

    [SingleTon removeSingletonObject];
    [SingleTon createSingletonObj];

    if (!bgQueue) {
        bgQueue = dispatch_queue_create("command_queue", DISPATCH_QUEUE_SERIAL);
    }

    //Start a Async task of sending Sanity command and TempPassCommand and return YES
    //Async task will send command and will generate respective events

    dispatch_async(bgQueue, ^(void) {
        SingleTon *socket = [SingleTon getObject];
        [socket setConnectionState:INITIALIZING];

        GenericCommand *sanityCommand = [[GenericCommand alloc] init];
        sanityCommand.commandType = CLOUD_SANITY;
        sanityCommand.command = nil;

        NSError *error;

        id ret = [SecurifiToolkit sendtoCloud:sanityCommand error:&error];
        if (ret != nil) {
            NSLog(@"Method Name: %s SESSION STARTED TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
            NSLog(@"initSDK - Send Sanity Successful");

            //Send Temppass command
            @try {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                if ([prefs objectForKey:PASSWORD] && [prefs objectForKey:USERID]) {
                    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
                    LoginTempPass *loginCommand = [[LoginTempPass alloc] init];

                    loginCommand.UserID = [prefs objectForKey:USERID];
                    loginCommand.TempPass = [prefs objectForKey:PASSWORD];

                    cloudCommand.commandType = LOGIN_TEMPPASS_COMMAND;
                    cloudCommand.command = loginCommand;

                    NSError *error_2;
                    id ret_2 = [SecurifiToolkit sendtoCloud:cloudCommand error:&error_2];
                    if (error_2) {
                        NSLog(@"Error init sdk: %@", error_2.localizedDescription);
                        [socket setConnectionState:NETWORK_DOWN];
                    }
                    else if (ret_2 != nil) {
                        NSLog(@"initSDK - Temp login sent");
                        [socket setConnectionState:LOGGING];
                    }
                    else {
                        NSLog(@"Error init sdk: %@", error_2.localizedDescription);
                        [socket setConnectionState:NETWORK_DOWN];
                    }
                }
                else {
                    NSLog(@"TempPass not found in preferences");
                    //// [SNLog Log:@"Method Name: %s TempPass not found in preferences", __PRETTY_FUNCTION__];
                    //Send notification so that App can display Login / Password screen
                    //[SecurifiToolkit initSDKCloud];
                    [socket setConnectionState:NOT_LOGGED_IN];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFIER object:self userInfo:nil];
                }
            }
            @catch (NSException *e) {
                NSLog(@" Network Down %@", e.reason);
            }
        }
        else {
            [socket setConnectionState:NETWORK_DOWN];
        }
    });
    //4. Send temppass login command
    //Now try to send Login Request using stored credentials


    //For initSDK


    return @"Yes";

    //Send tempPass Command to check existing login
    //Send SANITY_COMMAND TO chekc cloud connectivity and insturct main app that you are
    //connected to cloud

    //3 Register Reachability callback
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];

    //Change the host name here to change the server your monitoring
    //remoteHostLabel.text = [NSString stringWithFormat: @"Remote Host: %@", @"www.apple.com"];
    /*
     hostReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
     [hostReach startNotifier];
     */

    //return @"yes";
}


//+(id)initReconnectSDK
//{
//    NSLog(@"INIT Reconnect SDK");
//    
//    [SingleTon removeSingletonObject];
//    [SingleTon createSingletonObj];
//    dispatch_queue_t cloudReconnectQueue;
//    if(!cloudReconnectQueue){
//        cloudReconnectQueue = dispatch_queue_create("command_reconnect_queue", DISPATCH_QUEUE_SERIAL);
//    }
//
//    //Start a Async task of sending Sanity command and TempPassCommand and return YES
//    //Asynch task will send command and will generate respective events
//    
//    dispatch_async(cloudReconnectQueue, ^(void) {
//        
//        SingleTon *socket = [SingleTon getObject];
//        [socket setConnectionState:CLOUD_CONNECTION_ENDED];
//        
////        GenericCommand *sanityCommand = [[GenericCommand alloc] init];
////        sanityCommand.commandType=CLOUD_SANITY;
////        sanityCommand.command=nil;
////        
////        NSError *error;
////        id ret = nil;
////        ret = [SecurifiToolkit sendtoCloud:sanityCommand error:&error];
////        sanityCommand=nil;
////        
////        if (ret != nil)
////        {
//            //// [SNLog Log:@"Method Name: %s initSDK - Send Sanity Successful", __PRETTY_FUNCTION__];
//            //Send Temppass command
//            @try{
//                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                if ([prefs objectForKey:PASSWORD] && [prefs objectForKey:USERID])
//                {
//                    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
//                    LoginTempPass *loginCommand = [[LoginTempPass alloc] init];
//                    
//                    loginCommand.UserID =  [prefs objectForKey:USERID];
//                    loginCommand.TempPass = [prefs objectForKey:PASSWORD];
//                    
//                    cloudCommand.commandType=LOGIN_TEMPPASS_COMMAND;
//                    cloudCommand.command=loginCommand;
//                    
//                    NSError *error;
//                    id ret = nil;
//                    ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
//                    if (ret != nil)
//                    {
//                        NSLog(@"init Reconnect SDK - Temp login sent");
//                        //// [SNLog Log:@"Method Name: %s initSDK - Temp login sent", __PRETTY_FUNCTION__];
//                        [socket setConnectionState:LOGGING];
//                        //return @"yes";
//                    }
//                    else
//                    {
//                        NSLog(@"Error : %@",[error localizedDescription]);
//                        //// [SNLog Log:@"Method Name: %s Error : %@", __PRETTY_FUNCTION__,[error localizedDescription]];
//                        [socket setConnectionState:NETWORK_DOWN];
//                        //return nil;
//                    }
//                    cloudCommand=nil;
//                    loginCommand=nil;
//                }
//                else
//                {
//                    NSLog(@"TempPass not found in preferences");
//                    //// [SNLog Log:@"Method Name: %s TempPass not found in preferences", __PRETTY_FUNCTION__];
//                    //Send notification so that App can display Login / Password screen
//                    //[SecurifiToolkit initSDKCloud];
//                    [socket setConnectionState:NOT_LOGGED_IN];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFIER object:self userInfo:nil];
//                    //return @"yes";
//                }
//            }
//            @catch (NSException *e) {
//                NSLog(@" Network Down %@", e.reason);
//                //// [SNLog Log:@"Method Name: %s Network Down %@", __PRETTY_FUNCTION__,e.reason];
//            }
////        }
////        else
////        {
////            //// [SNLog Log:@"Method Name: %s Error : %@", __PRETTY_FUNCTION__,[error localizedDescription]];
////            
////            [socket setConnectionState:NETWORK_DOWN];
////            //return nil;
////        }
//    });
//
//    
//    
//    return @"Yes";
//    
//}

+(NSInteger)getConnectionState
{
    SingleTon *socket = [SingleTon getObject];
    return [socket connectionState];
}

/*
+(BOOL)isLoggedin
{
    SingleTon *socket = [SingleTon getObject];
    if (socket)
    {
        if (YES == [socket isLoggedin])
            return YES;
        else
            return NO;
    }
    else
    {
        return NO;
    }
}
*/

/*PY 190913 To Establish cloud connection without trying to login - Useful for Logout command*/
+ (id)initSDKCloud {
    NSLog(@"Init Cloud");
    [SingleTon removeSingletonObject];
    [SingleTon createSingletonObj];

    //todo this leaks; why not just use default queue.
    dispatch_queue_t cloudQueue = dispatch_queue_create("cloud_connect_queue", DISPATCH_QUEUE_SERIAL);

    //Start a Async task of sending Sanity command and TempPassCommand and return YES
    //Async task will send command and will generate respective events
    dispatch_async(cloudQueue, ^(void) {
        SingleTon *socket = [SingleTon getObject];

        GenericCommand *sanityCommand = [[GenericCommand alloc] init];
        sanityCommand.commandType = CLOUD_SANITY;
        sanityCommand.command = nil;

        NSError *error;

        id ret = [SecurifiToolkit sendtoCloud:sanityCommand error:&error];
        if (ret != nil) {
            NSLog(@"Method Name: %s SESSION STARTED - SANITY TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
            [socket setConnectionState:NOT_LOGGED_IN];
        }
        else {
            [socket setConnectionState:NETWORK_DOWN];
        }
    });

    return @"Yes";
}

/*
//Called by Reachability whenever status changes.
+ (void) reachabilityChanged: (NSNotification* )note
{
    // [SNLog Log:@"Method Name: %s Reachability changed",__PRETTY_FUNCTION__];
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    if(curReach == hostReach)
	{
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        BOOL connectionRequired= [curReach connectionRequired];
        //summaryLabel.hidden = (netStatus != ReachableViaWWAN);
        
        NSString* baseLabel=  @"";
        if(connectionRequired)
        {
            baseLabel=  @"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
        }
        else
        {
            baseLabel=  @"Cellular data network is active.\n  Internet traffic will be routed through it.";
        }
        // [SNLog Log:@"Method Name: %s Base Label : %@",__PRETTY_FUNCTION__,baseLabel];
        
        
//        if (netStatus == ReachableViaWiFi)
//             //[SNLog Log:@"Method Name: %s Reachable via Local WiFi",__PRETTY_FUNCTION__];
//        else if (netStatus == ReachableViaWWAN)
//             //[SNLog Log:@"Method Name: %s Reachable via Data network (3G)",__PRETTY_FUNCTION__];
//        else
//             //[SNLog Log:@"Method Name: %s Not Reachabel",__PRETTY_FUNCTION__];
    }
}
*/

+(id)sendtoCloud:(id)sender error:(NSError **)outError
{
    @synchronized(self){
        
        SingleTon *socket = [SingleTon getObject];
        
        do {
            if (socket.sendCommandFail == YES)
            {
                // [SNLog Log:@"Method Name: %s Break send loop and return error",__PRETTY_FUNCTION__];
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Securifi - Send Error" forKey:NSLocalizedDescriptionKey];
                *outError=[NSError errorWithDomain:@"Securifi" code:200 userInfo:details];
                return nil;
            }
        }
        while (socket.isStreamConnected != YES && socket.sendCommandFail != YES);

        GenericCommand *obj = (GenericCommand *) sender;
        
        NSString *commandPayload;
        unsigned int commandLength;
        unsigned int commandType;
        NSData *sendCommandPayload;
        
        @try{
            switch (obj.commandType) {
                case LOGIN_COMMAND:
                {
                    /* Check if User is already logged in [ if he has received loginResponse command */
                    if (socket.isLoggedin == YES)
                        // if (0)
                    {
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
                    else
                    {
                        // [SNLog Log:@"Method Name: %s Sending LOGIN COMMAND",__PRETTY_FUNCTION__];
                        Login *ob1 = (Login *)obj.command;
                        commandPayload = [NSString stringWithFormat:FRESH_LOGIN_REQUEST_XML,ob1.UserID,ob1.Password];
                        
                        
                        commandType= (uint32_t)htonl(LOGIN_COMMAND);
                        
                        sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                        commandLength = (uint32_t)htonl([sendCommandPayload length]);
                    }
                }
                    break;
                case LOGIN_TEMPPASS_COMMAND:
                {
                    // [SNLog Log:@"Method Name: %s Sending LOGIN_TEMPPASS_COMMAND",__PRETTY_FUNCTION__];
                    LoginTempPass *ob1 = (LoginTempPass *)obj.command;
                    commandPayload = [NSString stringWithFormat:LOGIN_REQUEST_XML,ob1.UserID,ob1.TempPass];
                    
                    //Cloud has switch for both command as LOGIN_COMMAND
                    commandType= (uint32_t)htonl(LOGIN_COMMAND);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case LOGOUT_COMMAND:
                {
                    // [SNLog Log:@"Method Name: %s Sending LOGOUT COMMAND",__PRETTY_FUNCTION__];
//                    Logout *ob1 = (Logout *)obj.command;
                    commandPayload = LOGOUT_REQUEST_XML;
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    //Cloud has switch for both command as LOGIN_COMMAND
                    commandType= (uint32_t)htonl(LOGOUT_COMMAND);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);

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
//                    id ret = [SecurifiToolkit initSDKCloud];
//                    if (ret == nil)
//                    {
//                        // [SNLog Log:@"Method Name: %s APP Delegate : SDKInit Error",__PRETTY_FUNCTION__];
//                    }
//                    
                    
                }
                    break;
                case SIGNUP_COMMAND:
                {
                    // [SNLog Log:@"Method Name: %s Sending SIGNUP Command",__PRETTY_FUNCTION__];
                    Signup *ob1 = (Signup *)obj.command;
                    commandPayload = [NSString stringWithFormat:SIGNUP_REQUEST_XML,ob1.UserID,ob1.Password];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(SIGNUP_COMMAND);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                    
                case CLOUD_SANITY:
                {
                    // [SNLog Log:@"Method Name: %s Sending CLOUD_SANITY Command",__PRETTY_FUNCTION__];
                    commandPayload = CLOUDSANITY_REQUEST_XML;//[NSString stringWithFormat:CLOUDSANITY_REQUEST_XML];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(CLOUD_SANITY);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case AFFILIATION_CODE_REQUEST:
                {
                    // [SNLog Log:@"Method Name: %s Sending Affiliation Code request",__PRETTY_FUNCTION__];
                    AffiliationUserRequest *affiliationObj = (AffiliationUserRequest*)obj.command;
                    commandPayload =[NSString stringWithFormat:AFFILIATION_CODE_REQUEST_XML,affiliationObj.Code];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(AFFILIATION_CODE_REQUEST);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case LOGOUT_ALL_COMMAND:
                {
                    //PY 160913 - Logout all command
                    // [SNLog Log:@"Method Name: %s Sending Logout request",__PRETTY_FUNCTION__];
                    //            <root>
                    //            <LogoutAll>
                    //            <EmailID>validemail@mycompany.com</EmailID>
                    //            <Password>originalpassword</Password>
                    //            </LogoutAll>
                    //            </root>
                    
                    LogoutAllRequest *logoutAllObj = (LogoutAllRequest *)obj.command;
                    commandPayload = [NSString stringWithFormat:LOGOUT_ALL_REQUEST_XML,logoutAllObj.UserID,logoutAllObj.Password];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(LOGOUT_ALL_COMMAND);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case ALMOND_LIST:
                {
                    //PY 160913 - almond list command
                   // [SNLog Log:@"Method Name: %s Sending almond list request",__PRETTY_FUNCTION__];
                    // <root></root>
                    
                    //AlmondListRequest *logoutAllObj = (AlmondListRequest *)obj.command;
                    commandPayload = ALMOND_LIST_REQUEST_XML; //[NSString stringWithFormat:];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(ALMOND_LIST);
                    
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case DEVICEDATA_HASH:
                {
                    //PY 170913 - Device Hash command
                    // [SNLog Log:@"Method Name: %s Sending Device Hash request",__PRETTY_FUNCTION__];
                    //            <root><DeviceDataHash>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceDataHash></root>
                    
                    DeviceDataHashRequest *deviceDataHashObj = (DeviceDataHashRequest *)obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_DATA_HASH_REQUEST_XML,deviceDataHashObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(DEVICEDATA_HASH);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case DEVICEDATA:
                {
                    //PY 170913 - Device Data command
                    // [SNLog Log:@"Method Name: %s Sending Device Data request",__PRETTY_FUNCTION__];
                    //            <root><DeviceData>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceData></root>
                    
                    DeviceListRequest *deviceDataObj = (DeviceListRequest *)obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_DATA_REQUEST_XML,deviceDataObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(DEVICEDATA);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case DEVICE_VALUE:
                {
                    //PY 190913 - Device Value command
                    // [SNLog Log:@"Method Name: %s Sending DeviceValue request",__PRETTY_FUNCTION__];
                    //            <root><DeviceValue>
                    //            <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    //            </DeviceValue></root>
                    
                    DeviceValueRequest *deviceValueObj = (DeviceValueRequest *)obj.command;
                    commandPayload = [NSString stringWithFormat:DEVICE_VALUE_REQUEST_XML,deviceValueObj.almondMAC];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(DEVICE_VALUE);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case MOBILE_COMMAND:
                {
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
                    
                    MobileCommandRequest *mobileCommandObj = (MobileCommandRequest *)obj.command;
                    commandPayload = [NSString stringWithFormat:MOBILE_COMMAND_REQUEST_XML,mobileCommandObj.almondMAC, mobileCommandObj.deviceID, mobileCommandObj.indexID, mobileCommandObj.changedValue, mobileCommandObj.internalIndex];
                    NSLog(@"Command length %lu", (unsigned long)[commandPayload length]);
                    
                    
                    //PY 290114: Replacing the \" (backslash quotes) in the string to just " (quotes).
                    //When we are using string obfuscation the decoded string has the \ escape character with it.
                    //The cloud is unable to handle it and rejects the command.
                    //Add this line to any XML  string with has \" in it. For example: <Device ID=\"%@\">
                    commandPayload = [self stringByRemovingEscapeCharacters:commandPayload];
                    
                    commandType= (uint32_t)htonl(MOBILE_COMMAND);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    NSLog(@"Payload Command length %lu", (unsigned long)[sendCommandPayload length]);
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case GENERIC_COMMAND_REQUEST:
                {
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
                    
                    GenericCommandRequest *genericCommandObj = (GenericCommandRequest *)obj.command;
                    
                    //Encode data to Base64
                    NSData *dataToEncode = [genericCommandObj.data dataUsingEncoding:NSUTF8StringEncoding];
                    NSData *encodedData = [dataToEncode base64EncodedDataWithOptions:0];
                    NSString *encodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
                    
                    commandPayload = [NSString stringWithFormat:GENERIC_COMMAND_REQUEST_XML,genericCommandObj.almondMAC, genericCommandObj.applicationID, genericCommandObj.mobileInternalIndex, encodedString];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(GENERIC_COMMAND_REQUEST);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                    //PY 011113 - Reactivation email command
                case VALIDATE_REQUEST:
                {
                     // [SNLog Log:@"Method Name: %s Sending VALIDATE request",__PRETTY_FUNCTION__];
                    /*
                     <root>
                     <ValidateAccountRequest>
                     <EmailID>xyz@abc.com</EmailID>
                     </ValidateAccountRequest>
                     </root>
                     */
                    
                    ValidateAccountRequest *validateObj = (ValidateAccountRequest *)obj.command;
                    commandPayload = [NSString stringWithFormat:VALIDATE_REQUEST_XML,validateObj.email];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(VALIDATE_REQUEST);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                case RESET_PASSWORD_REQUEST:
                {
                    // [SNLog Log:@"Method Name: %s Sending RESET_PASSWORD request",__PRETTY_FUNCTION__];
                    /*
                     <root>
                     <ResetPasswordRequest>
                     <EmailID>xyz@abc.com</EmailID>
                     </ResetPasswordRequest>
                     </root>
                     */
                    
                    ResetPasswordRequest *resetPwdObj = (ResetPasswordRequest *)obj.command;
                    commandPayload = [NSString stringWithFormat:RESET_PWD_REQUEST_XML,resetPwdObj.email];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    commandType= (uint32_t)htonl(RESET_PASSWORD_REQUEST);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);
                }
                    break;
                    //PY 150114 - Forced Data Update
                case DEVICE_DATA_FORCED_UPDATE_REQUEST:
                {
                    // [SNLog Log:@"Method Name: %s Sending DEVICE_DATA_FORCED_UPDATE_REQUEST request",__PRETTY_FUNCTION__];
                    /*
                    <root><DeviceDataForcedUpdate>
                    <AlmondplusMAC>251176214925585</AlmondplusMAC>
                    <MobileInternalIndex>1234</MobileInternalIndex>
                    </DeviceDataForcedUpdate></root>
                     */
                    
                    SensorForcedUpdateRequest *forcedUpdateObj = (SensorForcedUpdateRequest *)obj.command;
                    commandPayload = [NSString stringWithFormat:SENSOR_FORCED_UPDATE_REQUEST_XML,forcedUpdateObj.almondMAC, forcedUpdateObj.mobileInternalIndex];
                    //commandLength = (uint32_t)htonl([commandPayload length]);
                    
                    
                    //Send as Command 61
                    commandType= (uint32_t)htonl(MOBILE_COMMAND);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);

                    break;
                }
                    
                    //PY 200114 - Sensor name and location change
                case SENSOR_CHANGE_REQUEST:
                {
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
                    
                    SensorChangeRequest *sensorChangeObj = (SensorChangeRequest *)obj.command;

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
                    commandType= (uint32_t)htonl(MOBILE_COMMAND);
                    
                    sendCommandPayload = [[NSData alloc] initWithData:[commandPayload dataUsingEncoding:NSASCIIStringEncoding]];
                    commandLength = (uint32_t)htonl([sendCommandPayload length]);

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

            if (socket.outputStream != nil) {
                if (-1 == [socket.outputStream write:(uint8_t *) &commandLength maxLength:4]) {
                    socket.isLoggedin = NO;
                    NSMutableDictionary *details = [NSMutableDictionary dictionary];
                    [details setValue:@"Securifi Length - Send Error" forKey:NSLocalizedDescriptionKey];
                    *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];

                    if ([socket disableNetworkDownNotification] == NO) {
                        //PUSH Notify NetworkDOWN
                        // [SNLog Log:@"Method Name: %s From First Write ",__PRETTY_FUNCTION__];

                        [socket setSendCommandFail:YES];
                        [socket setIsStreamConnected:NO];

                        [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
                    }
                    return nil;
                }
            }

            //stream status
            if (socket.outputStream != nil) {
                if (-1 == [socket.outputStream write:(uint8_t *) &commandType maxLength:4]) {
                    socket.isLoggedin = NO;
                    NSMutableDictionary *details = [NSMutableDictionary dictionary];
                    [details setValue:@"Securifi Command Type - Send Error" forKey:NSLocalizedDescriptionKey];
                    *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];

                    if ([socket disableNetworkDownNotification] == NO) {
                        // [SNLog Log:@"Method Name: %s From Second Write ",__PRETTY_FUNCTION__];

                        [socket setSendCommandFail:YES];
                        [socket setIsStreamConnected:NO];

                        //PUSH Notify NetworkDOWN
                        [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
                        //Start reconnnect thread and return nil
                        //[NSThread detachNewThreadSelector:@selector(reconnect) toTarget:[SingleTon getObject] withObject:nil];
                    }
                    return nil;
                }
            }

            if (socket.outputStream != nil) {
                if (-1 == [socket.outputStream write:[sendCommandPayload bytes] maxLength:[sendCommandPayload length]]) {
                    socket.isLoggedin = NO;
                    NSMutableDictionary *details = [NSMutableDictionary dictionary];
                    [details setValue:@"Securifi Payload - Send Error" forKey:NSLocalizedDescriptionKey];
                    *outError = [NSError errorWithDomain:@"Securifi" code:200 userInfo:details];

                    if ([socket disableNetworkDownNotification] == NO) {
                        // [SNLog Log:@"Method Name: %s From Third Write ",__PRETTY_FUNCTION__];

                        [socket setSendCommandFail:YES];
                        [socket setIsStreamConnected:NO];

                        //PUSH Notify NetworkDOWN
                        [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
                        //Start reconnnect thread and return nil
                        //[NSThread detachNewThreadSelector:@selector(reconnect) toTarget:[SingleTon getObject] withObject:nil];
                    }
                    return nil;
                }
            }

            NSLog(@"Method Name: %s Command send to cloud: TIME => %f ",__PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
            return @"yes";
        }
        @catch (NSException *e) {
            // [SNLog Log:@"Method Name: %s Exception : %@",__PRETTY_FUNCTION__,e.reason];
            @throw;
        }
        //}//Where is cloud
    }//synchronized
}

+ (NSString *)stringByRemovingEscapeCharacters: (NSString *)inputString
{
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


@end
