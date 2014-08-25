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

@property(nonatomic) unsigned int deviceID;
@property(nonatomic) NSString *deviceName;
@property(nonatomic) NSString *OZWNode;
@property(nonatomic) NSString *zigBeeShortID;
@property(nonatomic) NSString *zigBeeEUI64;
@property(nonatomic) unsigned int deviceTechnology;
@property(nonatomic) NSString *associationTimestamp;
@property(nonatomic) unsigned int deviceType;
@property(nonatomic) NSString *deviceTypeName;
@property(nonatomic) NSString *friendlyDeviceType;
@property(nonatomic) NSString *deviceFunction;
@property(nonatomic) NSString *allowNotification;
@property(nonatomic) unsigned int valueCount;
@property(nonatomic) NSString *location;

@property(nonatomic) BOOL isExpanded;
@property(nonatomic) NSString *imageName;
@property(nonatomic) NSString *mostImpValueName;
@property(nonatomic) int mostImpValueIndex;
@property(nonatomic) int stateIndex;
@property(nonatomic) BOOL isTampered;
@property(nonatomic) int tamperValueIndex;
@property(nonatomic) BOOL isBatteryLow;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

// returns the imageName property value or when null returns the default value
- (NSString *)imageName:(NSString *)defaultName;

//todo not sure why it's called "most important" value
- (BOOL)isTamperMostImportantValue;

- (void)initializeFromValues:(SFIDeviceValue *)values;

@end
