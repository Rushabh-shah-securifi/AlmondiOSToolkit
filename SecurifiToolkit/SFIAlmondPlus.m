//
//  SFIAlmondPlus.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIAlmondPlus.h"

@implementation SFIAlmondPlus

#define kName_AlmondPlusMAC     @"AlmondPlusMAC"
#define kName_AlmondPlusName    @"AlmondPlusName"
#define kName_Index             @"Index"

- (id)initWithCoder:(NSCoder *)decoder {
    self.index = [decoder decodeIntForKey:kName_Index];
    self.almondplusMAC = [decoder decodeObjectForKey:kName_AlmondPlusMAC];
    self.almondplusName = [decoder decodeObjectForKey:kName_AlmondPlusName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.index forKey:kName_Index];
    [encoder encodeObject:self.almondplusMAC forKey:kName_AlmondPlusMAC];
    [encoder encodeObject:self.almondplusName forKey:kName_AlmondPlusName];
}

@end
