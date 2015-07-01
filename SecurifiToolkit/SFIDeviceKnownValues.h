//
//  SFIDeviceKnownValues.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

@interface SFIDeviceKnownValues : NSObject <NSCoding, NSCopying>

@property(nonatomic) unsigned int index;
@property(nonatomic) NSString *valueName;
@property(nonatomic) SFIDevicePropertyType propertyType;
@property(nonatomic) NSString *valueType;
@property(nonatomic) NSString *value;

// Converts the standard Device Property Name string into a type ID
+ (SFIDevicePropertyType)nameToPropertyType:(NSString *)valueName;

+ (NSString*)propertyTypeToName:(SFIDevicePropertyType)propertyType;

// true when a non-nil and non-empty value is present
- (BOOL)hasValue;

- (BOOL)boolValue;

- (int)intValue;

- (unsigned int)hexToIntValue;

- (float)floatValue;

- (void)setIntValue:(int)value;

// Sets the value property with the appropriate string representation
- (void)setBoolValue:(BOOL)value;

// Interprets the value as a numeric (level switch)
- (BOOL)isZeroLevelValue;

- (id)choiceForLevelValueZeroValue:(id)aZeroVal nonZeroValue:(id)aNonZeroValue nilValue:(id)aNoneValue;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

@end
