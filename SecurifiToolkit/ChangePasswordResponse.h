//
//  ChangePasswordResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChangePasswordResponse : NSObject
@property BOOL isSuccessful;
@property int reasonCode;
@property NSString *reason;
@end
