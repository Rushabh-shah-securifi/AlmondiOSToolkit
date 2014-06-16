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

#define SDK_UNINITIALIZED       0
#define NETWORK_DOWN            1
#define NOT_LOGGED_IN           2
#define LOGGED_IN               3
#define LOGIN_IN_PROCESS        4
#define INITIALIZING            5
#define CLOUD_CONNECTION_ENDED  6


@interface SingleTon ()
@property(nonatomic) SecCertificateRef certificate;
@property BOOL certificateTrusted;
@property(nonatomic, readonly) dispatch_queue_t backgroundQueue;
@property(nonatomic) unsigned int command;
@property(nonatomic, readonly) NSMutableData *partialData;
@property(nonatomic) BOOL cloudConnectionEnded;
@end

@implementation SingleTon

+ (SingleTon *)newSingleton:(dispatch_queue_t)backgroundQueue {
    SingleTon *obj = [[SingleTon alloc] initWithQueue:backgroundQueue];
    [obj initNetworkCommunication];
    return obj;
}

- (id)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        self.disableNetworkDownNotification = NO;
        self.isLoggedIn = NO;
        self.isStreamConnected = NO;
        self.sendCommandFail = NO;
        self.cloudConnectionEnded = NO;
        self.connectionState = SDK_UNINITIALIZED;
        _backgroundQueue = queue;
    }
    
    return self;
}

- (void)initNetworkCommunication {
    dispatch_async(self.backgroundQueue, ^(void) {
        if (self.inputStream == nil && self.outputStream == nil) {
            // Load certificate
            //
            [self loadCertificate];

            CFReadStreamRef readStream;
            CFWriteStreamRef writeStream;

            CFStringRef host = (__bridge CFStringRef) CLOUD_SERVER;
            CFStreamCreatePairWithSocketToHost(NULL, host, 1028, &readStream, &writeStream);

            self.inputStream = (__bridge_transfer NSInputStream *) readStream;
            self.outputStream = (__bridge_transfer NSOutputStream *) writeStream;

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

            CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef) settings);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef) settings);

            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

            [self.inputStream scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
            [self.outputStream scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];

            [self.inputStream open];
            [self.outputStream open];

            self.isStreamConnected = YES;

            while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && self.isStreamConnected && !self.cloudConnectionEnded) {
                //// NSLog(@"Run loop did run");
            }

            NSLog(@"Run loop exited");

            [self.delegate singletTonCloudConnectionDidClose:self];
        }
        else {
            NSLog(@"Stream already opened");
        }

        self.cloudConnectionEnded = NO;
    });
}

- (void)dealloc {
    if (_certificate) {
        CFRelease(_certificate);
        _certificate = nil;
    }
}

- (void)shutdown {
    dispatch_async(self.backgroundQueue, ^(void) {
        [self tearDownNetwork];
    });
}

