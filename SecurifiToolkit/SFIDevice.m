//
//  SFIDevice.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDevice.h"

@implementation SFIDevice

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.deviceID = (unsigned int) [coder decodeIntForKey:@"self.deviceID"];
        self.deviceName = [coder decodeObjectForKey:@"self.deviceName"];
        self.OZWNode = [coder decodeObjectForKey:@"self.OZWNode"];
        self.zigBeeShortID = [coder decodeObjectForKey:@"self.zigBeeShortID"];
        self.zigBeeEUI64 = [coder decodeObjectForKey:@"self.zigBeeEUI64"];
        self.deviceTechnology = (unsigned int) [coder decodeIntForKey:@"self.deviceTechnology"];
        self.associationTimestamp = [coder decodeObjectForKey:@"self.associationTimestamp"];
        self.deviceType = (unsigned int) [coder decodeIntForKey:@"self.deviceType"];
        self.deviceTypeName = [coder decodeObjectForKey:@"self.deviceTypeName"];
        self.friendlyDeviceType = [coder decodeObjectForKey:@"self.friendlyDeviceType"];
        self.deviceFunction = [coder decodeObjectForKey:@"self.deviceFunction"];
        self.allowNotification = [coder decodeObjectForKey:@"self.allowNotification"];
        self.valueCount = (unsigned int) [coder decodeIntForKey:@"self.valueCount"];
        self.location = [coder decodeObjectForKey:@"self.location"];
        self.isExpanded = [coder decodeBoolForKey:@"self.isExpanded"];
        self.imageName = [coder decodeObjectForKey:@"self.imageName"];
        self.mostImpValueName = [coder decodeObjectForKey:@"self.mostImpValueName"];
        self.mostImpValueIndex = [coder decodeIntForKey:@"self.mostImpValueIndex"];
        self.stateIndex = [coder decodeIntForKey:@"self.stateIndex"];
        self.isTampered = [coder decodeBoolForKey:@"self.isTampered"];
        self.tamperValueIndex = [coder decodeIntForKey:@"self.tamperValueIndex"];
        self.isBatteryLow = [coder decodeBoolForKey:@"self.isBatteryLow"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.deviceID forKey:@"self.deviceID"];
    [coder encodeObject:self.deviceName forKey:@"self.deviceName"];
    [coder encodeObject:self.OZWNode forKey:@"self.OZWNode"];
    [coder encodeObject:self.zigBeeShortID forKey:@"self.zigBeeShortID"];
    [coder encodeObject:self.zigBeeEUI64 forKey:@"self.zigBeeEUI64"];
    [coder encodeInt:self.deviceTechnology forKey:@"self.deviceTechnology"];
    [coder encodeObject:self.associationTimestamp forKey:@"self.associationTimestamp"];
    [coder encodeInt:self.deviceType forKey:@"self.deviceType"];
    [coder encodeObject:self.deviceTypeName forKey:@"self.deviceTypeName"];
    [coder encodeObject:self.friendlyDeviceType forKey:@"self.friendlyDeviceType"];
    [coder encodeObject:self.deviceFunction forKey:@"self.deviceFunction"];
    [coder encodeObject:self.allowNotification forKey:@"self.allowNotification"];
    [coder encodeInt:self.valueCount forKey:@"self.valueCount"];
    [coder encodeObject:self.location forKey:@"self.location"];
    [coder encodeBool:self.isExpanded forKey:@"self.isExpanded"];
    [coder encodeObject:self.imageName forKey:@"self.imageName"];
    [coder encodeObject:self.mostImpValueName forKey:@"self.mostImpValueName"];
    [coder encodeInt:self.mostImpValueIndex forKey:@"self.mostImpValueIndex"];
    [coder encodeInt:self.stateIndex forKey:@"self.stateIndex"];
    [coder encodeBool:self.isTampered forKey:@"self.isTampered"];
    [coder encodeInt:self.tamperValueIndex forKey:@"self.tamperValueIndex"];
    [coder encodeBool:self.isBatteryLow forKey:@"self.isBatteryLow"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.deviceID=%u", self.deviceID];
    [description appendFormat:@", self.deviceName=%@", self.deviceName];
    [description appendFormat:@", self.OZWNode=%@", self.OZWNode];
    [description appendFormat:@", self.zigBeeShortID=%@", self.zigBeeShortID];
    [description appendFormat:@", self.zigBeeEUI64=%@", self.zigBeeEUI64];
    [description appendFormat:@", self.deviceTechnology=%u", self.deviceTechnology];
    [description appendFormat:@", self.associationTimestamp=%@", self.associationTimestamp];
    [description appendFormat:@", self.deviceType=%u", self.deviceType];
    [description appendFormat:@", self.deviceTypeName=%@", self.deviceTypeName];
    [description appendFormat:@", self.friendlyDeviceType=%@", self.friendlyDeviceType];
    [description appendFormat:@", self.deviceFunction=%@", self.deviceFunction];
    [description appendFormat:@", self.allowNotification=%@", self.allowNotification];
    [description appendFormat:@", self.valueCount=%u", self.valueCount];
    [description appendFormat:@", self.location=%@", self.location];
    [description appendFormat:@", self.isExpanded=%d", self.isExpanded];
    [description appendFormat:@", self.imageName=%@", self.imageName];
    [description appendFormat:@", self.mostImpValueName=%@", self.mostImpValueName];
    [description appendFormat:@", self.mostImpValueIndex=%i", self.mostImpValueIndex];
    [description appendFormat:@", self.stateIndex=%i", self.stateIndex];
    [description appendFormat:@", self.isTampered=%d", self.isTampered];
    [description appendFormat:@", self.tamperValueIndex=%i", self.tamperValueIndex];
    [description appendFormat:@", self.isBatteryLow=%d", self.isBatteryLow];
    [description appendString:@">"];
    return description;
}

@end
