//
//  SingleTon.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//


#import "SingleTon.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
//#import <SecurifiToolkit/LoginResponse.h>
#import "GenericCommand.h"
#import "Commandparser.h"
#import "PrivateCommandTypes.h"
#import "AlmondPlusSDKConstants.h"
#import "SNLog.h"
#import <Security/Security.h>
#import "Base64.h"
#import "LoginTempPass.h"
//Schedule runloop on backgroundQueue

#define SDK_UNINITIALIZED       0
#define NETWORK_DOWN            1
#define NOT_LOGGED_IN           2
#define LOGGED_IN               3
#define LOGGING                 4
#define INITIALIZING            5
#define CLOUD_CONNECTION_ENDED  6


@implementation SingleTon

@synthesize deviceid;
@synthesize inputStream, outputStream;
@synthesize expectedLength,totalReceivedLength;

@synthesize command;
@synthesize isLoggedin;
@synthesize disableNetworkDownNotification;
@synthesize isStreamConnected;
@synthesize sendCommandFail;
@synthesize connectionState;
@synthesize backgroundQueue;
@synthesize certificate;


static SingleTon *single=nil;
NSThread * nThread;

static BOOL isDone=NO;

static BOOL isBusy=NO;

//static BOOL disableNetworkDownNotification=NO;

+ (SingleTon *)getObject
{
    @synchronized(self)
    {
        if (single)
            return single;
        else
            return nil;
    }
}

+(SingleTon *)createSingletonObj{
    
    @synchronized(self)
    {
        if (!single)
        {
            // SNFileLogger *logger = [[SNFileLogger alloc] init];
            // [// [SNLog logManager] addLogStrategy:logger];
            // [SNLog Log:@"Method Name: %s Creating SingleTon Object with Network Init", __PRETTY_FUNCTION__];
            single = [[SingleTon alloc] init];
            //single->backgroundQueue=dispatch_queue_create("com.securifi.cloud", NULL);
            [single setDisableNetworkDownNotification:NO];
            [single setIsLoggedin:NO];
            [single setIsStreamConnected:NO];
            
            [single setSendCommandFail:NO];
            [single setConnectionState:SDK_UNINITIALIZED];
            
            [single initNetworkCommunication];
        }
    }
    //Don't return singleTon Object
    return single;
}

