//
//  SFIAlmondPlus.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIAlmondPlus : NSObject <NSCoding, NSCopying>

+ (NSString*)convertDecimalToMacHex:(NSString*)macDecimal;

+ (NSString*)convertMacHexToDecimal:(NSString*)macHex;

@property(nonatomic, copy) NSString *almondplusMAC; // mac decimal value
@property(nonatomic, copy) NSString *almondplusName;
@property(nonatomic) int index;
@property(nonatomic) int colorCodeIndex;

@property(nonatomic) int userCount;
@property(nonatomic) NSMutableArray *accessEmailIDs;
@property(nonatomic) BOOL isExpanded;
@property(nonatomic, copy) NSString *ownerEmailID;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

// indicates whether the Almond router supports the "send logs to the cloud" functionality.
// the version string is attained dynamically from the almond, and this method tests whether it is a
// current enough version.
- (BOOL)supportsSendLogs:(NSString *)almondVersion;

- (BOOL)isEqualAlmondPlus:(SFIAlmondPlus *)other;

@end
