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
@property(nonatomic, readonly) dispatch_queue_t backgroundQueue;
@property(nonatomic, readonly) dispatch_semaphore_t network_established_latch;

@property(nonatomic) SecCertificateRef certificate;
@property BOOL certificateTrusted;
@property(nonatomic) unsigned int command;
@property(nonatomic, readonly) NSMutableData *partialData;
@property(nonatomic) BOOL networkShutdown;
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
        self.networkShutdown = NO;
        self.connectionState = SDK_UNINITIALIZED;
        _backgroundQueue = queue;
        _network_established_latch = dispatch_semaphore_create(0);
    }
    
    return self;
}

- (void)initNetworkCommunication {
    SingleTon *block_self = self;
    
    dispatch_async(self.backgroundQueue, ^(void) {
        if (block_self.inputStream == nil && block_self.outputStream == nil) {
            // Load certificate
            //
            [block_self loadCertificate];

            CFReadStreamRef readStream;
            CFWriteStreamRef writeStream;

            CFStringRef host = (__bridge CFStringRef) CLOUD_SERVER;
            UInt32 port = 1028;
            CFStreamCreatePairWithSocketToHost(NULL, host, port, &readStream, &writeStream);

            block_self.inputStream = (__bridge_transfer NSInputStream *) readStream;
            block_self.outputStream = (__bridge_transfer NSOutputStream *) writeStream;

            [block_self.inputStream setDelegate:block_self];
            [block_self.outputStream setDelegate:block_self];

            [block_self.inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
            [block_self.outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];

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
                    (__bridge id) kCFStreamSSLValidatesCertificateChain : @YES
            };

            CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef) settings);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertySSLSettings, (__bridge CFTypeRef) settings);

            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

            [block_self.inputStream scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
            [block_self.outputStream scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];

            [block_self.inputStream open];
            [block_self.outputStream open];

            NSLog(@"Streams opened and ready");

            NSLog(@"Streams entering run loop");

            // Signal to waiting socket writers that the network is up and then invoke the run loop to pump events
            block_self.isStreamConnected = YES;
            dispatch_semaphore_signal(self.network_established_latch);
            //
            while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && !block_self.networkShutdown) {
//                NSLog(@"Streams entered run loop");
            }
            block_self.isStreamConnected = NO;

            NSLog(@"Streams exited run loop");

            [block_self.delegate singletTonCloudConnectionDidClose:block_self];
        }
        else {
            NSLog(@"Stream already opened");
        }

        block_self.networkShutdown = NO;
    });
}

- (void)dealloc {
    if (_certificate) {
        CFRelease(_certificate);
        _certificate = nil;
    }
}

- (void)shutdown {
    if (_backgroundQueue == nil) {
        // already shutdown
        return;
    }
    dispatch_async(self.backgroundQueue, ^(void) {
        [self tearDownNetwork];
    });
}

