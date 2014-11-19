//
//  DynamicNotificationPreferenceList.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar  on 11/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicNotificationPreferenceList : NSObject
@property NSString *almondMAC;
@property int userCount;
@property NSMutableArray *notificationUserList;
@end
