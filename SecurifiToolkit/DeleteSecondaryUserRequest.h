//
//  DeleteSecondaryUserRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface DeleteSecondaryUserRequest : BaseCommandRequest  <SecurifiCommand>
@property NSString *almondMAC;
@property NSString *emailID;
@property(nonatomic) NSString *internalIndex;

- (NSString*)toXml;
@end