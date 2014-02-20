//
//  SingleTon.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//


NSString *const tempPasswordKey = @"tempPasswordPrefKey";
NSString *const userIDKey = @"userIDPrefKey";

#import "SingleTon.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
//#import <SecurifiToolkit/LoginResponse.h>
#import "GenericCommand.h"
#import "Commandparser.h"
#import "PrivateCommandTypes.h"

//Schedule runloop on backgroundQueue

#define SDK_UNINITIALIZED   0
#define NETOWORK_DOWN   1
#define NOT_LOGGED_IN   2
#define LOGGED_IN       3

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
            NSLog(@"Creating SingleTon Object with Network Init");
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
    id ret=nil;
    unsigned int i=1;
    
    if(isBusy == NO)
    {
        isBusy = YES;
        self.disableNetworkDownNotification=YES;
        while (ret == nil && i<10)
        {
            NSLog(@"From Thread");
            ret = [SecurifiToolkit initSDK];
            if (ret == nil)
            {
                NSLog(@"Thread - SDKInit Error");
                if (1 == i)
                {
                    NSLog(@"Server not reachable");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];
                }
            }
        NSLog(@"Thread - Sleeping for %d seconds",i);
        sleep(i);
        i+=1;
        }
        self.disableNetworkDownNotification=NO;
        isBusy=NO;
    }
    NSLog(@"Out of reconnect thread");
    
    //}
    /*
    NSLog(@"In Reconnect");
    [SingleTon removeSingletonObject];
    [SingleTon createSingletonObj];
    
    //Send Sanity Command
    GenericCommand *sanityCommand = [[GenericCommand alloc] init];
    
    sanityCommand.commandType=CLOUD_SANITY;
    sanityCommand.command=nil;
    
    NSError *error;
    id ret = nil;
    ret = [SecurifiToolkit sendtoCloud:sanityCommand error:&error];
    if (ret != nil)
    {
        NSLog(@"initSDK - Send Sanity Successful");
        //Notify main app
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkUp" object:self userInfo:nil];
    }
    else
    {
        NSLog(@"Error : %@",[error localizedDescription]);
        //Dont notify User about network down unless it has been asked
        //Only notify once its back on internet
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];
    }
    sanityCommand=nil;
     */
}

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
    
    NSLog(@"thread: %@, debug description: %@", nThread, nThread.debugDescription);
    return nThread;
}

