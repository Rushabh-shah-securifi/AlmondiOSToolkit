//
//  SFINotificationDevice.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 14/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

/**
* Represents a notification preference setting for a device value index (property) for a specific device.
* A device having multiple properties will be managed by multiple instances of this class, one for each property.
*/
@interface SFINotificationDevice : NSObject
@property(nonatomic) sfi_id deviceID;
@property(nonatomic) unsigned int valueIndex;
@property(nonatomic) SFINotificationMode notificationMode;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

@end
