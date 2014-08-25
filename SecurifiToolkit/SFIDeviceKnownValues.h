//
//  SFIDeviceKnownValues.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIDeviceKnownValues : NSObject <NSCoding>
@property unsigned int      index;
@property NSString          *valueName;
@property NSString          *valueType;
@property NSString          *value;
@property BOOL              isUpdating;

// true when a non-nil and non-empty value is present
- (BOOL)hasValue;

- (BOOL)boolValue;
- (int)intValue;
- (float)floatValue;

- (void)setIntValue:(int)value;

// Sets the value property with the appropriate string representation
- (void)setBoolValue:(BOOL)value;

// Interprets the value as a numeric (level switch)
- (BOOL)isZeroLevelValue;

- (id)choiceForLevelValueZeroValue:(id)aZeroVal nonZeroValue:(id)aNonZeroValue nilValue:(id)aNoneValue;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue nonNilValue:(id)aNonNilValue;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

@end
