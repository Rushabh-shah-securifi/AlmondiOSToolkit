//
//  SFIDeviceValue.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDeviceValue.h"

@implementation SFIDeviceValue

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.deviceID = (unsigned int) [coder decodeIntForKey:@"self.deviceID"];
        self.valueCount = (unsigned int) [coder decodeIntForKey:@"self.valueCount"];
        self.knownValues = [coder decodeObjectForKey:@"self.knownValues"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.deviceID forKey:@"self.deviceID"];
    [coder encodeInt:self.valueCount forKey:@"self.valueCount"];
    [coder encodeObject:self.knownValues forKey:@"self.knownValues"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.deviceID=%u", self.deviceID];
    [description appendFormat:@", self.valueCount=%u", self.valueCount];
    [description appendFormat:@", self.knownValues=%@", self.knownValues];
    [description appendFormat:@", self.isPresent=%d", self.isPresent];
    [description appendString:@">"];
    return description;
}

- (id)copyWithZone:(NSZone *)zone {
    SFIDeviceValue *copy = (SFIDeviceValue *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.deviceID = self.deviceID;
        copy.valueCount = self.valueCount;
        copy.knownValues = self.knownValues;
        copy.isPresent = self.isPresent;
    }

    return copy;
}

- (SFIDeviceKnownValues*)knownValuesForProperty:(SFIDevicePropertyType)propertyType {
    for (SFIDeviceKnownValues *currentDeviceValue in self.knownValues) {
        if (currentDeviceValue.propertyType == propertyType) {
            return currentDeviceValue;
        }
    }
    return nil;
}

- (NSString *)valueForProperty:(SFIDevicePropertyType)propertyType {
    SFIDeviceKnownValues *values = [self knownValuesForProperty:propertyType];
    return values.value;
}


@end
