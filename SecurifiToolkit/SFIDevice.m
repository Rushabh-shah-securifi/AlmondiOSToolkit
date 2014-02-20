//
//  SFIDevice.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDevice.h"

@implementation SFIDevice
@synthesize deviceID, deviceFunction, deviceName, deviceTechnology, deviceType, deviceTypeName;
@synthesize zigBeeEUI64, zigBeeShortID;
@synthesize allowNotification, associationTimestamp, friendlyDeviceType, OZWNode, valueCount;
@synthesize isExpanded, imageName, mostImpValueIndex, mostImpValueName, stateIndex, isTampered;
@synthesize isBatteryLow;
@synthesize location, tamperValueIndex;


#define kName_ID                                @"ID"           //int
#define kName_DeviceName                        @"DeviceName"
#define kName_OZWNode                           @"OZWNode"
#define kName_ZigBeeShortID                     @"ZigbeeShortID"
#define kName_ZigBeeEUI64                       @"ZigbeeEUI64"
#define kName_DeviceTechnology                  @"DeviceTechnology" //int
#define kName_AssociationTimestamp              @"AssociationTimeStamp"
#define kName_DeviceType                        @"DeviceType" //int
#define kName_DeviceTypeName                    @"DeviceTypeName"
#define kName_FriendlyDeviceType                @"FriendlyDeviceType"
#define kName_DeviceFunction                    @"DeviceFunction"
#define kName_AllowNotification                 @"AllowNotification"
#define kName_ValueCount                        @"ValueCount" //int
#define kName_IsExpanded                        @"IsExpanded" //bool
#define kName_ImageName                         @"ImageName"
#define kName_ImpValueName                      @"ImpValueName"
#define kName_ImpValueIndex                     @"ImpValueIndex" //int
#define kName_StateIndex                        @"StateIndex" //int
#define kName_TamperIndex                       @"TamperIndex" //int
#define kName_Location                          @"Location"
#define kName_IsTampered                        @"Tampered" //BOOL
#define kName_IsBatteryLow                      @"LowBattery" //BOOL

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:deviceID forKey:kName_ID];
    [encoder encodeObject:deviceName forKey:kName_DeviceName];
    [encoder encodeObject:OZWNode forKey:kName_OZWNode];
    [encoder encodeObject:zigBeeShortID forKey:kName_ZigBeeShortID];
    [encoder encodeObject:zigBeeEUI64 forKey:kName_ZigBeeEUI64];
    [encoder encodeInteger:deviceTechnology forKey:kName_DeviceTechnology];
    [encoder encodeObject:associationTimestamp forKey:kName_AssociationTimestamp];
    [encoder encodeInteger:deviceType forKey:kName_DeviceType];
    [encoder encodeObject:deviceTypeName forKey:kName_DeviceTypeName];
    [encoder encodeObject:friendlyDeviceType forKey:kName_FriendlyDeviceType];
    [encoder encodeObject:deviceFunction forKey:kName_DeviceFunction];
    [encoder encodeObject:allowNotification forKey:kName_AllowNotification];
    [encoder encodeInteger:valueCount forKey:kName_ValueCount];
    [encoder encodeObject:location forKey:kName_Location];
    
    //PY 111013 - Integration with new UI
    [encoder encodeBool:isExpanded forKey:kName_IsExpanded];
    [encoder encodeObject:imageName forKey:kName_ImageName];
    [encoder encodeObject:mostImpValueName forKey:kName_ImpValueName];
    [encoder encodeInteger:mostImpValueIndex forKey:kName_ImpValueIndex];
    [encoder encodeInteger:stateIndex forKey:kName_StateIndex];
    [encoder encodeInteger:tamperValueIndex forKey:kName_TamperIndex];
    [encoder encodeBool:isExpanded forKey:kName_IsTampered];
    [encoder encodeBool:isExpanded forKey:kName_IsBatteryLow];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.deviceID = [decoder decodeIntegerForKey:kName_ID];
    self.deviceName = [decoder decodeObjectForKey:kName_DeviceName];
    self.OZWNode = [decoder decodeObjectForKey:kName_OZWNode];
    self.zigBeeShortID = [decoder decodeObjectForKey:kName_ZigBeeShortID];
    self.zigBeeEUI64 = [decoder decodeObjectForKey:kName_ZigBeeEUI64];
    self.deviceTechnology = [decoder decodeIntegerForKey:kName_DeviceTechnology];
    self.associationTimestamp = [decoder decodeObjectForKey:kName_AssociationTimestamp];
    self.deviceType = [decoder decodeIntegerForKey:kName_DeviceType];
    self.deviceTypeName = [decoder decodeObjectForKey:kName_DeviceTypeName];
    self.friendlyDeviceType = [decoder decodeObjectForKey:kName_FriendlyDeviceType];
    self.deviceFunction = [decoder decodeObjectForKey:kName_DeviceFunction];
    self.allowNotification = [decoder decodeObjectForKey:kName_AllowNotification];
    self.valueCount = [decoder decodeIntegerForKey:kName_ValueCount];
    self.location = [decoder decodeObjectForKey:kName_Location];
    
    //PY 111013 - Integration with new UI
    self.isExpanded = [decoder decodeBoolForKey:kName_IsExpanded];
    self.imageName = [decoder decodeObjectForKey:kName_ImageName];
    self.mostImpValueName = [decoder decodeObjectForKey:kName_ImpValueName];
    self.mostImpValueIndex = [decoder decodeIntegerForKey:kName_ImpValueIndex];
    self.stateIndex = [decoder decodeIntegerForKey:kName_StateIndex];
    self.isTampered = [decoder decodeBoolForKey:kName_IsTampered];
    self.isBatteryLow = [decoder decodeBoolForKey:kName_IsBatteryLow];
    self.tamperValueIndex = [decoder decodeIntegerForKey:kName_TamperIndex];
    return self;
}
@end
