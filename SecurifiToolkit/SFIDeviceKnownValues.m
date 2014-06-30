//
//  SFIDeviceKnownValues.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDeviceKnownValues.h"

@implementation SFIDeviceKnownValues

#define kName_Index             @"Index"          //int
#define kName_ValueName         @"ValueName"
#define kName_ValueType         @"ValueType"
#define kName_Value             @"Value"
#define kName_IsUpdating        @"IsUpdating"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.index forKey:kName_Index];
    [encoder encodeObject:self.valueName forKey:kName_ValueName];
    [encoder encodeObject:self.valueType forKey:kName_ValueType];
    [encoder encodeObject:self.value forKey:kName_Value];
    [encoder encodeBool:self.isUpdating forKey:kName_IsUpdating];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.index = (unsigned int)[decoder decodeIntForKey:kName_Index];
    self.valueName = [decoder decodeObjectForKey:kName_ValueName];
    self.valueType = [decoder decodeObjectForKey:kName_ValueType];
    self.value = [decoder decodeObjectForKey:kName_Value];
    self.isUpdating = [decoder decodeBoolForKey:kName_IsUpdating];
    return self;
}

- (BOOL)hasValue {
    return self.value.length > 0;
}

- (BOOL)boolValue {
    return [self.value isEqualToString:@"true"];
}

- (float)floatValue {
    return [self.value floatValue];
}


- (BOOL)isZeroLevelValue {
    return [self.value isEqualToString:@"0"];
}

- (id)choiceForLevelValueZeroValue:(id)aZeroVal nonZeroValue:(id)aNonZeroValue nilValue:(id)aNoneValue {
    if (self.value == nil) {
        return aNoneValue;
    }
    if (self.isZeroLevelValue) {
        return aZeroVal;
    }
    return aNonZeroValue;
}


- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr {
    if ([self.value isEqualToString:@"true"]) {
        return aTrueStr;
    }
    return aFalseStr;
}

- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue {
    if ([self.value isEqualToString:@"true"]) {
        return aTrueStr;
    }
    if ([self.value isEqualToString:@"false"]) {
        return aFalseStr;
    }
    return aNoneValue;
}


- (id)choiceForBoolValueTrueValue:(id)aTrueStr falseValue:(id)aFalseStr nilValue:(id)aNoneValue nonNilValue:(NSString*)aNonNilValue {
    if ([self.value isEqualToString:@"true"]) {
        return aTrueStr;
    }
    if ([self.value isEqualToString:@"false"]) {
        return aFalseStr;
    }
    if (self.value == nil) {
        return aNoneValue;
    }
    return aNonNilValue;
}


@end
