//
// Created by Matthew Sinclair-Day on 5/13/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "AlmondVersionChecker.h"
#import "SFIAlmondPlus.h"


@implementation AlmondVersionChecker

- (void)asyncCheckLatestVersion:(SFIAlmondPlus *)almond currentVersion:(NSString *)currentVersion {
    NSURL *url = [self checkVersionUrl:currentVersion];
    if (!url) {
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session
                                      downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                          if (error) {
                                              [self.delegate versionCheckerDidQueryVersion:almond result:AlmondVersionCheckerResult_cannotCompare currentVersion:currentVersion latestVersion:nil];
                                              return;
                                          }
                                          
                                          NSData *data = [NSData dataWithContentsOfURL:location];
                                          if (data.length == 0) {
                                              [self.delegate versionCheckerDidQueryVersion:almond result:AlmondVersionCheckerResult_cannotCompare currentVersion:currentVersion latestVersion:nil];
                                              return;
                                          }
                                          
                                          NSString *latestVersion = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          if (!latestVersion) {
                                              [self.delegate versionCheckerDidQueryVersion:almond result:AlmondVersionCheckerResult_cannotCompare currentVersion:currentVersion latestVersion:nil];
                                              return;
                                          }
                                          
                                          AlmondVersionCheckerResult result = [AlmondVersionChecker compareVersions:latestVersion currentVersion:currentVersion];
                                          [self.delegate versionCheckerDidQueryVersion:almond result:result currentVersion:currentVersion latestVersion:latestVersion];
                                      }];
    
    [task resume];
}

/*
 To get the latest version we need to send a request to
 
 https://firmware.securifi.com/CA1/version [cox]
 https://firmware.securifi.com/AL2/version [al2]
 https://firmware.securifi.com/AP2/version [ap2]
 
 */
- (NSURL *)checkVersionUrl:(NSString *)almondVersion {
    if (!almondVersion) {
        return nil;
    }
    
    almondVersion = [almondVersion uppercaseString];
    
    if ([almondVersion hasPrefix:@"CA1"]) {
        return [NSURL URLWithString:@"https://firmware.securifi.com/CA1/version"];
    }
    else if ([almondVersion hasPrefix:@"AL2"]) {
        return [NSURL URLWithString:@"https://firmware.securifi.com/AL2/version"];
    }
    else if ([almondVersion hasPrefix:@"AP2"]) {
        return [NSURL URLWithString:@"https://firmware.securifi.com/AP2/version"];
    }
    else if ([almondVersion hasPrefix:@"A1A"]) {
        return [NSURL URLWithString:@"https://firmware.securifi.com/A1A/version"];
    }
    
    else if ([almondVersion hasPrefix:@"AL3"]) {
        if([almondVersion rangeOfString:@"64" options:NSCaseInsensitiveSearch].location != NSNotFound){
            if([almondVersion rangeOfString:@"beta" options:NSCaseInsensitiveSearch].location != NSNotFound)
                return [NSURL URLWithString:@"https://firmware.securifi.com/AL3_64MB_BETA/version"];
            else
                return [NSURL URLWithString:@"https://firmware.securifi.com/AL3_64MB/version"];
        }
        else{
            return [NSURL URLWithString:@"https://firmware.securifi.com/AL3_BETA/version"];
        }
    }
    
    else {
        // not recognized version
        return nil;
    }
}

+ (AlmondVersionCheckerResult)compareVersions:(NSString *)latestVersion currentVersion:(NSString *)currentVersion {
    if (!latestVersion || !currentVersion) {
        return AlmondVersionCheckerResult_cannotCompare;
    }
    
    NSArray *latest_splits = [latestVersion componentsSeparatedByString:@"-"];
    NSArray *current_splits = [currentVersion componentsSeparatedByString:@"-"];
    
    if (latest_splits.count < 2 || current_splits.count < 2) {
        return AlmondVersionCheckerResult_cannotCompare;
    }
    
    NSString *latest_str = latest_splits[1];
    NSString *current_str = current_splits[1];
    
    NSComparisonResult result = [latest_str compare:current_str];
    
    switch (result) {
        case NSOrderedAscending:
            return AlmondVersionCheckerResult_currentNewerThanLatest;
        case NSOrderedSame:
            return AlmondVersionCheckerResult_currentSameAsLatest;
        case NSOrderedDescending:
            return AlmondVersionCheckerResult_currentOlderThanLatest;
        default:
            return AlmondVersionCheckerResult_cannotCompare;
    }
}

@end