#pragma mark - NSStreamDelegate methods

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    if (!self.partialData)
    {
        _partialData = [[NSMutableData alloc] init];
    }

    NSString *endTagString = @"</root>";
    NSData *endTag = [endTagString dataUsingEncoding:NSUTF8StringEncoding];

    NSString *startTagString = @"<root>";
    NSData *startTag = [startTagString dataUsingEncoding:NSUTF8StringEncoding];

	// NSLog(@"stream event %i", streamEvent);
	switch (streamEvent) {
		case NSStreamEventOpenCompleted: {
            break;
        }

		case NSStreamEventHasBytesAvailable:
			if (theStream == self.inputStream) {
				while ([self.inputStream hasBytesAvailable]) {
                    uint8_t inputBuffer[4096];
                    NSInteger len;

                    //Multiple entry in one callback possible
					len = [self.inputStream read:inputBuffer maxLength:sizeof(inputBuffer)];
					if (len > 0) {

                        //[SNLog Log:@"Method Name: %s Response Length : %d",__PRETTY_FUNCTION__,len];
                        //If current stream has </root>
                        //1. Get NSRange and prepare command
                        //2. If command has partial command add it to mutableData object
                        //3. It mutable object has some data append new received Data to it
                        //4. repeat this procedure for newly created mutableData

                        //Append received data to partial buffer
                        [self.partialData appendBytes:&inputBuffer[0] length:(NSUInteger) len];

                        //Initialize range
                        NSRange endTagRange = NSMakeRange(0, [self.partialData length]);
                        int count=0;

                        //NOT NEEDED- Convert received buffer to NSMutableData
                        //[totalReceivedData appendBytes:&inputBuffer[0] length:len];

                        while (endTagRange.location != NSNotFound)
                        {
                            endTagRange = [self.partialData rangeOfData:endTag options:0 range:endTagRange];
                            if(endTagRange.location != NSNotFound)
                            {
                                //// NSLog(@"endTag Location: %i, Length: %i",endTagRange.location,endTagRange.length);

                                //Look for <root> tag in [0 to endTag]
                                NSRange startTagRange = NSMakeRange(0, endTagRange.location);

                                startTagRange = [self.partialData rangeOfData:startTag options:0 range:startTagRange];

                                if(startTagRange.location == NSNotFound)
                                {
                                    // [SNLog Log:@"Method Name: %s Seriouse error !!! should not come heer // Invalid command /// without startRootTag", __PRETTY_FUNCTION__];
                                }
                                else
                                {
                                    [self.partialData getBytes:&_command range:NSMakeRange(4, 4)];
                                    NSLog(@"Method Name: %s Response Received: %d TIME => %f ",__PRETTY_FUNCTION__,NSSwapBigIntToHost(self.command), CFAbsoluteTimeGetCurrent());

                                    self.command = NSSwapBigIntToHost(self.command);
                                    // [SNLog Log:@"Method Name: %s Command Again: %d", __PRETTY_FUNCTION__,command];
                                    CommandParser *tempObj = [[CommandParser alloc] init];
                                    GenericCommand *temp = nil ;

                                    //Send single command data to parseXML rather than complete buffer
                                    NSRange xmlParserRange = {startTagRange.location, (endTagRange.location+endTagRange.length - 8)};
                                    NSData *buffer = [self.partialData subdataWithRange:xmlParserRange];

                                    {
                                        NSString *str = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
                                        NSLog(@"Partial Buffer : %@", str);
                                    }

                                    temp = (GenericCommand *)[tempObj parseXML:buffer];

                                    //Remove 8 bytes from received command
                                    [self.partialData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

                                    switch (temp.commandType) {
                                        case LOGIN_RESPONSE: {
                                            LoginResponse *obj = (LoginResponse *) temp.command;
                                            if (obj.isSuccessful == YES) {
                                                //Set the indicator that we are logged in to prevent next login from User
                                                self.isLoggedIn = YES;
                                                self.connectionState = LOGGED_IN;
                                            }
                                            else {
                                                self.isLoggedIn = NO;
                                                self.connectionState = NOT_LOGGED_IN;
                                            }

                                            [self postData:LOGIN_NOTIFIER data:obj];
                                            break;
                                        }
                                        case SIGNUP_RESPONSE: {
                                            [self postData:SIGN_UP_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case KEEP_ALIVE: {
                                            break;
                                        }

                                        case CLOUD_SANITY_RESPONSE: {
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


                                    [self.partialData replaceBytesInRange:NSMakeRange(0, endTagRange.location + endTagRange.length - 8 /* Removed 8 bytes before */) withBytes:NULL length:0];

                                    //Regenerate NSRange
                                    endTagRange = NSMakeRange(0, [self.partialData length]);

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
                [self shutdown];
//                self.connectionState = NETWORK_DOWN;

                //PY301013 - Reconnect
//                [self postData:NETWORK_DOWN_NOTIFIER data:nil];
                //PY 080114 - TRYING
                //                dispatch_async(backgroundQueue, ^ {
                //
                //                    [NSThread detachNewThreadSelector:@selector(reconnect) toTarget:self withObject:nil];
                //                });

                //[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];

                //TEST --- Remove it later
                //// NSLog(@"Dispatch ErrorOccurred Notification -- TCP DOWN");

                //Some how we should know that this is coming from thread or main thread
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
            // Evaluate the SSL connection
            if (!self.certificateTrusted) {
                BOOL trusted = [self isTrustedCertificate:theStream];
                if (!trusted) {
                    [self shutdown];
                }
                self.certificateTrusted = trusted;
            }

            break;
        }

        case NSStreamEventEndEncountered: {
            if (theStream == self.inputStream) {
                NSLog(@"Method Name: %s SESSION ENDED CONNECTION BROKEN TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                [self tearDownNetwork];
            }

            break;
        }

        default: {
//                [SNLog Log:@"Method Name: %s Unknown event", __PRETTY_FUNCTION__];
        }
    }

}

#pragma mark - Stream management

- (void)tearDownNetwork {
    // Signal to any waiting loops to exit
    self.cloudConnectionEnded = YES;
    self.isLoggedIn = NO;
    self.connectionState = CLOUD_CONNECTION_ENDED;

    NSRunLoop *loop = [NSRunLoop currentRunLoop];

    if (self.outputStream != nil) {
        [self.outputStream close];
        [self.outputStream removeFromRunLoop:loop forMode:NSDefaultRunLoopMode];
        self.outputStream = nil;
    }

    if (self.inputStream != nil) {
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:loop forMode:NSDefaultRunLoopMode];
        self.inputStream = nil;
    }
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"der"];
    NSData *certData = [NSData dataWithContentsOfFile:path];

    SecCertificateRef oldCertificate = self.certificate;
    self.certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certData);
    if (oldCertificate) {
        CFRelease(oldCertificate);
    }
}

- (BOOL)isTrustedCertificate:(NSStream *)aStream {
    SecPolicyRef policy = SecPolicyCreateSSL(NO, CFSTR("*.securifi.com"));

    SecTrustRef trust = NULL;
    CFArrayRef streamCertificates = (__bridge CFArrayRef) [aStream propertyForKey:(NSString *) kCFStreamPropertySSLPeerCertificates];
    SecTrustCreateWithCertificates(streamCertificates, policy, &trust);

    SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) @[(id) self.certificate]);

    SecTrustResultType trustResultType = kSecTrustResultInvalid;
    OSStatus status = SecTrustEvaluate(trust, &trustResultType);

    BOOL trusted;
    if (status == errSecSuccess) {
        // expect trustResultType == kSecTrustResultUnspecified until the cert exists in the keychain
        if (trustResultType == kSecTrustResultUnspecified) {
            trusted = YES;
        }
        else {
            NSLog(@"%s: Certificate is not trusted. TrustResultType: %d", __PRETTY_FUNCTION__, trustResultType);
            trusted = NO;
        }
    }
    else {
        NSLog(@"%s: Unable to evaluate trust: %d", __PRETTY_FUNCTION__, (int) status);
        trusted = NO;
    }

    if (trust) {
        CFRelease(trust);
    }
    if (policy) {
        CFRelease(policy);
    }

    return trusted;
}

@end