-(void)reconnect
{
    //@synchronized(self)
    //{
    // NSLog(@"State Reconnect %d",[single connectionState]);
    id ret=nil;
    unsigned int i=1;
    //[single setConnectionState:RECONNECT];
    if(isBusy == NO)
    {
        isBusy = YES;
        //self.disableNetworkDownNotification=YES;
        while (ret == nil && i<5)
        {
            
            ret = [self initReconnectSDK];
            //            if (ret == nil)
            //            {
            //                // [SNLog Log:@"Method Name: %s Thread - SDKInit Error", __PRETTY_FUNCTION__];
            ////                if (1 == i)
            ////                {
            ////                    // [SNLog Log:@"Method Name: %s Server not reachable", __PRETTY_FUNCTION__];
            ////                    [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
            ////                }
            //            }
            // [SNLog Log:@"Method Name: %s Thread - Sleeping for %d seconds", __PRETTY_FUNCTION__,i];
            sleep(i);
            i+=1;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkUp" object:self userInfo:nil];
        //self.disableNetworkDownNotification=NO;
        isBusy=NO;
    }
    // [SNLog Log:@"Method Name: %s Out of reconnect thread", __PRETTY_FUNCTION__];
    
    //}
    /*
     
     */
}



//-(void)reconnect
//{
//    //@synchronized(self)
//    //{
//    NSLog(@"State Reconnect %d",[single connectionState]);
//    id ret=nil;
//    unsigned int i=1;
//    //[single setConnectionState:RECONNECT];
//    if([single connectionState] == SDK_UNINITIALIZED)
//    {
//        isBusy = YES;
//        ret = [self initReconnectSDK];
//        //self.disableNetworkDownNotification=YES;
////        while (ret == nil && i<5)
////        {
////            
////            ret = [self initReconnectSDK];
////            //            if (ret == nil)
////            //            {
////            //                // [SNLog Log:@"Method Name: %s Thread - SDKInit Error", __PRETTY_FUNCTION__];
////            ////                if (1 == i)
////            ////                {
////            ////                    // [SNLog Log:@"Method Name: %s Server not reachable", __PRETTY_FUNCTION__];
////            ////                    [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
////            ////                }
////            //            }
////            // [SNLog Log:@"Method Name: %s Thread - Sleeping for %d seconds", __PRETTY_FUNCTION__,i];
////            sleep(i);
////            i+=1;
////        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkUp" object:self userInfo:nil];
//        //self.disableNetworkDownNotification=NO;
//        isBusy=NO;
//    }
//    // [SNLog Log:@"Method Name: %s Out of reconnect thread", __PRETTY_FUNCTION__];
//    
//    //}
//    /*
//     
//     */
//}

//-(id)initReconnectSDK
//{
//    NSLog(@"INIT Reconnect SDK");
//    
//    [SingleTon removeSingletonObject];
//    [SingleTon createSingletonObj];
//    
//    
//    
//    SingleTon *socket = [SingleTon getObject];
//    [socket setConnectionState:INITIALIZING];
//    
//    GenericCommand *sanityCommand = [[GenericCommand alloc] init];
//    sanityCommand.commandType=CLOUD_SANITY;
//    sanityCommand.command=nil;
//    
//    NSError *error;
//    id ret = nil;
//    ret = [SecurifiToolkit sendtoCloud:sanityCommand error:&error];
//    sanityCommand=nil;
//    
//    if (ret != nil)
//    {
//        NSLog(@"Method Name: %s SESSION STARTED TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
//        NSLog(@"initSDK - Send Sanity Successful");
//        //// [SNLog Log:@"Method Name: %s initSDK - Send Sanity Successful", __PRETTY_FUNCTION__];
//        //Send Temppass command
//        @try{
//            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//            if ([prefs objectForKey:PASSWORD] && [prefs objectForKey:USERID])
//            {
//                GenericCommand *cloudCommand = [[GenericCommand alloc] init];
//                LoginTempPass *loginCommand = [[LoginTempPass alloc] init];
//                
//                loginCommand.UserID =  [prefs objectForKey:USERID];
//                loginCommand.TempPass = [prefs objectForKey:PASSWORD];
//                
//                cloudCommand.commandType=LOGIN_TEMPPASS_COMMAND;
//                cloudCommand.command=loginCommand;
//                
//                NSError *error;
//                id ret = nil;
//                ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
//                if (ret != nil)
//                {
//                    NSLog(@"initSDK - Temp login sent");
//                    //// [SNLog Log:@"Method Name: %s initSDK - Temp login sent", __PRETTY_FUNCTION__];
//                    [socket setConnectionState:LOGGING];
//                    //return @"yes";
//                }
//                else
//                {
//                    NSLog(@"Error : %@",[error localizedDescription]);
//                    //// [SNLog Log:@"Method Name: %s Error : %@", __PRETTY_FUNCTION__,[error localizedDescription]];
//                    [socket setConnectionState:NETWORK_DOWN];
//                    //return nil;
//                }
//                cloudCommand=nil;
//                loginCommand=nil;
//            }
//            else
//            {
//                NSLog(@"TempPass not found in preferences");
//                //// [SNLog Log:@"Method Name: %s TempPass not found in preferences", __PRETTY_FUNCTION__];
//                //Send notification so that App can display Login / Password screen
//                [socket setConnectionState:NOT_LOGGED_IN];
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_ALL_NOTIFIER object:self userInfo:nil];
//                //return @"yes";
//            }
//        }
//        @catch (NSException *e) {
//            NSLog(@" Network Down %@", e.reason);
//            //// [SNLog Log:@"Method Name: %s Network Down %@", __PRETTY_FUNCTION__,e.reason];
//        }
//    }
//    else
//    {
//        //// [SNLog Log:@"Method Name: %s Error : %@", __PRETTY_FUNCTION__,[error localizedDescription]];
//        
//        [socket setConnectionState:NETWORK_DOWN];
//        //return nil;
//    }
//    
//    //4. Send temppass login command
//    //Now try to send Login Request using stored credentials
//    
//    
//    //For initSDK
//    
//    
//    return @"Yes";
//    
//    //Send tempPass Command to check existing login
//    //Send SANITY_COMMAND TO chekc cloud connectivity and insturct main app that you are
//    //connected to cloud
//    
//    //3 Register Reachability callback
//    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
//    
//    //Change the host name here to change the server your monitoring
//    //remoteHostLabel.text = [NSString stringWithFormat: @"Remote Host: %@", @"www.apple.com"];
//	/*
//     hostReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
//     [hostReach startNotifier];
//     */
//    
//    //return @"yes";
//}