- (void)networkThreadMain:(id)unused {
    do {
        //NSLog(@"Thread runloop");
        
        if ([[NSThread currentThread] isCancelled] == YES)
        {
            NSLog(@"Exiting current thread");
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
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"ec2-54-226-113-110.compute-1.amazonaws.com", 1028, &readStream, &writeStream);
    //Migrating to nodeLB
    //CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"nodeLB-1553508487.us-east-1.elb.amazonaws.com", 1028, &readStream, &writeStream);
    
        
    inputStream = (__bridge NSInputStream *)readStream;
	outputStream = (__bridge NSOutputStream *)writeStream;
    
	[inputStream setDelegate:self];
	[outputStream setDelegate:self];    
    
    [inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
                      forKey:NSStreamSocketSecurityLevelKey];
    [outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
                       forKey:NSStreamSocketSecurityLevelKey];
    
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
                              [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
                              [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
                              kCFNull,kCFStreamSSLPeerName,
                              nil];
    
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

    NSLog(@"*****Stream opened from dispatch queue");
    
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        
    while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && (self.isStreamConnected == YES) && (isDone == NO))
    {
        //NSLog(@"Run loop did run");
    }
        //NSLog(@"Run loop exitted");
    }
    else{
        //NSLog(@"Stream already opened");
    }
        
    NSLog(@"Terminating Async task");
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
    
	//NSLog(@"stream event %i", streamEvent);
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
                //NSLog(@"Stream Status : %d",type);
                NSLog(@"Dispatch OpenCompleted Notification -- TCP UP");
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
						NSLog(@"Length : %d",len);
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
                                //NSLog(@"endTag Location: %i, Length: %i",endTagRange.location,endTagRange.length);
                                
                                //Look for <root> tag in [0 to endTag]
                                NSRange startTagRange = NSMakeRange(0, endTagRange.location);
                                
                                startTagRange = [partialData rangeOfData:startTag options:0 range:startTagRange];
                                
                                if(startTagRange.location == NSNotFound)
                                {
                                    NSLog(@"Seriouse error !!! should not come heer // Invalid command /// without startRootTag");
                                }
                                else 
                                {
                                    //NSLog(@"startTag Location: %i, Length: %i",startTagRange.location,startTagRange.length);
                                    //Prepare Command
                                    [partialData getBytes:&expectedLength range:NSMakeRange(0, 4)];
                                    NSLog(@"Expected Length: %d",NSSwapBigIntToHost(expectedLength));
                                    
                                    [partialData getBytes:&command range:NSMakeRange(4,4)];
                                    NSLog(@"Command: %d",NSSwapBigIntToHost(command));
                                    
                                    CommandParser *tempObj = [[CommandParser alloc] init];
                                    
                                    //Send single command data to parseXML rather than complete buffer
                                    NSRange xmlParser = {startTagRange.location, (endTagRange.location+endTagRange.length - 8)};
                                    
                                    NSData *buffer = [partialData subdataWithRange:xmlParser];
                                    
                                    GenericCommand *temp = (GenericCommand *)[tempObj parseXML:buffer];
                                    
                                    //Remove 8 bytes from received command
                                    [partialData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

                                    //NSLog(@"Parsed Command: %d", temp.commandType);
                                    
                                    switch (temp.commandType) {
                                        case LOGIN_RESPONSE:
                                        {
                                            LoginResponse *obj = (LoginResponse *)temp.command;
                                            //NSLog(@"Singleton User ID : %@",[obj userID]);
                                            //NSLog(@"Singleton TempPass : %@", [obj tempPass]);
                                            //NSLog(@"Singleton isSuccessful : %d",[obj isSuccessful]);
                                            //NSLog(@"Singleton Reason : %@",[obj reason]);
                                            
                                            if (obj.isSuccessful == YES)
                                            {
                                                //Set the indicator that we are logged in to prevent next login from User
                                                isLoggedin = YES;
                                                
                                                [self setConnectionState:LOGGED_IN];
                                                
                                                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                                NSString *tempPass = obj.tempPass;
                                                NSString *userID = obj.userID;
                                                [prefs setObject:tempPass  forKey:tempPasswordKey];
                                                [prefs setObject:userID forKey:userIDKey];
                                                [prefs synchronize];
                                            }
                                            else{
                                                [self setConnectionState:NOT_LOGGED_IN];
                                            }
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            //Send Object
                                            //NSLog(@"Before Pused Notification");
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponse" object:self userInfo:data];
                                            
                                            //NSLog(@"After Pused Notification");
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        case SIGNUP_RESPONSE:
                                        {
                                            NSLog(@"Received Signup Response");
                                            SignupResponse *obj = (SignupResponse *)temp.command;
                                            
                                            NSLog(@"Signup isSuccessful %d", obj.isSuccessful);
                                            NSLog(@"Signup Reason %@",obj.Reason);
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"SignupResponseNotifier" object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        case KEEP_ALIVE:
                                            NSLog(@"Received keepalive command");
                                            tempObj=nil;
                                            temp=nil;
                                            break;
                                        case CLOUD_SANITY_RESPONSE:
                                        {
                                            //SanityResponse *obj = (SanityResponse *)temp.command;
                                            //NSLog(@"Singleton Response : %@",[obj reason]);
                                            
                                            //Instruct Main App that cloud is reachable
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkUP" object:self userInfo:nil];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        
                                        case AFFILIATION_USER_COMPLETE:
                                        {
                                            NSLog(@"Received Affiliation User Complete");
                                            AffiliationUserComplete *obj = (AffiliationUserComplete *)temp.command;
                                            
                                            NSLog(@"Affiliation AlmondMAC %@", obj.almondplusMAC);
                                            NSLog(@"Affiliation AlmondName %@",obj.almondplusName);
                                            
                                            NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"AffiliationUserCompleteNotifier" object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                            break;
                                        case AFFILIATION_CODE_RESPONSE:
                                        {
                                            NSLog(@"Received Affiliation Code");
                                            AffiliationUserResponse *obj = (AffiliationUserResponse *)temp.command;
                                            
                                            NSLog(@"Affiliation Code %@", obj.Code);
                                            NSLog(@"UserID %@",obj.UserID);
                                            
                                              NSDictionary *data = [NSDictionary dictionaryWithObject:obj forKey:@"data"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"AffiliationUserResponseNotifier" object:self userInfo:data];
                                            tempObj=nil;
                                            temp=nil;
                                        }
                                        default:
                                            break;
                                    }
                                    if (temp.commandType == LOGIN_RESPONSE)
                                    {
                                    
                                    }
                                    /* MIGRATING TO iOS SDK
                                     if (NSSwapBigIntToHost(command) == 2)
                                     {
                                     NSLog(@"Inside command == 2");
                                     //Create Notification and send it
                                     NSString *output = [[NSString alloc] initWithData:partialData encoding:NSUTF8StringEncoding];
                                     
                                     if (nil != output) {
                                     NSLog(@"server said: %@", output);
                                     //[self messageReceived:output];
                                     //send local notification to update view
                                     NSDictionary *data = [NSDictionary dictionaryWithObject:output forKey:@"data"];
                                     
                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponse" object:self userInfo:data];
                                     
                                     //[[NSNotificationCenter defaultCenter] postNotificationName:@"tempPassLogingRes" object:self userInfo:data];
                                     }
                                     }
                                     
                                     if ((NSSwapBigIntToHost(command) == 24) || (NSSwapBigIntToHost(command) == 26))
                                     {
                                     NSLog(@"Inside command == %d",NSSwapBigIntToHost(command));
                                     //Create Notification and send it
                                     NSString *output = [[NSString alloc] initWithData:partialData encoding:NSUTF8StringEncoding];
                                     
                                     if (nil != output) {
                                     NSLog(@"server said: %@", output);
                                     //[self messageReceived:output];
                                     //send local notification to update view
                                     NSDictionary *data = [NSDictionary dictionaryWithObject:output forKey:@"data"];
                                     
                                     //[[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponse" object:self userInfo:data];
                                     }
                                     }
                                     */
                                    
                                    //NSLog(@"Partial Buffer before trim : %@",partialData);
                                    
                                    //Trim Partial Buffer
                                    //This will trim parital buffer till </root>
                                    [partialData replaceBytesInRange:NSMakeRange(0, endTagRange.location+endTagRange.length - 8 /* Removed 8 bytes before */) withBytes:NULL length:0];
                                    
                                    //Regenerate NSRange
                                    endTagRange = NSMakeRange(0, [partialData length]);
                                    
                                    //NSLog(@"Partial Buffer after trim : %@",partialData);
                                }
                                count++;
                            }
                            else
                            {
                                NSLog(@"Number of Command Processed  : %d",count);
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
                NSLog(@"Connection event: server down");
                isDone=YES;
                
                [theStream close];
                [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                theStream = nil;
                
                [inputStream close];
                [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                inputStream=nil;
                
                //Instruct SingleTon object
                isLoggedin=NO;
                [self setConnectionState:NETOWORK_DOWN];
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];
                
                //TEST --- Remove it later
                //NSLog(@"Dispatch ErrorOccurred Notification -- TCP DOWN");
                
                //Some how we should know that this is comming from thread or main thread
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];
                
                //User APP should not handle reconnection
                //Dispatch thread
                //[SingleTon reconnect];
                
                //Testing with reachability
                
                /*
                if ([[SingleTon getObject] disableNetworkDownNotification] == NO) //Implies not in thread
                {
                    NSLog(@"Launching thread from errorEvent handler");
                    //First Write of initSDK will throw NetworkDOWN notification
                    //dispatch_async(backgroundQueue, ^ {
                    
                    [NSThread detachNewThreadSelector:@selector(reconnect) toTarget:self withObject:nil];
                    
                    //[self reconnect];
                    //});
                }
                */
            }
            break;
			
		case NSStreamEventEndEncountered:
            if (theStream == inputStream)
            {
                NSLog(@"Cloud Server Closed the Connection");
                //[nThread cancel];
                [theStream close];
                [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                theStream = nil;
             
                [outputStream close];
                [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                outputStream=nil;
                
                isDone = YES;
                NSLog(@"Dispatch EndEncountered Notification -- TCP DOWN");
                
                //Instruct SingleTon object
                isLoggedin=NO;
                [self setConnectionState:NETOWORK_DOWN];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkDOWN" object:self userInfo:nil];
                //User APP should not handle reconnection
                //Dispatch thread
                //[SingleTon reconnect];
                //dispatch_async(backgroundQueue, ^ {
                
                //[NSThread detachNewThreadSelector:@selector(reconnect) toTarget:self withObject:nil];
                
                //[self reconnect];
                //});
            }
            break;
            
		default:
			NSLog(@"Unknown event");
	}
    
}
@end

