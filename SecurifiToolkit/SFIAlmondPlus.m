//
//  SFIAlmondPlus.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIAlmondPlus.h"

@implementation SFIAlmondPlus
@synthesize almondplusMAC, almondplusName, index;

#define kName_AlmondPlusMAC     @"AlmondPlusMAC"
#define kName_AlmondPlusName    @"AlmondPlusName"
#define kName_Index             @"Index"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:index forKey:kName_Index];
    [encoder encodeObject:almondplusMAC forKey:kName_AlmondPlusMAC];
    [encoder encodeObject:almondplusName forKey:kName_AlmondPlusName];
}


- (id)initWithCoder:(NSCoder *)decoder {
    self.index = [decoder decodeIntegerForKey:kName_Index];
    self.almondplusMAC = [decoder decodeObjectForKey:kName_AlmondPlusMAC];
    self.almondplusName = [decoder decodeObjectForKey:kName_AlmondPlusName];
    return self;
}

@end
