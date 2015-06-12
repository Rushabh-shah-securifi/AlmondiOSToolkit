//
//  SFIOfflineDataManager.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIOfflineDataManager.h"
#import "AlmondPlusSDKConstants.h"
#import "SFIAlmondPlus.h"

@interface SFIOfflineDataManager ()
@property(nonatomic, readonly) NSObject *syncLocker;
@property(nonatomic, readonly) NSObject *notification_syncLocker;
@property(nonatomic, readonly) NSString *almondListFp;
@property(nonatomic, readonly) NSString *hashFp;
@property(nonatomic, readonly) NSString *deviceListFp;
@property(nonatomic, readonly) NSString *deviceValueFp;
@property(nonatomic, readonly) NSString *notificationPreferenceListFp;
@property(nonatomic, readonly) NSMutableSet *markedForBackupExclusionPaths;
@end

@implementation SFIOfflineDataManager

- (id)init {
    self = [super init];
    if (self) {
        _syncLocker = [NSObject new];
        _notification_syncLocker = [NSObject new];

        _almondListFp = [SFIOfflineDataManager filePathForName:ALMONDLIST_FILENAME];
        _hashFp = [SFIOfflineDataManager filePathForName:HASH_FILENAME];
        _deviceListFp = [SFIOfflineDataManager filePathForName:DEVICELIST_FILENAME];
        _deviceValueFp = [SFIOfflineDataManager filePathForName:DEVICEVALUE_FILENAME];
        _notificationPreferenceListFp = [SFIOfflineDataManager filePathForName:NOTIFICATION_PREF_FILENAME];

        // ensure data files are excluded from iCloud backup:
        // add all paths that need to be excluded
        _markedForBackupExclusionPaths = [NSMutableSet setWithArray:@[
                self.almondListFp,
                self.hashFp,
                self.deviceListFp,
                self.deviceValueFp,
                self.notificationPreferenceListFp
        ]];

        // try to exclude them now if they exist; otherwise, will be excluded on creation
        for (NSString *path in self.markedForBackupExclusionPaths.copy) {
            [self markExcludeFileFromBackup:path];
        }
    }

    return self;
}

- (void)markExcludeFileFromBackup:(NSString*)filePath {
    if (![self.markedForBackupExclusionPaths containsObject:filePath]) {
        // fail fast; if already removed from set, no longer need to try excluding
        return;
    }

    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!exists) {
        // wait until the file has been created for first time
        return;
    }

    NSURL *url = [NSURL fileURLWithPath:filePath];

    NSError *error;
    BOOL success = [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (success) {
        [self.markedForBackupExclusionPaths removeObject:filePath];
        NSLog(@"SFIOfflineDataManager: Marked for backup exclusion: %@", filePath);
    }
    else {
        NSLog(@"SFIOfflineDataManager: Error excluding %@ from backup %@", filePath, error);
    }
}

- (void)writeAlmondList:(NSArray *)arrayAlmondList {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.almondListFp;

        NSArray *arAlmondList = [arrayAlmondList copy];
        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:arAlmondList toFile:filePath];
        if (didWriteSuccessful) {
            [self markExcludeFileFromBackup:filePath];
        }
        else {
            NSLog(@"Failed to write almond list");
        }
    }
}


// Read AlmondList for the current user from offline storage
- (NSArray *)readAlmondList {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.almondListFp;

        NSArray *arAlmondList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        return [NSMutableArray arrayWithArray:arAlmondList];
    }
}

// Write HashList for the current user to offline storage
- (void)writeHashList:(NSString *)strHashValue currentMAC:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.hashFp;

        NSMutableDictionary *mutableDictHashList = [NSMutableDictionary dictionary];
        [mutableDictHashList setValue:strHashValue forKey:strCurrentMAC];

        NSDictionary *dictHashList = [mutableDictHashList copy];

        //Write
        BOOL didWriteSuccessful = [dictHashList writeToFile:filePath atomically:YES];
        if (didWriteSuccessful) {
            [self markExcludeFileFromBackup:filePath];
        }
        else {
            NSLog(@"Failed to write hash list");
        }
    }
}

// Read HashList for the current user from offline storage
- (NSString *)readHashList:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.hashFp;

        NSDictionary *dictHashList = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSString *strHashValue = [dictHashList valueForKey:strCurrentMAC];
        return strHashValue;
    }
}

- (void)purgeAll {
    @synchronized (self.syncLocker) {
        [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
        [SFIOfflineDataManager deleteFile:HASH_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
        [SFIOfflineDataManager deleteFile:NOTIFICATION_PREF_FILENAME];
    }
}

- (NSArray *)deleteAlmond:(SFIAlmondPlus *)deletedAlmond {
    @synchronized (self.syncLocker) {
        // Diff the current list, removing the deleted almond
        NSArray *currentAlmondList = [self readAlmondList];
        NSMutableArray *newAlmondList = [NSMutableArray array];

        NSString *mac = deletedAlmond.almondplusMAC;

        // Update Almond List
        for (SFIAlmondPlus *current in currentAlmondList) {
            if (![current.almondplusMAC isEqualToString:mac]) {
                [newAlmondList addObject:current];
            }
        }

        [self writeAlmondList:newAlmondList];

        [self deleteHashForAlmond:mac];
        [self deleteDeviceDataForAlmond:mac];
        [self deleteDeviceValueForAlmond:mac];
        [self deleteNotificationPreferenceList:mac];

        return newAlmondList;
    }
}

// Delete HashList for the deleted almond from offline storage
- (void)deleteHashForAlmond:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.hashFp;

        //Remove current hash from the dictionary
        NSMutableDictionary *mutableDictHashList = [[NSDictionary dictionaryWithContentsOfFile:filePath] mutableCopy];
        [mutableDictHashList removeObjectForKey:strCurrentMAC];

        NSDictionary *dictHashList = [mutableDictHashList copy];
        [dictHashList writeToFile:filePath atomically:YES];

        [self markExcludeFileFromBackup:filePath];
    }
}

