//
//  Device.h
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"
#import "GenericIndexClass.h"
#import "DeviceKnownValues.h"

@interface Device : NSObject

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
- (NSArray *)updateNotificationMode:(SFINotificationMode)mode deviceValue:(NSArray *)knownValues;

+ (Device*)getDeviceForID:(sfi_id)deviceID;

+ (NSMutableArray*)getDeviceTypes;

+ (NSMutableArray*)getGenericIndexes;

+ (NSDictionary*)getCommonIndexesDict;

+ (void)setDeviceNameLocation:(Device*)device forGenericID:(int)genericID value:(NSString*)value;

+ (Device *)getDeviceCopy:(Device*)device;

+ (NSString *)getValueForIndex:(int)index deviceID:(int)deviceID;

+ (int)getTypeForID:(int)deviceId;

+ (void)updateValueForID:(int)deviceID index:(int)index value:(NSString*)value;

+ (void)updateDeviceData:(DeviceCommandType)deviceCmdType value:(NSString*)value deviceID:(int)deviceID;

+ (DeviceKnownValues *)getKnownValue:(NSArray*)knownValues index:(int)index;
@end
