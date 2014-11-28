//
//  NotificationPreferences.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 27/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"
#import "SFINotificationUser.h"

@interface NotificationPreferences : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *action;
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic) int preferenceCount;
@property(nonatomic, copy) NSString *userID;
@property(nonatomic) NSArray *notificationDeviceList;
@property(nonatomic, copy) NSString *internalIndex;

- (NSString *)toXml;
@end