- (void)waitForConnectionEstablishment {
    dispatch_time_t blockingSleepSecondsIfNotDone = 1;

    while (0 != dispatch_semaphore_wait(self.network_established_latch, blockingSleepSecondsIfNotDone)) {
        if (self.networkShutdown || self.sendCommandFail) {
            return;
        }
    }
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

                        //[SNLog Log:@"%s: Response Length : %d",__PRETTY_FUNCTION__,len];
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
                                    // [SNLog Log:@"%s: Serious error !!! should not come here// Invalid command /// without startRootTag", __PRETTY_FUNCTION__];
                                }
                                else
                                {
                                    [self.partialData getBytes:&_command range:NSMakeRange(4, 4)];
                                    NSLog(@"%s: Response Received: %d TIME => %f ",__PRETTY_FUNCTION__,NSSwapBigIntToHost(self.command), CFAbsoluteTimeGetCurrent());

                                    self.command = NSSwapBigIntToHost(self.command);
                                    // [SNLog Log:@"%s: Command Again: %d", __PRETTY_FUNCTION__,command];
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
                                            //                                            // [SNLog Log:@"%s: Received Affiliation Code", __PRETTY_FUNCTION__];
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
                                            // [SNLog Log:@"%s: Received Device Value Mobile Response", __PRETTY_FUNCTION__];
                                            [self postData:DEVICE_VALUE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 200913 - Mobile Command Response
                                        case MOBILE_COMMAND_RESPONSE: {
                                            // [SNLog Log:@"%s: Received Mobile Command Response", __PRETTY_FUNCTION__];
                                            [self postData:MOBILE_COMMAND_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 230913 - Device List Command - 81 -  Response
                                        case DYNAMIC_DEVICE_DATA: {
                                            // [SNLog Log:@"%s: Received DYNAMIC_DEVICE_DATA", __PRETTY_FUNCTION__];
                                            [self postData:DEVICE_DATA_CLOUD_NOTIFIER data:temp.command];
                                            break;
                                        }

                                            //PY 230913 - Device Value Command - 82 -  Response
                                        case DYNAMIC_DEVICE_VALUE_LIST: {
                                            // [SNLog Log:@"%s: Received DEVICE_VALUE_LIST_RESPONSE", __PRETTY_FUNCTION__];
                                            [self postData:DEVICE_VALUE_CLOUD_NOTIFIER data:temp.command];
                                            break;
                                        }
                                            //PY 291013 - Generic Command Response
                                        case GENERIC_COMMAND_RESPONSE: {
                                            // [SNLog Log:@"%s: Received Generic Command Response", __PRETTY_FUNCTION__];
                                            GenericCommandResponse *obj = (GenericCommandResponse *) temp.command;
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            obj.decodedData = decodedData;

                                            [self postData:GENERIC_COMMAND_NOTIFIER data:obj];
                                            break;
                                        }
                                            //PY 301013 - Generic Command Notification
                                        case GENERIC_COMMAND_NOTIFICATION: {
                                            // [SNLog Log:@"%s: Received Generic Command Notification", __PRETTY_FUNCTION__];
                                            GenericCommandResponse *obj = (GenericCommandResponse *) temp.command;

                                            //Decode using Base64
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            obj.decodedData = decodedData;

                                            [self postData:GENERIC_COMMAND_CLOUD_NOTIFIER data:obj];

                                            break;
                                        }
                                            //PY 011113 - Validate Account Response
                                        case VALIDATE_RESPONSE: {
                                            // [SNLog Log:@"%s: Received VALIDATE_RESPONSE", __PRETTY_FUNCTION__];
                                            [self postData:VALIDATE_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case RESET_PASSWORD_RESPONSE: {
                                            // [SNLog Log:@"%s: Received RESET_PASSWORD_RESPONSE", __PRETTY_FUNCTION__];
                                            [self postData:RESET_PWD_RESPONSE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case DYNAMIC_ALMOND_ADD: {
                                            // [SNLog Log:@"%s: Received DYNAMIC_ALMOND_ADD", __PRETTY_FUNCTION__];
                                            [self postData:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case DYNAMIC_ALMOND_DELETE: {
                                            // [SNLog Log:@"%s: Received DYNAMIC_ALMOND_DELETE", __PRETTY_FUNCTION__];
                                            [self postData:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case SENSOR_CHANGE_RESPONSE: {
                                            //[SNLog Log:@"%s: Received SENSOR_CHANGE_RESPONSE", __PRETTY_FUNCTION__];
                                            [self postData:SENSOR_CHANGE_NOTIFIER data:temp.command];
                                            break;
                                        }
                                        case DYNAMIC_ALMOND_NAME_CHANGE: {
                                            // [SNLog Log:@"%s: Received DYNAMIC_ALMOND_NAME_CHANGE", __PRETTY_FUNCTION__];
                                            [self postData:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER data:temp.command];
                                            break;
                                        }

                                        default:
                                            break;
                                    }

                                    [self.partialData replaceBytesInRange:NSMakeRange(0, endTagRange.location + endTagRange.length - 8 /* Removed 8 bytes before */) withBytes:NULL length:0];

                                    //Regenerate NSRange
                                    endTagRange = NSMakeRange(0, [self.partialData length]);
                                }
                                count++;
                            }
                            else
                            {
                                // [SNLog Log:@"%s: Number of Command Processed  : %d", __PRETTY_FUNCTION__,count];
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
                NSLog(@"Output stream error: %@", theStream.streamError.localizedDescription);
                [self shutdown];
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
                NSLog(@"%s: SESSION ENDED CONNECTION BROKEN TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                [self tearDownNetwork];
            }

            break;
        }

        default: {
//                [SNLog Log:@"%s: Unknown event", __PRETTY_FUNCTION__];
        }
    }

}

#pragma mark - Stream management

- (void)tearDownNetwork {
    // Signal to any waiting loops to exit
    dispatch_semaphore_signal(self.network_established_latch);

    self.networkShutdown = YES;
    self.isLoggedIn = NO;
    self.connectionState = CLOUD_CONNECTION_ENDED;
    self.isStreamConnected = NO;

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

    _backgroundQueue = nil;
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

