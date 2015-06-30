//
//  Login.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/16/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface Login : NSObject <SecurifiCommand>
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *UserID;
@property(nonatomic, copy) NSString *Password;

- (NSString *)toXml;

@end
