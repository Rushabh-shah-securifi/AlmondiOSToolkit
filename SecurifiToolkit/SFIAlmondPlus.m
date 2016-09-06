//
//  SFIAlmondPlus.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "SFIAlmondPlus.h"
#import "AlmondVersionChecker.h"

@implementation SFIAlmondPlus

+ (NSString *)convertDecimalToMacHex:(NSString *)macDecimal {
    //Step 1: Conversion from decimal to hexadecimal
    DLog(@"%llu", (unsigned long long) [macDecimal longLongValue]);
    NSString *hexIP = [NSString stringWithFormat:@"%llX", (unsigned long long) [macDecimal longLongValue]];

    NSMutableString *wifiMAC = [[NSMutableString alloc] init];
    //Step 2: Divide in pairs of 2 hex
    for (NSUInteger i = 0; i < [hexIP length]; i = i + 2) {
        NSString *ichar = [NSString stringWithFormat:@"%c%c:", [hexIP characterAtIndex:i], [hexIP characterAtIndex:i + 1]];
        [wifiMAC appendString:ichar];
    }

    [wifiMAC deleteCharactersInRange:NSMakeRange([wifiMAC length] - 1, 1)];

    DLog(@"WifiMAC: %@", wifiMAC);
    return wifiMAC;
}

+ (NSString *)convertMacHexToDecimal:(NSString *)macHex {
    if (!macHex) {
        return nil;
    }

    NSString *cleaned = [macHex stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:cleaned];

    unsigned long long int result = 0;
    BOOL success = [scanner scanHexLongLong:&result];
    if (!success) {
        
        return @"9999999999";
    }

    NSNumber *number = @(result);
    return number.stringValue;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.linkType = SFIAlmondPlusLinkType_cloud_local;
    }

    return self;
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        self.almondplusMAC = [coder decodeObjectForKey:@"self.almondplusMAC"];
        self.almondplusName = [coder decodeObjectForKey:@"self.almondplusName"];
        self.firmware = [coder decodeObjectForKey:@"self.firmware"];
        self.index = [coder decodeIntForKey:@"self.index"];
        self.colorCodeIndex = [coder decodeIntForKey:@"self.colorCodeIndex"];
        //PY 190914 - Owned Almond information
        self.userCount = [coder decodeIntForKey:@"self.userCount"];
        self.accessEmailIDs = [coder decodeObjectForKey:@"self.accessEmailIDs"];
        self.isExpanded = [coder decodeBoolForKey:@"self.isExpanded"];
        self.ownerEmailID = [coder decodeObjectForKey:@"self.ownerEmailID"];
        self.linkType = (enum SFIAlmondPlusLinkType) [coder decodeIntForKey:@"self.linkType"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt32:1 forKey:@"self.schemaVersion"]; // for future use/expansion; version this schema

    [coder encodeObject:self.almondplusMAC forKey:@"self.almondplusMAC"];
    [coder encodeObject:self.almondplusName forKey:@"self.almondplusName"];
    [coder encodeObject:self.firmware forKey:@"self.firmware"];
    [coder encodeInt:self.index forKey:@"self.index"];
    [coder encodeInt:self.colorCodeIndex forKey:@"self.colorCodeIndex"];

    //PY 190914 - Owned Almond information
    [coder encodeInt:self.userCount forKey:@"self.userCount"];
    [coder encodeObject:self.accessEmailIDs forKey:@"self.accessEmailIDs"];
    [coder encodeBool:self.isExpanded forKey:@"self.isExpanded"];
    [coder encodeObject:self.ownerEmailID forKey:@"self.ownerEmailID"];

    [coder encodeInt:self.linkType forKey:@"self.linkType"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.almondplusMAC=%@", self.almondplusMAC];
    [description appendFormat:@", self.almondplusName=%@", self.almondplusName];
    [description appendFormat:@", self.firmware=%@", self.firmware];
    [description appendFormat:@", self.index=%i", self.index];
    [description appendFormat:@", self.colorCodeIndex=%i", self.colorCodeIndex];
    [description appendFormat:@", self.userCount=%i", self.userCount];
    [description appendFormat:@", self.accessEmailIDs=%@", self.accessEmailIDs];
    [description appendFormat:@", self.isExpanded=%d", self.isExpanded];
    [description appendFormat:@", self.ownerEmailID=%@", self.ownerEmailID];
    [description appendFormat:@", self.linkType=%i", self.linkType];
    [description appendString:@">"];
    return description;
}

