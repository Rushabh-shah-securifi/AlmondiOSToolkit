//
//  SignupResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignupResponse : NSObject
@property BOOL isSuccessful;
@property NSString *Reason;
@property int reasonCode;
@end