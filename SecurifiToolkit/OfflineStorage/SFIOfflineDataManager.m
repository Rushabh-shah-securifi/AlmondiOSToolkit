//
//  SFIOfflineDataManager.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIOfflineDataManager.h"
#import "SFIAlmondPlus.h"
#import "SFIAlmondLocalNetworkSettings.h"

#define ALMOND_LIST_FILENAME @"almondlist"
#define HASH_FILENAME @"almondhashes"
#define DEVICE_LIST_FILENAME  @"devicelist"
#define DEVICE_VALUE_FILENAME @"devicevalue"
#define NOTIFICATION_PREF_FILENAME @"notificationpreference"
#define ALMOND_LOCAL_NETWORK_SETTINGS_FILENAME @"almondlocalnet"

@interface SFIOfflineDataManager ()
@property(nonatomic, readonly) NSObject *syncLocker;
@property(nonatomic, readonly) NSObject *notification_syncLocker;
@property(nonatomic, readonly) NSString *almondListFp;
@property(nonatomic, readonly) NSString *hashFp;
@property(nonatomic, readonly) NSString *deviceListFp;
@property(nonatomic, readonly) NSString *deviceValueFp;
@property(nonatomic, readonly) NSString *notificationPreferenceListFp;
@property(nonatomic, readonly) NSString *almondLocalNetworkSettingsFp;
@property(nonatomic, readonly) NSMutableSet *markedForBackupExclusionPaths;
@end

@implementation SFIOfflineDataManager

- (id)init {
    self = [super init];
    if (self) {
        _syncLocker = [NSObject new];
        _notification_syncLocker = [NSObject new];

        _almondListFp = [SFIOfflineDataManager filePathForName:ALMOND_LIST_FILENAME];
        _hashFp = [SFIOfflineDataManager filePathForName:HASH_FILENAME];
        _deviceListFp = [SFIOfflineDataManager filePathForName:DEVICE_LIST_FILENAME];
        _deviceValueFp = [SFIOfflineDataManager filePathForName:DEVICE_VALUE_FILENAME];
        _notificationPreferenceListFp = [SFIOfflineDataManager filePathForName:NOTIFICATION_PREF_FILENAME];
        _almondLocalNetworkSettingsFp = [SFIOfflineDataManager filePathForName:ALMOND_LOCAL_NETWORK_SETTINGS_FILENAME];

        // ensure data files are excluded from iCloud backup:
        // add all paths that need to be excluded
        _markedForBackupExclusionPaths = [NSMutableSet setWithArray:@[
                self.almondListFp,
                self.hashFp,
                self.deviceListFp,
                self.deviceValueFp,
                self.notificationPreferenceListFp,
                self.almondLocalNetworkSettingsFp
        ]];

        // try to exclude them now if they exist; otherwise, will be excluded on creation
        for (NSString *path in self.markedForBackupExclusionPaths.copy) {
            [self markExcludeFileFromBackup:path];
        }
    }

    return self;
}

#pragma mark - Almonds List

- (void)writeAlmondList:(NSArray *)almondList {
    [self writeListToFilePath:self.almondListFp list:almondList locker:self.syncLocker];
}

// Read AlmondList for the current user from offline storage
- (NSArray *)readAlmondList {
    return [self readListFromFilePath:self.almondListFp locker:self.syncLocker];
}

#pragma mark - Almonds Hash values

// Write HashList for the current user to offline storage
- (void)writeHashList:(NSString *)almondHashValue almondMac:(NSString *)almondMac {
    [self writeDictionaryEntryToFilePath:self.hashFp key:almondMac value:almondHashValue locker:self.syncLocker];
}

// Read HashList for the current user from offline storage
- (NSString *)readHashList:(NSString *)almondMac {
    return [self readDictionaryEntryForFilePath:self.hashFp key:almondMac locker:self.syncLocker];
}

#pragma mark - Almond Device List

// Write Device List for the current MAC to offline storage
- (void)writeDeviceList:(NSArray *)deviceList almondMac:(NSString *)almondMac {
    [self writeDictionaryEntryToFilePath:self.deviceListFp key:almondMac value:deviceList locker:self.syncLocker];
}

// Read DeviceList for the current MAC from offline storage
- (NSArray *)readDeviceList:(NSString *)almondMac {
    return [self readDictionaryEntryForFilePath:self.deviceListFp key:almondMac locker:self.syncLocker];
}

// Delete DeviceList for the deleted almond from offline storage
- (void)deleteDeviceDataForAlmond:(NSString *)almondMac {
    [self removedDictionaryEntryFromFilePath:self.deviceListFp key:almondMac locker:self.syncLocker];
}

#pragma mark - Device Values List

// Write DeviceValueList for the current MAC to offline storage
- (void)writeDeviceValueList:(NSArray *)deviceValueList almondMac:(NSString *)almondMac {
    [self writeDictionaryEntryToFilePath:self.deviceValueFp key:almondMac value:deviceValueList locker:self.syncLocker];
}

// Read DeviceValueList for the current MAC from offline storage
- (NSArray *)readDeviceValueList:(NSString *)almondMac {
    return [self readDictionaryEntryForFilePath:self.deviceValueFp key:almondMac locker:self.syncLocker];
}

- (void)removeAllDevices:(NSString *)almondMac {
    @synchronized (self.syncLocker) {
        [self removedDictionaryEntryFromFilePath:self.deviceListFp key:almondMac locker:self.syncLocker];
        [self removedDictionaryEntryFromFilePath:self.deviceValueFp key:almondMac locker:self.syncLocker];
    }
}

