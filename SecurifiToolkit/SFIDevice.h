//
//  SFIDevice.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFIDeviceValue;

@interface SFIDevice : NSObject <NSCoding>

@property unsigned int deviceID;
@property NSString *deviceName;
@property NSString *OZWNode;
@property NSString *zigBeeShortID;
@property NSString *zigBeeEUI64;
@property unsigned int deviceTechnology;
@property NSString *associationTimestamp;
@property unsigned int deviceType;
@property NSString *deviceTypeName;
@property NSString *friendlyDeviceType;
@property NSString *deviceFunction;
@property NSString *allowNotification;
@property unsigned int valueCount;
@property NSString *location;

//PY 111013 - Integration with new UI
@property BOOL isExpanded;
@property(nonatomic, retain) NSString *imageName;
@property(nonatomic, retain) NSString *mostImpValueName;
@property int mostImpValueIndex;
@property int stateIndex;
@property BOOL isTampered;
@property int tamperValueIndex;
@property BOOL isBatteryLow;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

// returns the imageName property value or when null returns the default value
- (NSString *)imageName:(NSString *)defaultName;

- (void)initializeFromValues:(SFIDeviceValue *)values;

@end
