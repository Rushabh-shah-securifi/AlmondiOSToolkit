//
//  SFIOfflineDataManager.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFIAlmondPlus;

@interface SFIOfflineDataManager : NSObject

+ (BOOL)writeAlmondList:(NSArray *)arrayAlmondList;

+ (NSArray *)readAlmondList;

+ (BOOL)writeHashList:(NSString *)strHashValue currentMAC:(NSString *)strCurrentMAC;

+ (NSString *)readHashList:(NSString *)strCurrentMAC;

+ (BOOL)writeDeviceList:(NSArray *)deviceList currentMAC:(NSString *)strCurrentMAC;

+ (NSArray *)readDeviceList:(NSString *)strCurrentMAC;

+ (BOOL)writeDeviceValueList:(NSArray *)deviceValueList currentMAC:(NSString *)strCurrentMAC;

+ (NSArray *)readDeviceValueList:(NSString *)strCurrentMAC;

+ (BOOL)purgeAll;

// removes the specified Almond and returns the new Almond List
+ (NSArray*)deleteAlmond:(SFIAlmondPlus*)almond;

@end
