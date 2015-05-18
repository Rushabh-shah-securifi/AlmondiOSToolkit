//
//  SFIAlmondPlus.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIAlmondPlus : NSObject <NSCoding, NSCopying>

@property(nonatomic) NSString *almondplusMAC;
@property(nonatomic) NSString *almondplusName;
@property(nonatomic) int index;
@property(nonatomic) int colorCodeIndex;

@property(nonatomic) int userCount;
@property(nonatomic) NSMutableArray *accessEmailIDs;
@property(nonatomic) BOOL isExpanded;
@property(nonatomic) NSString *ownerEmailID;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

// indicates whether the Almond router supports the "send logs to the cloud" functionality
- (BOOL)supportsSendLogs:(NSString*)almondVersion;

- (BOOL)isEqualAlmondPlus:(SFIAlmondPlus*)other;

@end
