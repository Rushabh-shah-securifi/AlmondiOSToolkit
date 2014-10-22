//
//  AffiliationUserResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/29/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface AffiliationUserRequest : BaseCommandRequest <SecurifiCommand>

@property NSString *Code;

- (NSString *)toXml;

@end
