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
@property(nonatomic) NSMutableArray *knownValues;

// Ephemeral value holder useful for managing deleted or missing devices.
// Value is not persistent. Defaults to NO.
@property(nonatomic) BOOL isPresent;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (SFIDeviceKnownValues*)knownValuesForProperty:(SFIDevicePropertyType)propertyType;

// returns the value for the specified property, or nil if none found
- (NSString*)valueForProperty:(SFIDevicePropertyType)propertyType;

- (id)copyWithZone:(NSZone *)zone;

@end
