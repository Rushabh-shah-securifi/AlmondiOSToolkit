//
//  SFIDeviceValue.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
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

// Returns a copy of the known values for the specified property name, or nil if none found.
// The property name is the string representation of SFIDevicePropertyType, as used on the wire with the cloud.
// This method provides a way to access indexed or synthesized properties for which there is no, or cannot be,
// a single SFIDevicePropertyType representation. For example, door lock pin codes are assigned to
// any number of named properties derived from SFIDevicePropertyType_USER_CODE.
// changes to SFIDeviceKnownValues are not reflected in the instances retained by this container.
// Call replaceKnownDeviceValues: to update this container's collection
- (SFIDeviceKnownValues*)knownValuesForPropertyName:(NSString*)name;

// Returns a copy of the known values for the specified property, or nil if none found.
// Changes to SFIDeviceKnownValues are not reflected in the instances retained by this container.
// Call replaceKnownDeviceValues: to update this container's collection
- (SFIDeviceKnownValues*)knownValuesForProperty:(SFIDevicePropertyType)propertyType;

// Returns the value for the specified property, or nil if none found
// This is the most efficient method when a string representation is required.
- (NSString*)valueForProperty:(SFIDevicePropertyType)propertyType;

// Returns the value for the specified property, or the ifNil value when no value is found.
// This is the most efficient method when a string representation is required.
- (NSString*)valueForProperty:(SFIDevicePropertyType)propertyType default:(NSString*)ifNil;

// Returns the dictionary value associated with the specified property's value, or ifNil value when no match is found.
// This method provides a convenience to UI controls, such as segmented buttons, that must set their state depending
// on more than one possible value. The dictionary key is the literal property value to match on,
// and the dictionary value is the object to be returned.
- (id)choiceForPropertyValue:(SFIDevicePropertyType)propertyType choices:(NSDictionary *)choices default:(id)ifNil;

// Returns a copy of the SFIDeviceKnownValues;
// changes to SFIDeviceKnownValues are not reflected in the instances retained by this container.
// Call replaceKnownDeviceValues: to update this container's collection
- (NSArray*)knownDevicesValues;

// Updates the values for the specified property.
// The receiver's state is not altered and a clone reflecting the change is returned.
- (SFIDeviceValue*)setKnownValues:(SFIDeviceKnownValues *)newValues forProperty:(SFIDevicePropertyType)type;

// Updates the values for the specified property.
// The receiver's state is not altered and a clone reflecting the change is returned.
- (SFIDeviceValue*)setKnownValues:(SFIDeviceKnownValues *)newValues forPropertyName:(NSString*)name;

// Sets the SFIDeviceKnownValues with the specified values.
// The values are copied.
- (void)replaceKnownDeviceValues:(NSArray*)values;

+ (NSArray *)removeDeviceValue:(unsigned int)deviceId list:(NSArray *)list;

@end
