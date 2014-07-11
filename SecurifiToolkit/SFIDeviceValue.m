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
        self.isPresent = [coder decodeBoolForKey:@"self.isPresent"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.deviceID forKey:@"self.deviceID"];
    [coder encodeInt:self.valueCount forKey:@"self.valueCount"];
    [coder encodeObject:self.knownValues forKey:@"self.knownValues"];
    [coder encodeBool:self.isPresent forKey:@"self.isPresent"];
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


@end
