//
//  SFIDeviceValue.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDeviceValue.h"

@implementation SFIDeviceValue
@synthesize deviceID, valueCount, knownValues;
@synthesize isPresent;

#define kName_ID                                @"ID"          //int
#define kName_ValueCount                        @"ValueCount" //int
#define kName_KnownValues                       @"KnownValue" 
#define kName_IsPresent                         @"IsPresent"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:deviceID forKey:kName_ID];
    [encoder encodeInteger:valueCount forKey:kName_ValueCount];
    [encoder encodeObject:knownValues forKey:kName_KnownValues];
    [encoder encodeBool:isPresent forKey:kName_IsPresent];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.deviceID = [decoder decodeIntegerForKey:kName_ID];
    self.valueCount = [decoder decodeIntegerForKey:kName_ValueCount];
    self.knownValues = [decoder decodeObjectForKey:kName_KnownValues];
    self.isPresent = [decoder decodeBoolForKey:kName_IsPresent];
    return self;
}
@end
