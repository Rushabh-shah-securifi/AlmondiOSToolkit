//
//  Device.h
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

@class SFIDeviceKnownValues;

@interface Device : NSObject <NSCoding, NSCopying>

@property(nonatomic) int type;
@property(nonatomic) sfi_id ID;
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *location;
@property(nonatomic) NSString *almondMAC; //todo remove me or set me in the toolkit
@property(nonatomic) SFINotificationMode notificationMode;
@property(nonatomic) NSMutableArray *knownValues;

+ (NSArray*)addDevice:(Device*)device list:(NSArray*)list;
+ (NSArray*)removeDevice:(Device*)device list:(NSArray*)list;

// Indicates whether the device has been tampered
- (BOOL)isTampered;
// Indicates whether the device has a low battery
- (BOOL)isBatteryLow;

// Updates this instances notificationMode and generates SFINotificationDevice values that can be
// sent to the cloud to communicate this mode change.
- (NSArray *)updateNotificationMode:(SFINotificationMode)mode deviceValue:(Device *)value;



@end
