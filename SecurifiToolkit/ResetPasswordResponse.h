//
//  ResetPasswordResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 01/11/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResetPasswordResponse : NSObject
@property BOOL isSuccessful;
@property NSString *reason;
@property int reasonCode;
@end
