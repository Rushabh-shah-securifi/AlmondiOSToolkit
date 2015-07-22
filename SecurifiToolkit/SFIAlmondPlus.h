//
//  SFIAlmondPlus.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIAlmondPlus : NSObject <NSCoding, NSCopying>

+ (NSString*)convertDecimalToMacHex:(NSString*)decimal;

+ (NSString*)convertMacHexToDecimal:(NSString*)decimal;

@property(nonatomic, copy) NSString *almondplusMAC;
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

// indicates whether the Almond router supports the "send logs to the cloud" functionality
- (BOOL)supportsSendLogs:(NSString *)almondVersion;

- (BOOL)isEqualAlmondPlus:(SFIAlmondPlus *)other;

@end
