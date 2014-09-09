//
//  LogoutAllRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface LogoutAllRequest : NSObject <SecurifiCommand>
@property BOOL isSuccessful;
@property NSString *UserID;
@property NSString *Password;
@property NSString *Reason;

- (NSString *)toXml;

@end
