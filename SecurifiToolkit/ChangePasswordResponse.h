//
//  ChangePasswordResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChangePasswordResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) int reasonCode;
@property(nonatomic, copy) NSString *reason;
@end
