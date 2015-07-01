//
//  LogoutResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogoutResponse : NSObject
@property (nonatomic) BOOL isSuccessful;
@property (nonatomic, copy)NSString *reason;
@property (nonatomic) int reasonCode;
@end