-(id)initReconnectSDK{
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

    sanityCommand.commandType=CLOUD_SANITY;
    sanityCommand.command=nil;

    NSError *error;
    id ret = nil;
    ret = [SecurifiToolkit sendtoCloud:sanityCommand error:&error];
    if (ret != nil)
    {
        // NSLog(@"Reconnect initSDK - Send Sanity Successful");

        //Notify main app
        [single setConnectionState:SDK_UNINITIALIZED];
        return @"Yes";
    }
    else
    {
        // NSLog(@"Reconnect Error : %@",[error localizedDescription]);
        return nil;
        //Dont notify User about network down unless it has been asked
        //Only notify once its back on internet

        //[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];
    }
    sanityCommand=nil;
}

//+(id)initSDK
//{
//    [SingleTon removeSingletonObject];
//    [SingleTon createSingletonObj];
//
//    if(!bgQueue){
//        bgQueue = dispatch_queue_create("command_queue", NULL);
//    }
//
//    //    SNFileLogger *logger = [[SNFileLogger alloc] init];
//    //    [// [SNLog logManager] addLogStrategy:logger];
//
//    //Start a Async task of sending Sanity command and TempPassCommand and return YES
//    //Asynch task will send command and will generate respective events
//
//    dispatch_async(bgQueue, ^(void) {
//
//        SingleTon *socket = [SingleTon getObject];
//
//        GenericCommand *sanityCommand = [[GenericCommand alloc] init];
//        sanityCommand.commandType=CLOUD_SANITY;
//        sanityCommand.command=nil;
//
//        NSError *error;
//        id ret = nil;
//        ret = [SecurifiToolkit sendtoCloud:sanityCommand error:&error];
//        sanityCommand=nil;
//
//        if (ret != nil)
//        {
//            // [SNLog Log:@"Method Name: %s initSDK - Send Sanity Successful", __PRETTY_FUNCTION__];
//            //Send Temppass command
//            @try{
//                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                if ([prefs objectForKey:tmpPwdKey] && [prefs objectForKey:usrIDKey])
//                {
//                    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
//                    LoginTempPass *loginCommand = [[LoginTempPass alloc] init];
//
//                    loginCommand.UserID =  [prefs objectForKey:usrIDKey];
//                    loginCommand.TempPass = [prefs objectForKey:tmpPwdKey];
//
//                    cloudCommand.commandType=LOGIN_TEMPPASS_COMMAND;
//                    cloudCommand.command=loginCommand;
//
//                    NSError *error;
//                    id ret = nil;
//                    ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
//                    if (ret != nil)
//                    {
//                        // [SNLog Log:@"Method Name: %s initSDK - Temp login sent", __PRETTY_FUNCTION__];
//                        //return @"yes";
//                    }
//                    else
//                    {
//                        // [SNLog Log:@"Method Name: %s Error : %@", __PRETTY_FUNCTION__,[error localizedDescription]];
//                        [socket setConnectionState:NETWORK_DOWN];
//                        //return nil;
//                    }
//                    cloudCommand=nil;
//                    loginCommand=nil;
//                }
//                else
//                {
//                    // [SNLog Log:@"Method Name: %s TempPass not found in preferences", __PRETTY_FUNCTION__];
//                    //Send notification so that App can display Login / Password screen
//                    [socket setConnectionState:NOT_LOGGED_IN];
//
//                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFIER object:self userInfo:nil];
//                    //return @"yes";
//                }
//            }
//            @catch (NSException *e) {
//                // [SNLog Log:@"Method Name: %s Network Down %@", __PRETTY_FUNCTION__,e.reason];
//            }
//        }
//        else
//        {
//            // [SNLog Log:@"Method Name: %s Error : %@", __PRETTY_FUNCTION__,[error localizedDescription]];
//
//            [socket setConnectionState:NETWORK_DOWN];
//            //return nil;
//        }
//    });
//    //4. Send temppass login command
//    //Now try to send Login Request using stored credentials
//
//
//    //For initSDK
//
//
//    return @"Yes";
//
//    //Send tempPass Command to check existing login
//    //Send SANITY_COMMAND TO chekc cloud connectivity and insturct main app that you are
//    //connected to cloud
//
//    //3 Register Reachability callback
//    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
//
//    //Change the host name here to change the server your monitoring
//    //remoteHostLabel.text = [NSString stringWithFormat: @"Remote Host: %@", @"www.apple.com"];
//	/*
//     hostReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
//     [hostReach startNotifier];
//     */
//
//    //return @"yes";
//}


