//
//  NotificationDeleteRegistrationResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 07/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationDeleteRegistrationResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) int reasonCode;
@end
