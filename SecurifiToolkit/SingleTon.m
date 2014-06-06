//  SingleTon.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//


#import "SingleTon.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "Commandparser.h"
#import "PrivateCommandTypes.h"

//Schedule runloop on backgroundQueue

#define SDK_UNINITIALIZED       0
#define NETWORK_DOWN            1
#define NOT_LOGGED_IN           2
#define LOGGED_IN               3
#define LOGGING                 4
#define INITIALIZING            5
#define CLOUD_CONNECTION_ENDED  6


@interface SingleTon ()
@property SecCertificateRef certificate;
@property dispatch_queue_t backgroundQueue;
@end

@implementation SingleTon {
    NSMutableData *partialData;
    dispatch_queue_t backgroundQueue;
}

@synthesize deviceid;
@synthesize totalReceivedLength;
@synthesize expectedLength;

@synthesize command;
@synthesize isLoggedin;
@synthesize disableNetworkDownNotification;
@synthesize isStreamConnected;
@synthesize sendCommandFail;
@synthesize connectionState;
@synthesize backgroundQueue;
@synthesize certificate;


static SingleTon *single=nil;

//todo track down and remove
//NSThread * nThread;

//todo track down and remove
static BOOL isDone=NO;

//todo track down and remove
static BOOL isBusy=NO;

//static BOOL disableNetworkDownNotification=NO;

+ (SingleTon *)getObject {
    @synchronized (self) {
        if (single) {
            return single;
        }
        else {
            return nil;
        }
    }
}

+ (void)createSingletonObj {
    @synchronized (self) {
        if (!single) {
            single = [[SingleTon alloc] init];
            single.disableNetworkDownNotification = NO;
            single.isLoggedin = NO;
            single.isStreamConnected = NO;

            single.sendCommandFail = NO;
            single.connectionState = SDK_UNINITIALIZED;

            [single initNetworkCommunication];
        }
    }
}

