//
//  SFINotificationDevice.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 14/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "SFINotificationDevice.h"

@implementation SFINotificationDevice
- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.deviceID = (unsigned int)[coder decodeIntForKey:@"self.deviceID"];
        self.valueIndex = (unsigned int) [coder decodeIntForKey:@"self.valueIndex"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.deviceID forKey:@"self.deviceID"];
    [coder encodeInt:self.valueIndex forKey:@"self.valueIndex"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.deviceID=%u", self.deviceID];
    [description appendFormat:@", self.valueIndex=%u", self.valueIndex];
    [description appendString:@">"];
    return description;
}

- (id)copyWithZone:(NSZone *)zone {
    SFINotificationDevice *copy = (SFINotificationDevice *) [[[self class] allocWithZone:zone] init];
    
    if (copy != nil) {
        copy.deviceID = self.deviceID;
        copy.valueIndex = self.valueIndex;
    }
    
    return copy;
}
@end