+(void) removeSingletonObject
{
    @synchronized(self)
    {
        if(single){
            [single.outputStream close];
            [single.inputStream close];
            
            [single.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [single.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            single.outputStream=nil;
            single.inputStream=nil;
            single=nil;
        }
    }
}

- (NSThread *)networkThread {
    nThread = nil;
    
    nThread =
    [[NSThread alloc] initWithTarget:self
                            selector:@selector(networkThreadMain:)
                              object:nil];
    [nThread start];
    
    // [SNLog Log:@"Method Name: %s thread: %@, debug description: %@", __PRETTY_FUNCTION__, nThread, nThread.debugDescription];
    return nThread;
}

- (void)networkThreadMain:(id)unused {
    do {
        //// NSLog(@"Thread runloop");
        
        if ([[NSThread currentThread] isCancelled] == YES)
        {
            // [SNLog Log:@"Method Name: %s Exiting current thread", __PRETTY_FUNCTION__];
            [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [NSThread exit];
        }
        [[NSRunLoop currentRunLoop] run];
    } while (YES);
}

- (void)scheduleInCurrentThread:(id)unused
{
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSRunLoopCommonModes];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSRunLoopCommonModes];
    [inputStream open];
    [outputStream open];
}

-(void) initNetworkCommunication{
    
    if(!self.backgroundQueue){
        self.backgroundQueue = dispatch_queue_create("connection_queue", NULL);
    }
    
    dispatch_async(self.backgroundQueue, ^(void) {
        
        if(self.inputStream ==nil && self.outputStream ==nil) {
            CFReadStreamRef readStream;
            CFWriteStreamRef writeStream;
            //ashutosh: ec2-54-226-113-110.compute-1.amazonaws.com
            //PY080813 Change to ashutosh
            //CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"ec2-54-226-114-39.compute-1.amazonaws.com", 1028, &readStream, &writeStream);
            NSString *cloudServer = CLOUD_SERVER;
            CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)CFBridgingRetain(cloudServer), 1028, &readStream, &writeStream);
            //Migrating to nodeLB
            //CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"nodeLB-1553508487.us-east-1.elb.amazonaws.com", 1028, &readStream, &writeStream);
            
            //Add certificate
            NSString *path = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"der"];
            NSData *certData = [NSData dataWithContentsOfFile:path];
            certificate = SecCertificateCreateWithData(NULL,(__bridge CFDataRef)certData);
            
            //            // NSLog(@"Certificate Data: %@", certificateData);
            //            // Import .p12 data
            //            CFArrayRef keyref = NULL;
            //
            //            // Identity
            //            CFDictionaryRef identityDict = CFArrayGetValueAtIndex(keyref, 0);
            //            SecIdentityRef identityRef = (SecIdentityRef)CFDictionaryGetValue(identityDict,
            //                                                                              kSecImportItemIdentity);
            //            SecCertificateRef   cert;
            // Cert
            //            SecCertificateRef   cert;
            //            //CFDataRef cfdata = CFDataCreate(NULL, [certificateData bytes], [certificateData length]);
            //            if( [certData length] ) {
            //                cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
            //                if( cert != NULL ) {
            //                    CFStringRef certSummary = SecCertificateCopySubjectSummary(cert);
            //                    NSString* summaryString = [[NSString alloc] initWithString:(__bridge NSString*)certSummary];
            //                    // NSLog(@"CERT SUMMARY: %@", summaryString);
            //                    CFRelease(certSummary);
            //                } else {
            //                    // NSLog(@" *** ERROR *** trying to create the SSL certificate from data located at %@, but failed", path);
            //                }
            //            }
            //
            //            // the certificates array, containing the identity then the root certificate
            //            NSArray *sslCerts = [[NSArray alloc] initWithObjects:(__bridge id)cert, nil];
            //            // NSLog(@"sslCerts Size %d", sslCerts);
            //
            
            inputStream = (__bridge NSInputStream *)readStream;
            outputStream = (__bridge NSOutputStream *)writeStream;
            
            [inputStream setDelegate:self];
            [outputStream setDelegate:self];
            
            [inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
                              forKey:NSStreamSocketSecurityLevelKey];
            [outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
                               forKey:NSStreamSocketSecurityLevelKey];
            
            //[SSLOptions setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsExpiredRoots];
            //[SSLOptions setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsExpiredCertificates];
            //[SSLOptions setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
            //[SSLOptions setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
            //[SSLOptions setObject:@"test.domain.com:443" forKey:(NSString *)kCFStreamSSLPeerName];
            //[SSLOptions setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString*)kCFStreamSSLLevel];
            //[SSLOptions setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL forKey:(NSString*)kCFStreamPropertySocketSecurityLevel];
            //[SSLOptions setObject:myCerts forKey:(NSString *)kCFStreamSSLCertificates];
            //[SSLOptions setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLIsServer];
            
            NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithBool:NO], kCFStreamSSLAllowsExpiredRoots,
                                      [NSNumber numberWithBool:NO], kCFStreamSSLAllowsExpiredCertificates,
                                      [NSNumber numberWithBool:NO], kCFStreamSSLAllowsAnyRoot,
                                      [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
                                      //@"*.securifi.com",kCFStreamSSLPeerName,
                                      nil];
            
            //            sslCerts , kCFStreamSSLCertificates,
            //            [NSNumber numberWithBool:NO], kCFStreamSSLIsServer,
            
            
            CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
            CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
            
            [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                   forMode:NSRunLoopCommonModes];
            [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSRunLoopCommonModes];
            [inputStream open];
            [outputStream open];
            
            /*
             [self performSelector:@selector(scheduleInCurrentThread:)
             onThread:[self networkThread]
             withObject:nil
             waitUntilDone:YES];
             */
            
            [self setIsStreamConnected:YES];
            
            // [SNLog Log:@"Method Name: %s *****Stream opened from dispatch queue", __PRETTY_FUNCTION__];
            
            NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
            
            while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && (self.isStreamConnected == YES) && (isDone == NO))
            {
                //// NSLog(@"Run loop did run");
            }
            //// NSLog(@"Run loop exitted");
        }
        else{
            //// NSLog(@"Stream already opened");
        }
        
        // [SNLog Log:@"Method Name: %s Terminating Async task", __PRETTY_FUNCTION__];
        isDone=NO;
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
			if (theStream == inputStream) {
				while ([inputStream hasBytesAvailable]) {
                    uint8_t inputBuffer[4096];
                    int len;
                    
                    //Multiple entry in one callback possible
					len = [inputStream read:inputBuffer maxLength:sizeof(inputBuffer)];
					if (len > 0) {
                        
                        //[SNLog Log:@"Method Name: %s Response Length : %d",__PRETTY_FUNCTION__,len];
                        //If current stream has </root>
                        //1. Get NSRange and prepare command
                        //2. If command has parital command add it to mutableData object
                        //3. It mutable object has some data append new received Data to it
                        //4. repeat this procedure for newly created mutableData
                        
                        //Append received data to paritial buffer
                        [partialData appendBytes:&inputBuffer[0] length:len];
                        
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
                                        case LOGIN_RESPONSE:
                                        {
                                            LoginResponse *obj = (LoginResponse *)temp.command;
                                            //// NSLog(@"Singleton User ID : %@",[obj userID]);
                                            //// NSLog(@"Singleton TempPass : %@", [obj tempPass]);
                                            //// NSLog(@"Singleton isSuccessful : %d",[obj isSuccessful]);
                                            //// NSLog(@"Singleton Reason : %@",[obj reason]);
                                            
                                            if (obj.isSuccessful == YES)
                                            {
                                                //Set the indicator that we are logged in to prevent next login from User
                                                isLoggedin = YES;
                                                
                                                [self setConnectionState:LOGGED_IN];
                                                
                                                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                                NSString *tempPass = obj.tempPass;
                                                NSString *userID = obj.userID;
                                                [prefs setObject:tempPass  forKey:PASSWORD];
                                                [prefs setObject:userID forKey:USERID];
                                                [prefs synchronize];
                                            }
                                            else{
                                                [self setConnectionState:NOT_LOGGED_IN];
                                            }
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            //Send Object
                                            //// NSLog(@"Before Pused Notification");
                                            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTIFIER object:self userInfo:data];
                                            
                                            //// NSLog(@"After Pushed Notification");
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        case SIGNUP_RESPONSE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received Signup Response", __PRETTY_FUNCTION__];;
                                            SignupResponse *obj = (SignupResponse *)temp.command;
                                            
                                            // [SNLog Log:@"Method Name: %s Signup isSuccessful %d", __PRETTY_FUNCTION__, obj.isSuccessful];
                                            // [SNLog Log:@"Method Name: %s Signup Reason %@", __PRETTY_FUNCTION__,obj.Reason];
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:SIGN_UP_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        case KEEP_ALIVE:
                                            // [SNLog Log:@"Method Name: %s Received keepalive command", __PRETTY_FUNCTION__];
                                            tempObj=nil;
                                            temp=nil;
                                            break;
                                        case CLOUD_SANITY_RESPONSE:
                                        {
                                            //SanityResponse *obj = (SanityResponse *)temp.command;
                                            //// NSLog(@"Singleton Response : %@",[obj reason]);
                                            
                                            //Instruct Main App that cloud is reachable
                                            [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_UP_NOTIFIER object:self userInfo:nil];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            //PY 250214 - Logout Response
                                        case LOGOUT_RESPONSE:
                                        {
                                            LogoutResponse *obj = (LogoutResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                            break;
                                        }
                                            //PY 250214 - Logout All Response
                                        case LOGOUT_ALL_RESPONSE:
                                        {
                                            LogoutAllResponse *obj = (LogoutAllResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_ALL_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                            break;
                                        }
                                        case AFFILIATION_USER_COMPLETE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received Affiliation User Complete", __PRETTY_FUNCTION__];
                                            AffiliationUserComplete *obj = (AffiliationUserComplete *)temp.command;
                                            
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:AFFILIATION_COMPLETE_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
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
                                        case ALMOND_LIST_RESPONSE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received Almond List Response", __PRETTY_FUNCTION__];
                                            AlmondListResponse *obj = (AlmondListResponse *)temp.command;
                                            
                                            
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:ALMOND_LIST_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            //PY 170913 - Device Data Hash Response
                                        case DEVICEDATA_HASH_RESPONSE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received Device Data Hash Response", __PRETTY_FUNCTION__];
                                            DeviceDataHashResponse *obj = (DeviceDataHashResponse *)temp.command;
                                            
                                            // [SNLog Log:@"Method Name: %s Hash Success %d",__PRETTY_FUNCTION__, (int)obj.isSuccessful];
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:HASH_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            //PY 170913 - Device Data  Response
                                        case DEVICEDATA_RESPONSE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received Device Data Response", __PRETTY_FUNCTION__];
                                            DeviceListResponse *obj = (DeviceListResponse *)temp.command;
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_DATA_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            //PY 170913 - Device Data  Response
                                        case DEVICE_VALUE_LIST_RESPONSE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received Device Value Mobile Response", __PRETTY_FUNCTION__];
                                            DeviceValueResponse *obj = (DeviceValueResponse *)temp.command;
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_VALUE_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            //PY 200913 - Mobile Command Response
                                        case MOBILE_COMMAND_RESPONSE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received Mobile Command Response", __PRETTY_FUNCTION__];
                                            MobileCommandResponse *obj = (MobileCommandResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:MOBILE_COMMAND_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            //PY 230913 - Device List Command - 81 -  Response
                                        case DYNAMIC_DEVICE_DATA:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received DYNAMIC_DEVICE_DATA", __PRETTY_FUNCTION__];
                                            DeviceListResponse *obj = (DeviceListResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_DATA_CLOUD_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            
                                            //PY 230913 - Device Value Command - 82 -  Response
                                        case DYNAMIC_DEVICE_VALUE_LIST:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received DEVICE_VALUE_LIST_RESPONSE", __PRETTY_FUNCTION__];
                                            DeviceValueResponse *obj = (DeviceValueResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_VALUE_CLOUD_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            //PY 291013 - Generic Command Response
                                        case GENERIC_COMMAND_RESPONSE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received Generic Command Response", __PRETTY_FUNCTION__];
                                            GenericCommandResponse *obj = (GenericCommandResponse *)temp.command;
                                            
                                            //Decode using Base64
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            //                                            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                                            obj.decodedData = decodedData;
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_COMMAND_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            //PY 301013 - Generic Command Notification
                                        case GENERIC_COMMAND_NOTIFICATION:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received Generic Command Notification", __PRETTY_FUNCTION__];
                                            GenericCommandResponse *obj = (GenericCommandResponse *)temp.command;
                                            
                                            //Decode using Base64
                                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:obj.genericData options:0];
                                            //                                            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                                            obj.decodedData = decodedData;
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:GENERIC_COMMAND_CLOUD_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                            //PY 011113 - Validate Account Response
                                        case VALIDATE_RESPONSE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received VALIDATE_RESPONSE", __PRETTY_FUNCTION__];
                                            ValidateAccountResponse *obj = (ValidateAccountResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:VALIDATE_RESPONSE_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        case RESET_PASSWORD_RESPONSE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received RESET_PASSWORD_RESPONSE", __PRETTY_FUNCTION__];
                                            ResetPasswordResponse *obj = (ResetPasswordResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:RESET_PWD_RESPONSE_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        case DYNAMIC_ALMOND_ADD:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received DYNAMIC_ALMOND_ADD", __PRETTY_FUNCTION__];
                                            AlmondListResponse *obj = (AlmondListResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        case DYNAMIC_ALMOND_DELETE:
                                        {
                                            // [SNLog Log:@"Method Name: %s Received DYNAMIC_ALMOND_DELETE", __PRETTY_FUNCTION__];
                                            AlmondListResponse *obj = (AlmondListResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        case SENSOR_CHANGE_RESPONSE:
                                        {
                                            //[SNLog Log:@"Method Name: %s Received SENSOR_CHANGE_RESPONSE", __PRETTY_FUNCTION__];
                                            SensorChangeResponse *obj = (SensorChangeResponse *)temp.command;
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:SENSOR_CHANGE_NOTIFIER object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
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
            
            if (theStream == outputStream)
            {
                // [SNLog Log:@"Method Name: %s Connection event: server down", __PRETTY_FUNCTION__];
                isDone=YES;
                
                [theStream close];
                [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                theStream = nil;
                
                [inputStream close];
                [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                inputStream=nil;
                
                //Instruct SingleTon object
                isLoggedin=NO;
                [self setConnectionState:NETWORK_DOWN];
                
                //PY301013 - Reconnect
                [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
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
        case NSStreamEventHasSpaceAvailable:
            // NSLog(@"Inside NSStreamEventHasSpaceAvailable");
        {
            SecPolicyRef policy= SecPolicyCreateSSL(NO, CFSTR("*.securifi.com"));
            SecTrustRef trust = NULL;
            //CFArrayRef streamCertificates = (__bridge CFArrayRef)([theStream propertyForKey:(NSString *) kCFStreamPropertySSLPeerCertificates]);
            // NSLog(@"After kCFStreamPropertySSLPeerCertificates");
            SecCertificateRef certs[1] = { self.certificate };
            CFArrayRef array = CFArrayCreate(NULL, (const void **) certs, 1, NULL);
            SecTrustCreateWithCertificates(array, policy, &trust);
            // NSLog(@"After SecTrustCreateWithCertificates");
            SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)([NSArray arrayWithObject:(id)self.certificate]));
            // NSLog(@"After SecTrustSetAnchorCertificates");
            
            SecTrustResultType trustResultType = kSecTrustResultInvalid;
            OSStatus status = SecTrustEvaluate(trust, &trustResultType);
            if (status == errSecSuccess) {
                // expect trustResultType == kSecTrustResultUnspecified
                // until my cert exists in the keychain see technote for more detail.
                if (trustResultType == kSecTrustResultUnspecified) {
                    // NSLog(@"We can trust this certificate! TrustResultType: %d", trustResultType);
                } else {
                    // NSLog(@"Cannot trust certificate. TrustResultType: %d", trustResultType);
                }
            } else {
                // NSLog(@"Creating trust failed: %d", status);
                [theStream close];
            }
            if (trust) {
                CFRelease(trust);
            }
            if (policy) {
                CFRelease(policy);
            }
        }
            break;
            
            
		case NSStreamEventEndEncountered:
            if (theStream == inputStream)
            {
                NSLog(@"Method Name: %s SESSION ENDED CONNECTION BROKEN TIME => %f", __PRETTY_FUNCTION__, CFAbsoluteTimeGetCurrent());
                
                //PY 160913 - Logout All Notifier - PY 250214 - Logout All should happen after user tries to reconnect and fails
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"LogoutAllResponseNotifier" object:self userInfo:NULL];
                
                // [SNLog Log:@"Method Name: %s Cloud Server Closed the Connection", __PRETTY_FUNCTION__];
                //[nThread cancel];
                [theStream close];
                [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                theStream = nil;
                
                [outputStream close];
                [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                outputStream=nil;
                
                isDone = YES;
                // [SNLog Log:@"Method Name: %s Dispatch EndEncountered Notification -- TCP DOWN", __PRETTY_FUNCTION__];
                
                isLoggedin=NO;
                [self setConnectionState:CLOUD_CONNECTION_ENDED];
                
                
                //User APP should not handle reconnection
                //Dispatch thread
                //[SingleTon reconnect];
                
                //PY301013 - Reconnect
                [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DOWN_NOTIFIER object:self userInfo:nil];
                dispatch_async(backgroundQueue, ^ {
                    
                    [NSThread detachNewThreadSelector:@selector(reconnect) toTarget:self withObject:nil];
                });

                
            }
            break;
            
            //default:
			//[SNLog Log:@"Method Name: %s Unknown event", __PRETTY_FUNCTION__];
	}
    
}
@end

