//
//  LogoutAllRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface LogoutAllRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *UserID;
@property(nonatomic, copy) NSString *Password;
@property(nonatomic, copy) NSString *Reason;

- (NSString *)toXml;

@end