// Delete DeviceValueList for the deleted almond from offline storage
- (void)deleteDeviceValueForAlmond:(NSString *)almondMac {
    [self removedDictionaryEntryFromFilePath:self.deviceValueFp key:almondMac locker:self.syncLocker];
}

#pragma mark - Notification Preferences

// Write Notification Preference List for the current MAC to offline storage
- (void)writeNotificationPreferenceList:(NSArray *)notificationList almondMac:(NSString *)almondMac {
    [self writeDictionaryEntryToFilePath:self.notificationPreferenceListFp key:almondMac value:notificationList locker:self.notification_syncLocker];
}

// Read Notification Preference List for the current MAC from offline storage
- (NSArray *)readNotificationPreferenceList:(NSString *)almondMac {
    return [self readDictionaryEntryForFilePath:self.notificationPreferenceListFp key:almondMac locker:self.notification_syncLocker];
}

// Read Notification Preference List for the current MAC from offline storage
- (void)deleteNotificationPreferenceList:(NSString *)strCurrentMAC {
    [self removedDictionaryEntryFromFilePath:self.notificationPreferenceListFp key:strCurrentMAC locker:self.notification_syncLocker];
}

#pragma mark - Almond Local Network Settings

- (void)writeAlmondLocalNetworkSettings:(SFIAlmondLocalNetworkSettings *)settings {
    [self writeDictionaryEntryToFilePath:self.almondLocalNetworkSettingsFp key:settings.almondplusMAC value:settings locker:self.syncLocker];
}

- (SFIAlmondLocalNetworkSettings *)readALmondLocalNetworkSettings:(NSString *)almondMac {
    return [self readDictionaryEntryForFilePath:self.almondLocalNetworkSettingsFp key:almondMac locker:self.syncLocker];
}

- (void)deleteLocalNetworkSettingsForAlmond:(NSString *)strAlmondMac {
    [self removedDictionaryEntryFromFilePath:self.almondLocalNetworkSettingsFp key:strAlmondMac locker:self.syncLocker];
}

#pragma mark - Deletion

- (void)purgeAll {
    @synchronized (self.syncLocker) {
        [SFIOfflineDataManager deleteFile:ALMOND_LIST_FILENAME];
        [SFIOfflineDataManager deleteFile:HASH_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICE_LIST_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICE_VALUE_FILENAME];
        [SFIOfflineDataManager deleteFile:ALMOND_LOCAL_NETWORK_SETTINGS_FILENAME];

        @synchronized (self.notification_syncLocker) {
            [SFIOfflineDataManager deleteFile:NOTIFICATION_PREF_FILENAME];
        }
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

        @synchronized (self.notification_syncLocker) {
            [self deleteLocalNetworkSettingsForAlmond:mac];
        }

        return newAlmondList;
    }
}

// Delete HashList for the deleted almond from offline storage
- (void)deleteHashForAlmond:(NSString *)almondMac {
    [self removedDictionaryEntryFromFilePath:self.hashFp key:almondMac locker:self.syncLocker];
}

#pragma mark - Serialization Functions

- (NSArray *)readListFromFilePath:(NSString *)filePath locker:(NSObject *)locker {
    @synchronized (locker) {
        NSArray *ls = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (ls == nil) {
            ls = [NSArray array]; // no null pointers allowed
        }
        return ls;
    }
}

- (void)writeListToFilePath:(NSString *)filePath list:(NSArray *)list locker:(NSObject *)locker {
    @synchronized (locker) {
        NSArray *list_copy = [list copy];
        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:list_copy toFile:filePath];
        if (didWriteSuccessful) {
            [self markExcludeFileFromBackup:filePath];
        }
        else {
            NSLog(@"Failed to write almond list");
        }
    }
}

- (id)readDictionaryEntryForFilePath:(NSString *)filePath key:(NSString *)dictKey locker:(NSObject *)locker {
    @synchronized (locker) {
        NSMutableDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

        id value = nil;
        if (dictionary != nil) {
            value = [dictionary valueForKey:dictKey];
        }
        return value;
    }
}

- (void)writeDictionaryEntryToFilePath:(NSString *)filePath key:(NSString *)dictKey value:(id)dictValue locker:(NSObject *)locker {
    if (dictKey == nil) {
        return;
    }

    @synchronized (locker) {
        //Read the entire dictionary from the list
        NSMutableDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (dictionary == nil) {
            dictionary = [[NSMutableDictionary alloc] init];
        }
        dictionary[dictKey] = dictValue;

        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:dictionary toFile:filePath];
        if (didWriteSuccessful) {
            [self markExcludeFileFromBackup:filePath];
        }
        else {
            NSLog(@"Faile to write device list");
        }
    }
}

- (void)removedDictionaryEntryFromFilePath:(NSString *)filePath key:(NSString *)dictKey locker:(NSObject *)locker {
    if (dictKey == nil) {
        return;
    }

    @synchronized (locker) {
        NSMutableDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

        [dictionary removeObjectForKey:dictKey];
        [NSKeyedArchiver archiveRootObject:dictionary toFile:filePath];

        [self markExcludeFileFromBackup:filePath];
    }
}

#pragma mark - File management

- (void)markExcludeFileFromBackup:(NSString *)filePath {
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

+ (BOOL)deleteFile:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];

    BOOL exists = [fileManager fileExistsAtPath:filePath];
    if (!exists) {
        return YES;
    }

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
