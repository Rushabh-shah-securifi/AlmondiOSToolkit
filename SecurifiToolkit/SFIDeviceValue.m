//
//  SFIDeviceValue.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDeviceValue.h"

@interface SFIDeviceValue ()
@property(nonatomic, readonly) NSArray *knownValues;
@property(nonatomic, readonly) NSDictionary *lookupTable; // property type :: SFIDeviceKnownValues
@end

@implementation SFIDeviceValue

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.deviceID = (unsigned int) [coder decodeIntForKey:@"self.deviceID"];
        self.valueCount = (unsigned int) [coder decodeIntForKey:@"self.valueCount"];
        _knownValues = [coder decodeObjectForKey:@"self.knownValues"];
        _lookupTable = [self buildLookupTable:_knownValues];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.deviceID forKey:@"self.deviceID"];
    [coder encodeInt:self.valueCount forKey:@"self.valueCount"];
    [coder encodeObject:self.knownDevicesValues forKey:@"self.knownValues"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.deviceID=%u", self.deviceID];
    [description appendFormat:@", self.valueCount=%u", self.valueCount];
    [description appendFormat:@", self.knownValues=%@", self.knownDevicesValues];
    [description appendFormat:@", self.isPresent=%d", self.isPresent];
    [description appendString:@">"];
    return description;
}

- (id)copyWithZone:(NSZone *)zone {
    SFIDeviceValue *copy = (SFIDeviceValue *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.deviceID = self.deviceID;
        copy.valueCount = self.valueCount;
        [copy replaceKnownDeviceValues:self.knownDevicesValues];
        copy.isPresent = self.isPresent;
    }

    return copy;
}

- (SFIDeviceKnownValues *)knownValuesForPropertyName:(NSString *)name {
    for (SFIDeviceKnownValues *values in _knownValues) {
        if ([values.valueName isEqualToString:name]) {
            return values;
        }
    }
    return nil;
}

- (NSArray *)knownDevicesValues {
    if (_knownValues == nil) {
        return [NSArray array];
    }
    return [[NSArray alloc] initWithArray:_knownValues copyItems:YES];
}


- (void)replaceKnownDeviceValues:(NSArray *)values {
    NSArray *copy = [[NSArray alloc] initWithArray:values copyItems:YES];
    NSDictionary *lookupTable = [self buildLookupTable:copy];
    _knownValues = copy;
    _lookupTable = lookupTable;
}

- (SFIDeviceKnownValues*)knownValuesForProperty:(SFIDevicePropertyType)propertyType {
    SFIDeviceKnownValues *values = [self internalKnownValuesForProperty:propertyType];
    return [values copy];
}

- (SFIDeviceKnownValues *)internalKnownValuesForProperty:(SFIDevicePropertyType)propertyType {
    NSNumber *key = @(propertyType);
    return (self.lookupTable)[key];
}

- (NSString *)valueForProperty:(SFIDevicePropertyType)propertyType {
    SFIDeviceKnownValues *values = [self internalKnownValuesForProperty:propertyType];
    return values.value;
}

- (NSString *)valueForProperty:(SFIDevicePropertyType)propertyType default:(NSString *)ifNil {
    SFIDeviceKnownValues *values = [self internalKnownValuesForProperty:propertyType];
    NSString *str = values.value;
    return (str == nil) ? ifNil : str;
}

- (id)choiceForPropertyValue:(SFIDevicePropertyType)propertyType choices:(NSDictionary *)choices default:(id)ifNil {
    SFIDeviceKnownValues *values = [self internalKnownValuesForProperty:propertyType];
    if (!values) {
        return ifNil;
    }

    NSString *str = values.value;
    if (!str) {
        return ifNil;
    }

    id o = choices[str];
    if (!o) {
        return ifNil;
    }

    return o;
}

- (NSDictionary*)buildLookupTable:(NSArray*)knownValues {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (SFIDeviceKnownValues *values in knownValues) {
        NSNumber *key = @(values.propertyType);
        dict[key] = values;
    }
    
    return dict;
}

@end
