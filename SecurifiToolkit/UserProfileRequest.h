//
//  SFIUserProfileRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 15/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface UserProfileRequest : NSObject <SecurifiCommand>
- (NSString*)toXml;
@end
