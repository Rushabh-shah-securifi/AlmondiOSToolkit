//
//  DeleteAccountRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 18/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface DeleteAccountRequest : NSObject  <SecurifiCommand>
@property NSString *emailID;
@property NSString *password;
- (NSString*)toXml;
@end
