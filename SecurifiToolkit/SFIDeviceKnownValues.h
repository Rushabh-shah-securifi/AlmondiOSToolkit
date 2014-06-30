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
- (float)floatValue;

// Interprets the value as a numeric (level switch)
- (BOOL)isZeroLevelValue;

- (id)choiceForLevelValueZeroValue:(id)aZeroVal nonZeroValue:(id)aNonZeroValue nilValue:(id)aNoneValue;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue;

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue nonNilValue:(id)aNonNilValue;

@end
