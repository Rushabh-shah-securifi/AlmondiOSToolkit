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

// returns a copy of the known values for the specified property name, or nil if none found.
// the property name is the string representation of SFIDevicePropertyType, as used on the wire with the cloud.
// this method provides a way to access indexed or synthesized properties for which there is no, or cannot be,
// a single SFIDevicePropertyType representation. For example, door lock pin codes are assigned to
// any number of named properties derived from SFIDevicePropertyType_USER_CODE.
// changes to SFIDeviceKnownValues are not reflected in the instances retained by this container.
// call replaceKnownDeviceValues: to update this container's collection
- (SFIDeviceKnownValues*)knownValuesForPropertyName:(NSString*)name;

// returns a copy of the known values for the specified property, or nil if none found.
// changes to SFIDeviceKnownValues are not reflected in the instances retained by this container.
// call replaceKnownDeviceValues: to update this container's collection
- (SFIDeviceKnownValues*)knownValuesForProperty:(SFIDevicePropertyType)propertyType;

// returns the value for the specified property, or nil if none found
// this is the most efficient method for returns the value when only the string representation is required.
- (NSString*)valueForProperty:(SFIDevicePropertyType)propertyType;

// returns the value for the specified property, or the ifNil value when no value is found.
// this is the most efficient method for returns the value when only the string representation is required.
- (NSString*)valueForProperty:(SFIDevicePropertyType)propertyType default:(NSString*)ifNil;

// returns the dictionary value associated with the specified property's value, or ifNil value when no match is found.
// this method provides a convenience to UI controls, such as segmented buttons, that must set their state depending
// on more than one possible value.
// The dictionary key is the property value to match on, and the dictionary value is the object to be returned.
- (id)choiceForPropertyValue:(SFIDevicePropertyType)propertyType choices:(NSDictionary *)choices default:(id)ifNil;

// returns a copy of the SFIDeviceKnownValues;
// changes to SFIDeviceKnownValues are not reflected in the instances retained by this container.
// call replaceKnownDeviceValues: to update this container's collection
- (NSArray*)knownDevicesValues;

// sets the SFIDeviceKnownValues with the specified values.
// the values are copied
- (void)replaceKnownDeviceValues:(NSArray*)values;

@end
