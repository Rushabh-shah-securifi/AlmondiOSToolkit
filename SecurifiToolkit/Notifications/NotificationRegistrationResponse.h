//
//  NotificationRegistrationResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 06/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, NotificationRegistrationResponseType) {
    NotificationRegistrationResponseType_success,
    NotificationRegistrationResponseType_alreadyRegistered,
    NotificationRegistrationResponseType_failedToRegister
};

@interface NotificationRegistrationResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) int reasonCode;

// interprets the reason code to indicate whether an unsuccessful response is due to the APN token already being registered.
// in this case, the failure can be ignored.
- (NotificationRegistrationResponseType)responseType;

@end