- (id)copyWithZone:(NSZone *)zone {
    SFIAlmondPlus *copy = (SFIAlmondPlus *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.almondplusMAC = self.almondplusMAC;
        copy.almondplusName = self.almondplusName;
        copy.firmware = self.firmware;
        copy.index = self.index;
        copy.colorCodeIndex = self.colorCodeIndex;
        copy.userCount = self.userCount;
        copy.accessEmailIDs = self.accessEmailIDs;
        copy.isExpanded = self.isExpanded;
        copy.ownerEmailID = self.ownerEmailID;
        copy.linkType = self.linkType;
    }

    return copy;
}

- (BOOL)supportsSendLogs:(NSString *)almondVersion {
    if (!almondVersion) {
        return NO;
    }

    almondVersion = [almondVersion uppercaseString];

    /*
    The Almond  versions that support send logs are
    R087 for v2
    R073 for almond+
    for cox we are not supporting it.
     */

    AlmondVersionCheckerResult result = AlmondVersionCheckerResult_cannotCompare;
    if ([almondVersion hasPrefix:@"AL2-"]) {
        result = [AlmondVersionChecker compareVersions:almondVersion currentVersion:@"AL2-R087"];
    }
    else if ([almondVersion hasPrefix:@"AP2-"]) {
        result = [AlmondVersionChecker compareVersions:almondVersion currentVersion:@"AP2-R073"];
    }

    return (result == AlmondVersionCheckerResult_currentSameAsLatest) || (result == AlmondVersionCheckerResult_currentOlderThanLatest);
}

- (BOOL)supportsGenericIndexes:(NSString *)almondVersion{
    if (!almondVersion) {
        return NO;
    }
    NSLog(@"almondversion: %@", almondVersion);
    //latest is what almond has, current is constant
    //AL2-R092 and above supports generic indexes
    //AP2-R086 and above supports generic indexes
//    almondVersion = [almondVersion uppercaseString];
    BOOL result = NO;
    //"a" just to make sure internal beta's also support.
    if ([almondVersion hasPrefix:@"AL2-"]) {
        result = [self compareVersions:almondVersion supportedVersion:@"AL2-R091a"];
    }
    else if ([almondVersion hasPrefix:@"AP2-"]) {
        result = [self compareVersions:almondVersion supportedVersion:@"AP2-R085a"];
    }
    else if([almondVersion hasPrefix:@"AL3-"]){
        result = YES;
    }
    else if([almondVersion hasPrefix:@"A1A-"]){
        result = [self compareVersions:almondVersion supportedVersion:@"A1A-R007"];
    }
    NSLog(@"result: %d", result);
    return result;
}


- (BOOL)compareVersions:(NSString *)almondVersion supportedVersion:(NSString *)supportedVersion {
    if (!almondVersion || !supportedVersion) {
        return NO;
    }
    
    NSArray *cur_alm_splits = [almondVersion componentsSeparatedByString:@"-"];
    NSArray *supported_alm_splits = [supportedVersion componentsSeparatedByString:@"-"];
    
    
    if (supported_alm_splits.count < 2 || cur_alm_splits.count < 2) {
        return NO;
    }
    
    NSString *current_str = cur_alm_splits[1];
    NSString *supported_str = supported_alm_splits[1];
    
    NSLog(@"currentstr: %@, supportedstr: %@", current_str, supported_str);
    NSComparisonResult result = [current_str compare:supported_str];
    NSLog(@"result %d", result);
    switch (result) {
        case NSOrderedAscending:
            return NO;
        case NSOrderedSame:
            return YES;
        case NSOrderedDescending:
            return YES;
        default:
            return NO;
    }
}

- (BOOL)isEqualAlmondPlus:(SFIAlmondPlus *)other {
    if (!other) {
        return NO;
    }

    if (self == other) {
        return YES;
    }

    NSString *this_mac = self.almondplusMAC;
    NSString *other_mac = other.almondplusMAC;
    if (!this_mac || !other_mac) {
        return NO;
    }

    return [this_mac isEqualToString:other_mac];
}

+ (BOOL)checkIfFirmwareIsCompatible:(SFIAlmondPlus *)almond{
//    SFIAlmondPlus *currentAlmond = [[SecurifiToolkit sharedInstance] currentAlmond];
//    BOOL local = [[SecurifiToolkit sharedInstance] useLocalNetwork:currentAlmond.almondplusMAC];
    
    //Ignoring the screen when firmware is nil
    if(almond.firmware == nil){
        return YES;
    }
    return [almond supportsGenericIndexes:almond.firmware];
}

@end
