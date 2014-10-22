//
//  DeleteMeAsSecondaryUserRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 24/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface DeleteMeAsSecondaryUserRequest : BaseCommandRequest <SecurifiCommand>
@property NSString *almondMAC;
@property NSString *internalIndex;

- (NSString*)toXml;
@end
