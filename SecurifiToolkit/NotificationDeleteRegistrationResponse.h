//
//  NotificationDeleteRegistrationResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 07/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationDeleteRegistrationResponse : NSObject
@property BOOL isSuccessful;
@property NSString *reason;
@property int reasonCode;
@end
