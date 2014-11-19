//
//  SFINotificationUser.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFINotificationUser : NSObject <NSCoding, NSCopying>
@property NSString *userID;
@property int preferenceCount;
@property NSMutableArray *notificationDeviceList;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

// Indicates whether the device has notification preference on
- (BOOL)isNotificationEnabled:(NSString*)deviceID;
@end
