//
// Created by Matthew Sinclair-Day on 5/13/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFIAlmondPlus;

@protocol AlmondVersionCheckerDelegate

- (void)versionCheckerDidFindNewerVersion:(SFIAlmondPlus *)almond currentVersion:(NSString *)currentVersion latestVersion:(NSString *)latestAlmondVersion;

@end

@interface AlmondVersionChecker : NSObject

@property(weak) id <AlmondVersionCheckerDelegate> delegate;

- (void)asyncCheckLatestVersion:(SFIAlmondPlus *)almond currentVersion:(NSString *)currentVersion;

@end