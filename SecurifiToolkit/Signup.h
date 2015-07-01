//
//  Signup.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/31/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface Signup : NSObject <SecurifiCommand>
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *UserID;
@property(nonatomic, copy) NSString *Password;
@property(nonatomic, copy) NSString *Reason;

- (NSString *)toXml;

@end
