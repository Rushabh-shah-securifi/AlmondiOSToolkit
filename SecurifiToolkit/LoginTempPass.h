//
//  LoginTempPass.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/16/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface LoginTempPass : NSObject <SecurifiCommand>
@property NSString *UserID;
@property NSString *TempPass;

- (NSString *)toXml;

@end