// Write Device List for the current MAC to offline storage
- (void)writeDeviceList:(NSArray *)deviceList currentMAC:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.deviceListFp;

        //Read the entire dictionary from the list
        NSMutableDictionary *dictDeviceList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (dictDeviceList == nil) {
            // [SNLog Log:@"Method Name: %s First time write!", __PRETTY_FUNCTION__];
            dictDeviceList = [[NSMutableDictionary alloc] init];
        }
        dictDeviceList[strCurrentMAC] = deviceList;

        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:dictDeviceList toFile:filePath];
        if (didWriteSuccessful) {
            [self markExcludeFileFromBackup:filePath];
        }
        else {
            NSLog(@"Faile to write device list");
        }
    }
}

// Read DeviceList for the current MAC from offline storage
- (NSArray *)readDeviceList:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.deviceListFp;

        NSMutableDictionary *dictDeviceList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

        NSMutableArray *deviceList = nil;
        if (dictDeviceList != nil) {
            deviceList = [dictDeviceList valueForKey:strCurrentMAC];
        }
        return deviceList;
    }
}

// Delete DeviceList for the deleted almond from offline storage
- (void)deleteDeviceDataForAlmond:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.deviceListFp;

        NSMutableDictionary *dictDeviceList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

        [dictDeviceList removeObjectForKey:strCurrentMAC];
        [NSKeyedArchiver archiveRootObject:dictDeviceList toFile:filePath];

        [self markExcludeFileFromBackup:filePath];
    }
}


// Write DeviceValueList for the current MAC to offline storage
- (void)writeDeviceValueList:(NSArray *)deviceValueList currentMAC:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.deviceValueFp;

        //Read the entire dictionary from the list
        NSMutableDictionary *dictDeviceValueList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (dictDeviceValueList == nil) {
            // [SNLog Log:@"Method Name: %s First time write!", __PRETTY_FUNCTION__];
            dictDeviceValueList = [[NSMutableDictionary alloc] init];
        }
        dictDeviceValueList[strCurrentMAC] = deviceValueList;

        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:dictDeviceValueList toFile:filePath];
        if (didWriteSuccessful) {
            [self markExcludeFileFromBackup:filePath];
        }
        else {
            NSLog(@"Failed to write device value list");
        }
    }
}

// Read DeviceValueList for the current MAC from offline storage
- (NSArray *)readDeviceValueList:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.deviceValueFp;

        NSMutableDictionary *dictDeviceValueList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

        NSMutableArray *deviceValueList = nil;
        if (dictDeviceValueList != nil) {
            deviceValueList = [dictDeviceValueList valueForKey:strCurrentMAC];
        }
        return deviceValueList;
    }
}

// Delete DeviceValueList for the deleted almond from offline storage
- (void)deleteDeviceValueForAlmond:(NSString *)strCurrentMAC {
    NSString *filePath = self.deviceValueFp;

    NSMutableDictionary *dictDeviceValueList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    [dictDeviceValueList removeObjectForKey:strCurrentMAC];
    [NSKeyedArchiver archiveRootObject:dictDeviceValueList toFile:filePath];

    [self markExcludeFileFromBackup:filePath];
}


// Write Notification Preference List for the current MAC to offline storage
- (void)writeNotificationPreferenceList:(NSArray *)notificationList currentMAC:(NSString *)strCurrentMAC {
    @synchronized (self.notification_syncLocker) {
        NSString *filePath = self.notificationPreferenceListFp;
        
        //Read the entire dictionary from the list
        NSMutableDictionary *dictNotificationList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (dictNotificationList == nil) {
            dictNotificationList = [[NSMutableDictionary alloc] init];
        }
        dictNotificationList[strCurrentMAC] = notificationList;
        
        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:dictNotificationList toFile:filePath];
        if (didWriteSuccessful) {
            [self markExcludeFileFromBackup:filePath];
        }
        else {
            NSLog(@"Failed to write notification list");
        }
    }
}

// Read Notification Preference List for the current MAC from offline storage
- (NSArray *)readNotificationPreferenceList:(NSString *)strCurrentMAC {
    @synchronized (self.notification_syncLocker) {
        NSString *filePath = self.notificationPreferenceListFp;
        
        NSMutableDictionary *dictNotificationList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        
        NSMutableArray *notificationList = nil;
        if (dictNotificationList != nil) {
            notificationList = [dictNotificationList valueForKey:strCurrentMAC];
        }
        return notificationList;
    }
}

// Read Notification Preference List for the current MAC from offline storage
- (void)deleteNotificationPreferenceList:(NSString *)strCurrentMAC {
    if (strCurrentMAC == nil) {
        return;
    }

    @synchronized (self.notification_syncLocker) {
        NSString *filePath = self.notificationPreferenceListFp;

        NSMutableDictionary *dictNotificationList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        [dictNotificationList removeObjectForKey:strCurrentMAC];

        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:dictNotificationList toFile:filePath];
        if (didWriteSuccessful) {
            [self markExcludeFileFromBackup:filePath];
        }
        else {
            NSLog(@"Failed to write notification list");
        }
    }
}

+ (BOOL)deleteFile:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];

    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];

    if (!success) {
        NSLog(@"Failed to remove file, path:%@, error:%@", filePath, error);
    }

    return success;
}

+ (NSString *)filePathForName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
