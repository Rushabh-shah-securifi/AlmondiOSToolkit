//
//  SFIDeviceValue.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIDeviceValue.h"

@implementation SFIDeviceValue

#define kName_ID                                @"ID"          //int
#define kName_ValueCount                        @"ValueCount" //int
#define kName_KnownValues                       @"KnownValue" 
#define kName_IsPresent                         @"IsPresent"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.deviceID forKey:kName_ID];
    [encoder encodeInteger:self.valueCount forKey:kName_ValueCount];
    [encoder encodeObject:self.knownValues forKey:kName_KnownValues];
    [encoder encodeBool:self.isPresent forKey:kName_IsPresent];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.deviceID = (unsigned int) [decoder decodeIntForKey:kName_ID];
    self.valueCount = (unsigned int) [decoder decodeIntForKey:kName_ValueCount];
    self.knownValues = [decoder decodeObjectForKey:kName_KnownValues];
    self.isPresent = [decoder decodeBoolForKey:kName_IsPresent];
    return self;
}
@end
