//
// Created by Matthew Sinclair-Day on 5/13/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFIAlmondPlus;

typedef NS_ENUM(unsigned int, AlmondVersionCheckerResult) {
    AlmondVersionCheckerResult_cannotCompare,
    AlmondVersionCheckerResult_currentSameAsLatest,
    AlmondVersionCheckerResult_currentOlderThanLatest,
    AlmondVersionCheckerResult_currentNewerThanLatest,
};

@protocol AlmondVersionCheckerDelegate

- (void)versionCheckerDidQueryVersion:(SFIAlmondPlus *)almond
                               result:(enum AlmondVersionCheckerResult)result
                       currentVersion:(NSString *)currentVersion
                        latestVersion:(NSString *)latestAlmondVersion;

@end

@interface AlmondVersionChecker : NSObject

@property(weak) id <AlmondVersionCheckerDelegate> delegate;

- (void)asyncCheckLatestVersion:(SFIAlmondPlus *)almond currentVersion:(NSString *)currentVersion;

+ (AlmondVersionCheckerResult)compareVersions:(NSString *)latestVersion currentVersion:(NSString *)currentVersion;

@end