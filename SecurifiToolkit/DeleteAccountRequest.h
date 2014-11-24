//
//  DeleteAccountRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 18/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface DeleteAccountRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *emailID;
@property(nonatomic, copy) NSString *password;

- (NSString *)toXml;
@end
