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
                    return;
                }

                NSData *data = [NSData dataWithContentsOfURL:location];
                if (data.length == 0) {
                    return;
                }

                NSString *latestVersion = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (!latestVersion) {
                    return;
                }

                if (![self isNewerVersion:latestVersion currentVersion:currentVersion]) {
                    return;
                }

                [self.delegate versionCheckerDidFindNewerVersion:almond currentVersion:currentVersion latestVersion:latestVersion];
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
    else {
        // not recognized version
        return nil;
    }
}

- (BOOL)isNewerVersion:(NSString *)latest currentVersion:(NSString *)current {
    if (!latest || !current) {
        return NO;
    }

    NSArray *latest_splits = [latest componentsSeparatedByString:@"-"];
    NSArray *current_splits = [current componentsSeparatedByString:@"-"];

    if (latest_splits.count < 2 || current_splits.count < 2) {
        return NO;
    }

    NSString *latest_str = latest_splits[1];
    NSString *current_str = current_splits[1];

    NSComparisonResult result = [latest_str compare:current_str];
    return result == NSOrderedDescending;
}

@end