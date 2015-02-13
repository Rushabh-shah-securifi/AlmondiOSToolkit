//
//  SFINotificationUser.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFINotificationUser : NSObject <NSCoding, NSCopying>

@property(nonatomic, copy) NSString *userID;
@property(nonatomic) int preferenceCount;
@property(nonatomic, copy) NSArray *notificationDeviceList; // instances of SFINotificationDevice

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (id)copyWithZone:(NSZone *)zone;

- (NSString *)description;

//// Indicates whether the device has notification preference on
//- (BOOL)isNotificationEnabled:(NSString*)deviceID currentMAC:(NSString*)currentMac;
@end
