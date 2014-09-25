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
        //PY 190914 - Owned Almond information
        self.userCount = [coder decodeIntForKey:@"self.userCount"];
        self.accessEmailIDs = [coder decodeObjectForKey:@"self.accessEmailIDs"];
        self.isExpanded = [coder decodeBoolForKey:@"self.isExpanded"];
        self.ownerEmailID = [coder decodeObjectForKey:@"self.ownerEmailID"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.almondplusMAC forKey:@"self.almondplusMAC"];
    [coder encodeObject:self.almondplusName forKey:@"self.almondplusName"];
    [coder encodeInt:self.index forKey:@"self.index"];
    [coder encodeInt:self.colorCodeIndex forKey:@"self.colorCodeIndex"];
    
    //PY 190914 - Owned Almond information
    [coder encodeInt:self.userCount forKey:@"self.userCount"];
    [coder encodeObject:self.accessEmailIDs forKey:@"self.accessEmailIDs"];
    [coder encodeBool:self.isExpanded forKey:@"self.isExpanded"];
    [coder encodeObject:self.ownerEmailID forKey:@"self.ownerEmailID"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.almondplusMAC=%@", self.almondplusMAC];
    [description appendFormat:@", self.almondplusName=%@", self.almondplusName];
    [description appendFormat:@", self.index=%i", self.index];
    [description appendFormat:@", self.colorCodeIndex=%i", self.colorCodeIndex];
    [description appendFormat:@", self.userCount=%i", self.userCount];
    [description appendFormat:@", self.accessEmailIDs=%@", self.accessEmailIDs];
    [description appendFormat:@", self.isExpanded=%d", self.isExpanded];
    [description appendFormat:@", self.ownerEmailID=%@", self.ownerEmailID];
    [description appendString:@">"];
    return description;
}

- (id)copyWithZone:(NSZone *)zone {
    SFIAlmondPlus *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.almondplusMAC = self.almondplusMAC;
        copy.almondplusName = self.almondplusName;
        copy.index = self.index;
        copy.colorCodeIndex = self.colorCodeIndex;
        copy.userCount = self.userCount;
        copy.accessEmailIDs = self.accessEmailIDs;
        copy.isExpanded = self.isExpanded;
        copy.ownerEmailID = self.ownerEmailID;
    }

    return copy;
}


@end
