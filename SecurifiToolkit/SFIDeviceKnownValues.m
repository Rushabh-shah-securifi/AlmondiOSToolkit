//
//  SFIDeviceKnownValues.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "SFIDeviceKnownValues.h"

@implementation SFIDeviceKnownValues


+ (SFIDevicePropertyType)nameToPropertyType:(NSString *)valueName {
    return securifi_NameToPropertyType(valueName);
}

+ (NSString *)propertyTypeToName:(SFIDevicePropertyType)propertyType {
    return securifi_propertyTypeToName(propertyType);
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.index = (unsigned int) [coder decodeIntForKey:@"self.index"];
        self.valueName = [coder decodeObjectForKey:@"self.valueName"];
        self.propertyType = (SFIDevicePropertyType) [coder decodeIntForKey:@"self.propertyType"];
        self.valueType = [coder decodeObjectForKey:@"self.valueType"];
        self.value = [coder decodeObjectForKey:@"self.value"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.index forKey:@"self.index"];
    [coder encodeObject:self.valueName forKey:@"self.valueName"];
    [coder encodeInt:self.propertyType forKey:@"self.propertyType"];
    [coder encodeObject:self.valueType forKey:@"self.valueType"];
    [coder encodeObject:self.value forKey:@"self.value"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.index=%u", self.index];
    [description appendFormat:@", self.valueName=%@", self.valueName];
    [description appendFormat:@", self.propertyType=%d", self.propertyType];
    [description appendFormat:@", self.valueType=%@", self.valueType];
    [description appendFormat:@", self.value=%@", self.value];
    [description appendString:@">"];
    return description;
}


- (BOOL)hasValue {
    return self.value.length > 0;
}

- (BOOL)boolValue {
    return [self.value isEqualToString:@"true"];
}

- (int)intValue {
    return [self.value intValue];
}

- (unsigned int)hexToIntValue {
    NSScanner *scanner = [NSScanner scannerWithString:self.value];

    unsigned int aInt = 0;
    [scanner scanHexInt:&aInt];
    return aInt;
}

- (float)floatValue {
    return [self.value floatValue];
}

- (void)setIntValue:(int)value {
    self.value = [NSString stringWithFormat:@"%d", value];
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
    if (self.value == nil || self.value.length == 0) {
        return aNoneValue;
    }
    if (self.isZeroLevelValue) {
        return aZeroVal;
    }
    return aNonZeroValue;
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


- (id)copyWithZone:(NSZone *)zone {
    SFIDeviceKnownValues *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.index = self.index;
        copy.valueName = self.valueName;
        copy.propertyType = self.propertyType;
        copy.valueType = self.valueType;
        copy.value = self.value;
    }

    return copy;
}

@end
