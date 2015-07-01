//
//  NotificationRegistrationResponse.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 06/11/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "NotificationRegistrationResponse.h"

@implementation NotificationRegistrationResponse

- (NotificationRegistrationResponseType)responseType {
    if (self.isSuccessful) {
        return NotificationRegistrationResponseType_success;
    }
    if (self.reasonCode == 3) {
        return NotificationRegistrationResponseType_alreadyRegistered;
    }
    return NotificationRegistrationResponseType_failedToRegister;
}

@end
