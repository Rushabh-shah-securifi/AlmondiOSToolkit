//
//  SFIAlmondPlus.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "SFIAlmondPlus.h"

@implementation SFIAlmondPlus

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.almondplusMAC = [coder decodeObjectForKey:@"self.almondplusMAC"];
        self.almondplusName = [coder decodeObjectForKey:@"self.almondplusName"];
        self.index = [coder decodeIntForKey:@"self.index"];
        self.colorCodeIndex = [coder decodeIntForKey:@"self.colorCodeIndex"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.almondplusMAC forKey:@"self.almondplusMAC"];
    [coder encodeObject:self.almondplusName forKey:@"self.almondplusName"];
    [coder encodeInt:self.index forKey:@"self.index"];
    [coder encodeInt:self.colorCodeIndex forKey:@"self.colorCodeIndex"];
}

@end
