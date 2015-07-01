//
//  ResetPasswordResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 01/11/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResetPasswordResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) int reasonCode;
@end
