//
//  HTTPRequest.h
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//



#ifndef HTTPRequest_h
#define HTTPRequest_h

#import <Foundation/Foundation.h>
#import "SecurifiToolkit.h"

#endif /* HTTPRequest_h */

@protocol HTTPDelegate <NSObject>

- (void) HTTPResponseReceived: (LoginResponse*) response;

@end

@interface HTTPRequest : NSObject

@property (nonatomic,weak) id<HTTPDelegate> delegate;

-(void)sendAsyncHTTPLoginRequestWithEmail:(NSString*)email AndPassword:(NSString*)password;

-(void) sendAsyncHTTPSignUPRequestWithEmail:(NSString*)email AndPassword:(NSString*)password;

-(void) sendAsyncHTTPResetPasswordRequest: (NSString*)emailID;

-(void) sendAsyncHTTPRequestResendActivationLink: (NSString*)emailID;

@end