- (void)reconnect {
    if (isBusy == NO) {
        isBusy = YES;

        unsigned int attempt_count = 1;
        while (attempt_count < 5) {
            BOOL success = [self initReconnectSDK];
            if (success) {
                break;
            }
            sleep(attempt_count);
            attempt_count += 1;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkUp" object:self userInfo:nil];
        //self.disableNetworkDownNotification=NO;
        isBusy = NO;
    }
}

- (BOOL)initReconnectSDK {
    // NSLog(@"In Reconnect");
    [SingleTon removeSingletonObject];
    [SingleTon createSingletonObj];

//     //// NSLog(@"Stream Status: %@", [single isStreamConnected]);
//    if(single.inputStream ==nil && single.outputStream ==nil){
//        // NSLog(@"Stream Connected!");
//        return @"YES";
//    }
//    return nil;


    //Send Sanity Command
    GenericCommand *sanityCommand = [[GenericCommand alloc] init];
    sanityCommand.commandType = CLOUD_SANITY;
    sanityCommand.command = nil;

    NSError *error;
    id ret = [[SecurifiToolkit sharedInstance] sendToCloud:sanityCommand error:&error];
    if (ret != nil) {
        // NSLog(@"Reconnect initSDK - Send Sanity Successful");

        //Notify main app
        [single setConnectionState:SDK_UNINITIALIZED];
        return YES;
    }
    else {
        // NSLog(@"Reconnect Error : %@",[error localizedDescription]);
        return NO;
        //Dont notify User about network down unless it has been asked
        //Only notify once its back on internet

        //[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];
    }
}

+ (void)removeSingletonObject {
    @synchronized (self) {
        if (single) {
            [single tearDownNetwork];
            single = nil;
        }
    }
}

-(void) initNetworkCommunication{

    if(!self.backgroundQueue){
        self.backgroundQueue = dispatch_queue_create("connection_queue", NULL);
    }

    dispatch_async(self.backgroundQueue, ^(void) {
        if (self.inputStream == nil && self.outputStream == nil) {
            // Load certificate
            //
            [self loadCertificate];

            CFReadStreamRef readStream;
            CFWriteStreamRef writeStream;
            //ashutosh: ec2-54-226-113-110.compute-1.amazonaws.com
            //PY080813 Change to ashutosh
            //CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"ec2-54-226-114-39.compute-1.amazonaws.com", 1028, &readStream, &writeStream);
            NSString *cloudServer = CLOUD_SERVER;
            CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)CFBridgingRetain(cloudServer), 1028, &readStream, &writeStream);
            //Migrating to nodeLB
            //CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"nodeLB-1553508487.us-east-1.elb.amazonaws.com", 1028, &readStream, &writeStream);

            self.inputStream = (__bridge_transfer NSInputStream *)readStream;
            self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;

            [self.inputStream setDelegate:self];
            [self.outputStream setDelegate:self];

            [self.inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
            [self.outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];

            //[SSLOptions setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsExpiredRoots];
            //[SSLOptions setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsExpiredCertificates];
            //[SSLOptions setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
            //[SSLOptions setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
            //[SSLOptions setObject:@"test.domain.com:443" forKey:(NSString *)kCFStreamSSLPeerName];
            //[SSLOptions setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString*)kCFStreamSSLLevel];
            //[SSLOptions setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString*)kCFStreamPropertySocketSecurityLevel];
            //[SSLOptions setObject:myCerts forKey:(NSString *)kCFStreamSSLCertificates];
            //[SSLOptions setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLIsServer];

            NSDictionary *settings = @{
                    (__bridge id) kCFStreamSSLAllowsExpiredRoots : @NO,
                    (__bridge id) kCFStreamSSLAllowsExpiredCertificates : @NO,
                    (__bridge id) kCFStreamSSLAllowsAnyRoot : @NO,
                    (__bridge id) kCFStreamSSLValidatesCertificateChain : @NO
            };

            //            sslCerts , kCFStreamSSLCertificates,
            //            [NSNumber numberWithBool:NO], kCFStreamSSLIsServer,


            CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef)settings);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef)settings);

            [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [self.inputStream open];
            [self.outputStream open];

            self.isStreamConnected = YES;

            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && self.isStreamConnected && !isDone) {
                //// NSLog(@"Run loop did run");
            }
            //// NSLog(@"Run loop exitted");
        }
        else{
            //// NSLog(@"Stream already opened");
        }

        // [SNLog Log:@"Method Name: %s Terminating Async task", __PRETTY_FUNCTION__];
        isDone = NO;
    });
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    if (!partialData)
    {
        partialData = [[NSMutableData alloc] init];
    }

    NSString *endTagString = @"</root>";
    NSData *endTag = [endTagString dataUsingEncoding:NSUTF8StringEncoding];

    NSString *startTagString = @"<root>";
    NSData *startTag = [startTagString dataUsingEncoding:NSUTF8StringEncoding];

	// NSLog(@"stream event %i", streamEvent);
	switch (streamEvent) {
		case NSStreamEventOpenCompleted:
            //MIGRATE TCP UP Notification -- send sanity check command to cloud after initSDK
            //if outputstream is not valid .. it will trigger TCP Down notification
            //Else if SDK receives some response from cloud it will push TCP UP notification

            /*
             if (theStream == outputStream)
             {
             NSStreamStatus type;
             type = [theStream streamStatus];
             //// NSLog(@"Stream Status : %d",type);
             // NSLog(@"Dispatch OpenCompleted Notification -- TCP UP");
             [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkUP" object:self userInfo:nil];
             }
             */
			break;

		case NSStreamEventHasBytesAvailable:
			if (theStream == _inputStream) {
				while ([_inputStream hasBytesAvailable]) {
                    uint8_t inputBuffer[4096];
                    NSInteger len;

                    //Multiple entry in one callback possible
					len = [_inputStream read:inputBuffer maxLength:sizeof(inputBuffer)];
					if (len > 0) {

                        //[SNLog Log:@"Method Name: %s Response Length : %d",__PRETTY_FUNCTION__,len];
                        //If current stream has </root>
                        //1. Get NSRange and prepare command
                        //2. If command has partial command add it to mutableData object
                        //3. It mutable object has some data append new received Data to it
                        //4. repeat this procedure for newly created mutableData

                        //Append received data to partial buffer
                        [partialData appendBytes:&inputBuffer[0] length:(NSUInteger) len];

                        //Initialize range
                        NSRange endTagRange = NSMakeRange(0, [partialData length]);
                        int count=0;

                        //NOT NEEDED- Convert received buffer to NSMutableData
                        //[totalReceivedData appendBytes:&inputBuffer[0] length:len];

                        while (endTagRange.location != NSNotFound)
                        {
                            endTagRange = [partialData rangeOfData:endTag options:0 range:endTagRange];
                            if(endTagRange.location != NSNotFound)
                            {
                                //// NSLog(@"endTag Location: %i, Length: %i",endTagRange.location,endTagRange.length);

                                //Look for <root> tag in [0 to endTag]
                                NSRange startTagRange = NSMakeRange(0, endTagRange.location);

                                startTagRange = [partialData rangeOfData:startTag options:0 range:startTagRange];

                                if(startTagRange.location == NSNotFound)
                                {
                                    // [SNLog Log:@"Method Name: %s Seriouse error !!! should not come heer // Invalid command /// without startRootTag", __PRETTY_FUNCTION__];
                                }
                                else
                                {
                                    //// NSLog(@"startTag Location: %i, Length: %i",startTagRange.location,startTagRange.length);
                                    //Prepare Command
                                    [partialData getBytes:&expectedLength range:NSMakeRange(0, 4)];
                                    // [SNLog Log:@"Method Name: %s Expected Length: %d", __PRETTY_FUNCTION__,NSSwapBigIntToHost(expectedLength)];

                                    [partialData getBytes:&command range:NSMakeRange(4,4)];
                                    // [SNLog Log:@"Method Name: %s Command: %d", __PRETTY_FUNCTION__,NSSwapBigIntToHost(command)];
                                    //[SNLog Log:@"Method Name: %s Response Received: %d TIME => %f ",__PRETTY_FUNCTION__,NSSwapBigIntToHost(command), CFAbsoluteTimeGetCurrent()];

                                    NSLog(@"Method Name: %s Response Received: %d TIME => %f ",__PRETTY_FUNCTION__,NSSwapBigIntToHost(command), CFAbsoluteTimeGetCurrent());

                                    command = NSSwapBigIntToHost(command);
                                    // [SNLog Log:@"Method Name: %s Command Again: %d", __PRETTY_FUNCTION__,command];
                                    CommandParser *tempObj = [[CommandParser alloc] init];
                                    GenericCommand *temp = nil ;

                                    NSLog(@"Partial Buffer : %@",partialData);

                                    //Send single command data to parseXML rather than complete buffer
                                    NSRange xmlParser = {startTagRange.location, (endTagRange.location+endTagRange.length - 8)};

                                    NSData *buffer = [partialData subdataWithRange:xmlParser];

                                    temp = (GenericCommand *)[tempObj parseXML:buffer];

                                    //Remove 8 bytes from received command
                                    [partialData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

                                    // [SNLog Log:@"Method Name: %s Parsed Command: %d", __PRETTY_FUNCTION__, temp.commandType];

                                    switch (temp.commandType) {
                                        case LOGIN_RESPONSE: {
                                            LoginResponse *obj = (LoginResponse *) temp.command;
                                            //// NSLog(@"Singleton User ID : %@",[obj userID]);
                                            //// NSLog(@"Singleton TempPass : %@", [obj tempPass]);
                                            //// NSLog(@"Singleton isSuccessful : %d",[obj isSuccessful]);
                                            //// NSLog(@"Singleton Reason : %@",[obj reason]);

                                            if (obj.isSuccessful == YES) {
                                                //Set the indicator that we are logged in to prevent next login from User
                                                isLoggedin = YES;

                                                [self setConnectionState:LOGGED_IN];

                                                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                                NSString *tempPass = obj.tempPass;
                                                NSString *userID = obj.userID;
                                                [prefs setObject:tempPass forKey:PASSWORD];
                                                [prefs setObject:userID forKey:USERID];
                                                [prefs synchronize];
                                            }
                                            else {
                                                [self setConnectionState:NOT_LOGGED_IN];
                                            }

                                            [self postData:LOGIN_NOTIFIER data:obj];
                                            break;
                                        }
                                        case SIGNUP_RESPONSE: {
                                            // [SNLog Log:@"Method Name: %s Received Signup Response", __PRETTY_FUNCTION__];;
                                            [self postData:SIGN_UP_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case KEEP_ALIVE: {
                                            // [SNLog Log:@"Method Name: %s Received keepalive command", __PRETTY_FUNCTION__];
                                            break;
                                        }

                                        case CLOUD_SANITY_RESPONSE: {
                                            //SanityResponse *obj = (SanityResponse *)temp.command;
                                            [self postData:NETWORK_UP_NOTIFIER data:nil];
                                            break;
                                        }
                                            //PY 250214 - Logout Response
                                        case LOGOUT_RESPONSE: {
                                            [self postData:LOGOUT_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 250214 - Logout All Response
                                        case LOGOUT_ALL_RESPONSE: {
                                            [self postData:LOGOUT_ALL_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        case AFFILIATION_USER_COMPLETE: {
                                            [self postData:AFFILIATION_COMPLETE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //                                        case AFFILIATION_CODE_RESPONSE:
                                            //                                        {
                                            //                                            // [SNLog Log:@"Method Name: %s Received Affiliation Code", __PRETTY_FUNCTION__];
                                            //                                            AffiliationUserRequest *obj = (AffiliationUserRequest *)temp.command;
                                            //
                                            //                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            //
                                            //                                            [[NSNotificationCenter defaultCenter] postNotificationName:AFFILIATION_CODE_NOTIFIER object:self userInfo:data];
                                            //                                            tempObj=nil;
                                            //                                            temp=nil;
                                            //                                        }
                                            //                                            break;
                                            //PY 160913 - Almond List Response
                                        case ALMOND_LIST_RESPONSE: {
                                            [self postData:ALMOND_LIST_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 170913 - Device Data Hash Response
                                        case DEVICEDATA_HASH_RESPONSE: {
                                            [self postData:HASH_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 170913 - Device Data  Response
                                        case DEVICEDATA_RESPONSE: {
                                            [self postData:DEVICE_DATA_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 170913 - Device Data  Response
                                        case DEVICE_VALUE_LIST_RESPONSE: {
                                            // [SNLog Log:@"Method Name: %s Received Device Value Mobile Response", __PRETTY_FUNCTION__];
                                            [self postData:DEVICE_VALUE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 200913 - Mobile Command Response
                                        case MOBILE_COMMAND_RESPONSE: {
                                            // [SNLog Log:@"Method Name: %s Received Mobile Command Response", __PRETTY_FUNCTION__];
                                            [self postData:MOBILE_COMMAND_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 230913 - Device List Command - 81 -  Response
                                        case DYNAMIC_DEVICE_DATA: {
                                            // [SNLog Log:@"Method Name: %s Received DYNAMIC_DEVICE_DATA", __PRETTY_FUNCTION__];
                                            [self postData:DEVICE_DATA_CLOUD_NOTIFIER data:temp.command];
                                            break;
                                        }

                                            //PY 230913 - Device Value Command - 82 -  Response
                                        case DYNAMIC_DEVICE_VALUE_LIST: {
                                            // [SNLog Log:@"Method Name: %s Received DEVICE_VALUE_LIST_RESPONSE", __PRETTY_FUNCTION__];
                                            [self postData:DEVICE_VALUE_CLOUD_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 291013 - Generic Command Response
                                        case GENERIC_COMMAND_RESPONSE: {
                                            // [SNLog Log:@"Method Name: %s Received Generic Command Response", __PRETTY_FUNCTION__];
                                            GenericCommandResponse *obj = (GenericCommandResponse *) temp.command;
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            obj.decodedData = decodedData;

                                            [self postData:GENERIC_COMMAND_NOTIFIER data:obj];
                                            break;
                                        }
                                            //PY 301013 - Generic Command Notification
                                        case GENERIC_COMMAND_NOTIFICATION: {
                                            // [SNLog Log:@"Method Name: %s Received Generic Command Notification", __PRETTY_FUNCTION__];
                                            GenericCommandResponse *obj = (GenericCommandResponse *) temp.command;

                                            //Decode using Base64
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            obj.decodedData = decodedData;

                                            [self postData:GENERIC_COMMAND_CLOUD_NOTIFIER data:obj];

                                            break;
                                        }
                                            //PY 011113 - Validate Account Response
                                        case VALIDATE_RESPONSE: {
                                            // [SNLog Log:@"Method Name: %s Received VALIDATE_RESPONSE", __PRETTY_FUNCTION__];
                                            [self postData:VALIDATE_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case RESET_PASSWORD_RESPONSE: {
                                            // [SNLog Log:@"Method Name: %s Received RESET_PASSWORD_RESPONSE", __PRETTY_FUNCTION__];
                                            [self postData:RESET_PWD_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case DYNAMIC_ALMOND_ADD: {
                                            // [SNLog Log:@"Method Name: %s Received DYNAMIC_ALMOND_ADD", __PRETTY_FUNCTION__];
                                            [self postData:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case DYNAMIC_ALMOND_DELETE: {
                                            // [SNLog Log:@"Method Name: %s Received DYNAMIC_ALMOND_DELETE", __PRETTY_FUNCTION__];
                                            [self postData:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case SENSOR_CHANGE_RESPONSE: {
                                            //[SNLog Log:@"Method Name: %s Received SENSOR_CHANGE_RESPONSE", __PRETTY_FUNCTION__];
                                            [self postData:SENSOR_CHANGE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case DYNAMIC_ALMOND_NAME_CHANGE: {
                                            // [SNLog Log:@"Method Name: %s Received DYNAMIC_ALMOND_NAME_CHANGE", __PRETTY_FUNCTION__];
                                            [self postData:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        default:
                                            break;
                                    }
                                    //                                    if (temp.commandType == LOGIN_RESPONSE)
                                    //                                    {
                                    //
                                    //                                    }
                                    /* MIGRATING TO iOS SDK
                                     if (NSSwapBigIntToHost(command) == 2)
                                     {
                                     // NSLog(@"Inside command == 2");
                                     //Create Notification and send it
                                     NSString *output = [[NSString alloc] initWithData:partialData encoding:NSUTF8StringEncoding];

                                     if (nil != output) {
                                     // NSLog(@"server said: %@", output);
                                     //[self messageReceived:output];
                                     //send local notification to update view
                                     NSDictionary *data = [NSDictionary dictionaryWithObject:output forKey:@"data"];

                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponse" object:self userInfo:data];

                                     //[[NSNotificationCenter defaultCenter] postNotificationName:@"tempPassLogingRes" object:self userInfo:data];
                                     }
                                     }

                                     if ((NSSwapBigIntToHost(command) == 24) || (NSSwapBigIntToHost(command) == 26))
                                     {
                                     // NSLog(@"Inside command == %d",NSSwapBigIntToHost(command));
                                     //Create Notification and send it
                                     NSString *output = [[NSString alloc] initWithData:partialData encoding:NSUTF8StringEncoding];

                                     if (nil != output) {
                                     // NSLog(@"server said: %@", output);
                                     //[self messageReceived:output];
                                     //send local notification to update view
                                     NSDictionary *data = [NSDictionary dictionaryWithObject:output forKey:@"data"];

                                     //[[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponse" object:self userInfo:data];
                                     }
                                     }
                                     */

                                    //// NSLog(@"Partial Buffer before trim : %@",partialData);

                                    //Trim Partial Buffer
                                    //This will trim parital buffer till </root>


                                    [partialData replaceBytesInRange:NSMakeRange(0, endTagRange.location+endTagRange.length - 8 /* Removed 8 bytes before */) withBytes:NULL length:0];

                                    //Regenerate NSRange
                                    endTagRange = NSMakeRange(0, [partialData length]);

                                    //// NSLog(@"Partial Buffer after trim : %@",partialData);
                                }
                                count++;
                            }
                            else
                            {
                                // [SNLog Log:@"Method Name: %s Number of Command Processed  : %d", __PRETTY_FUNCTION__,count];
                                //At this point paritalBuffer will have unffinised command data
                            }
                        }
                    }
                }
            }
            break;

        case NSStreamEventErrorOccurred:
            //Cleanup stream -- taken from EventEndEncountered
            //We should create new object of singleton class
            //if (theStream == outputStream && [outputStream streamStatus] == NSStreamStatusError)

            if (theStream == self.outputStream) {
                // [SNLog Log:@"Method Name: %s Connection event: server down", __PRETTY_FUNCTION__];

                [self tearDownNetwork];
                isDone = YES;
                isLoggedin = NO;
                [self setConnectionState:NETWORK_DOWN];

                //PY301013 - Reconnect
                [self postData:NETWORK_DOWN_NOTIFIER data:nil];
                //PY 080114 - TRYING
                //                dispatch_async(backgroundQueue, ^ {
                //
                //                    [NSThread detachNewThreadSelector:@selector(reconnect) toTarget:self withObject:nil];
                //                });

                //[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];

                //TEST --- Remove it later
                //// NSLog(@"Dispatch ErrorOccurred Notification -- TCP DOWN");

                //Some how we should know that this is comming from thread or main thread
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];

                //User APP should not handle reconnection
                //Dispatch thread
                //[SingleTon reconnect];

                //Testing with reachability

                /*
                 if ([[SingleTon getObject] disableNetworkDownNotification] == NO) //Implies not in thread
                 {
                 // NSLog(@"Launching thread from errorEvent handler");
                 //First Write of initSDK will throw NetworkDOWN notification
                 //dispatch_async(backgroundQueue, ^ {

                 [NSThread detachNewThreadSelector:@selector(reconnect) toTarget:self withObject:nil];

                 //[self reconnect];
                 //});
                 }
                 */
            }
            break;

        case NSStreamEventHasSpaceAvailable: {
            BOOL trusted = [self isTrustedCertificate];
            if (!trusted) {
                [theStream close];
            }
            break;
        }


        case NSStreamEventEndEncountered: {
            if (theStream == self.inputStream) {
                NSLog(@"Method Name: %s SESSION ENDED CONNECTION BROKEN TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());

                [self tearDownNetwork];
                isDone = YES;
                isLoggedin = NO;
                [self setConnectionState:CLOUD_CONNECTION_ENDED];

                //User APP should not handle reconnection
                //Dispatch thread
                //[SingleTon reconnect];

                //PY301013 - Reconnect
                [self postData:NETWORK_DOWN_NOTIFIER data:nil];
                dispatch_async(backgroundQueue, ^{
                    [NSThread detachNewThreadSelector:@selector(reconnect) toTarget:self withObject:nil];
                });

            }

            break;
        }

        default: {
//                [SNLog Log:@"Method Name: %s Unknown event", __PRETTY_FUNCTION__];
        }
    }

}

- (void)tearDownNetwork {
    [self.outputStream close];
    [self.inputStream close];

    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    [self.outputStream removeFromRunLoop:loop forMode:NSDefaultRunLoopMode];
    [self.inputStream removeFromRunLoop:loop forMode:NSDefaultRunLoopMode];

    self.outputStream = nil;
    self.inputStream = nil;
}

#pragma mark - Payload notification

- (void)postData:(NSString*)notificationName data:(id)payload {
    NSDictionary *data = nil;
    if (payload) {
        data = @{@"data" : payload};
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:data];
}


#pragma mark - SSL certificates

- (void)loadCertificate {
/*
    2014-06-05 sinclair no actual need to load a cert file so we disable for now; besides, this seems to trigger a leak inside of Security framework.

    NSString *path = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"der"];
    NSData *certData = [NSData dataWithContentsOfFile:path];

    SecCertificateRef oldCertificate = self.certificate;
    self.certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certData);
    if (oldCertificate) {
        CFRelease(oldCertificate);
    }
*/
}

- (BOOL)isTrustedCertificate {
    if (self.certificate == nil) {
        return YES;
    }

    SecPolicyRef policy = SecPolicyCreateSSL(NO, CFSTR("*.securifi.com"));
    //CFArrayRef streamCertificates = (__bridge CFArrayRef)([theStream propertyForKey:(NSString *) kCFStreamPropertySSLPeerCertificates]);
    // NSLog(@"After kCFStreamPropertySSLPeerCertificates");

    SecCertificateRef certs[1] = {self.certificate};
    SecTrustRef trust = NULL;
    CFArrayRef array = CFArrayCreate(NULL, (const void **) certs, 1, NULL);
    SecTrustCreateWithCertificates(array, policy, &trust);

    SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) (@[(id) self.certificate]));

    SecTrustResultType trustResultType = kSecTrustResultInvalid;
    OSStatus status = SecTrustEvaluate(trust, &trustResultType);

    BOOL trusted = (status == errSecSuccess);

    if (trust) {
        CFRelease(trust);
    }
    if (policy) {
        CFRelease(policy);
    }
    if (array) {
        CFRelease(array);
    }

    return trusted;
}

@end

