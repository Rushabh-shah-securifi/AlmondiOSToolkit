//
//  SFIDeviceKnownValues.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDeviceKnownValues.h"

@implementation SFIDeviceKnownValues
@synthesize index, value, valueName, valueType, isUpdating;

#define kName_Index             @"Index"          //int
#define kName_ValueName         @"ValueName"
#define kName_ValueType         @"ValueType"
#define kName_Value             @"Value"
#define kName_IsUpdating        @"IsUpdating"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:index forKey:kName_Index];
    [encoder encodeObject:valueName forKey:kName_ValueName];
    [encoder encodeObject:valueType forKey:kName_ValueType];
    [encoder encodeObject:value forKey:kName_Value];
    [encoder encodeBool:isUpdating forKey:kName_IsUpdating];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.index = (unsigned int)[decoder decodeIntForKey:kName_Index];
    self.valueName = [decoder decodeObjectForKey:kName_ValueName];
    self.valueType = [decoder decodeObjectForKey:kName_ValueType];
    self.value = [decoder decodeObjectForKey:kName_Value];
    self.isUpdating = [decoder decodeBoolForKey:kName_IsUpdating];
    return self;
}

@end
