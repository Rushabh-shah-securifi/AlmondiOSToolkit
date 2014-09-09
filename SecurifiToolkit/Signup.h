//
//  Signup.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface Signup : NSObject <SecurifiCommand>
@property BOOL isSuccessful;
@property NSString *UserID;
@property NSString *Password;
@property NSString *Reason;

- (NSString*)toXml;

@end
