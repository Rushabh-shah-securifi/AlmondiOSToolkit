//
//  DeleteMeAsSecondaryUserRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 24/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface DeleteMeAsSecondaryUserRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic, copy) NSString *internalIndex;

- (NSString *)toXml;
@end
