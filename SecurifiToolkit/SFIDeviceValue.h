//
//  SFIDeviceValue.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIDeviceKnownValues.h"

@interface SFIDeviceValue : NSObject <NSCoding, NSCopying>
@property(nonatomic) unsigned int deviceID;
@property(nonatomic) unsigned int valueCount;

// Ephemeral value holder useful for managing deleted or missing devices.
// Value is not persistent. Defaults to NO.
@property(nonatomic) BOOL isPresent;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

// returns a copy of the known values for the specified property, or nil if none found.
// changes to it are not reflected in the instances retained by this container.
- (SFIDeviceKnownValues*)knownValuesForProperty:(SFIDevicePropertyType)propertyType;

// returns the value for the specified property, or nil if none found
// this is the most efficient method for returns the value when only the string representation is required.
- (NSString*)valueForProperty:(SFIDevicePropertyType)propertyType;

// returns a copy of the SFIDeviceKnownValues;
// changes to them are not reflected in the instances retained by this container.
// call replaceKnownDeviceValues: update this container's collection
- (NSArray*)knownDevicesValues;

// sets the SFIDeviceKnownValues with the specified values.
// the values are copied
- (void)replaceKnownDeviceValues:(NSArray*)values;

@end
