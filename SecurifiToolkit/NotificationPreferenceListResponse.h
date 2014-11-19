//
//  NotificationPreferenceListResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 14/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFINotificationUser.h"

@interface NotificationPreferenceListResponse : NSObject
@property BOOL isSuccessful;
@property NSString *reason;
@property int reasonCode;
@property NSString *almondMAC;
@property int preferenceCount;
@property SFINotificationUser *notificationUser;
@property NSMutableArray *notificationDeviceList;
@end
