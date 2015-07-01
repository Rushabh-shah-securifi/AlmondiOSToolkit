//
//  LoginTempPass.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/16/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface LoginTempPass : NSObject <SecurifiCommand>
@property(nonatomic, copy) NSString *UserID;
@property(nonatomic, copy) NSString *TempPass;

- (NSString *)toXml;

@end
