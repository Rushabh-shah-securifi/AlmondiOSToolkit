//
//  DynamicNotificationPreferenceList.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar  on 11/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicNotificationPreferenceList : NSObject
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic) int userCount;
@property(nonatomic) NSMutableArray *notificationUserList;
@end
