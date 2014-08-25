//
//  SFIDeviceKnownValues.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDeviceKnownValues.h"

@implementation SFIDeviceKnownValues

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.index = (unsigned int) [coder decodeIntForKey:@"self.index"];
        self.valueName = [coder decodeObjectForKey:@"self.valueName"];
        self.valueType = [coder decodeObjectForKey:@"self.valueType"];
        self.value = [coder decodeObjectForKey:@"self.value"];
        self.isUpdating = [coder decodeBoolForKey:@"self.isUpdating"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.index forKey:@"self.index"];
    [coder encodeObject:self.valueName forKey:@"self.valueName"];
    [coder encodeObject:self.valueType forKey:@"self.valueType"];
    [coder encodeObject:self.value forKey:@"self.value"];
    [coder encodeBool:self.isUpdating forKey:@"self.isUpdating"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.index=%u", self.index];
    [description appendFormat:@", self.valueName=%@", self.valueName];
    [description appendFormat:@", self.valueType=%@", self.valueType];
    [description appendFormat:@", self.value=%@", self.value];
    [description appendFormat:@", self.isUpdating=%d", self.isUpdating];
    [description appendString:@">"];
    return description;
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

- (void)setBoolValue:(BOOL)value {
    if (value) {
        self.value = @"true";
    }
    else {
        self.value = @"false";
    }
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
