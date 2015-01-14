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
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) int reasonCode;
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic) int preferenceCount;
@property(nonatomic) SFINotificationUser *notificationUser;
@property(nonatomic) NSMutableArray *notificationDeviceList;
@end
