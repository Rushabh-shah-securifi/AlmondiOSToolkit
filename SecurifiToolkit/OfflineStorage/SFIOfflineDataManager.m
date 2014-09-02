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
@property(nonatomic, readonly) NSString *almondListFp;
@property(nonatomic, readonly) NSString *hashFp;
@property(nonatomic, readonly) NSString *deviceListFp;
@property(nonatomic, readonly) NSString *deviceValueFp;
@end

@implementation SFIOfflineDataManager

- (id)init {
    self = [super init];
    if (self) {
        _syncLocker = [NSObject new];

        _almondListFp = [SFIOfflineDataManager filePathForName:ALMONDLIST_FILENAME];
        _hashFp = [SFIOfflineDataManager filePathForName:HASH_FILENAME];
        _deviceListFp = [SFIOfflineDataManager filePathForName:DEVICELIST_FILENAME];
        _deviceValueFp = [SFIOfflineDataManager filePathForName:DEVICEVALUE_FILENAME];
    }

    return self;
}


- (void)writeAlmondList:(NSArray *)arrayAlmondList {
    @synchronized (self.syncLocker) {
        NSString *filePath = self.almondListFp;

        NSArray *arAlmondList = [arrayAlmondList copy];
        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:arAlmondList toFile:filePath];
        if (!didWriteSuccessful) {
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
        if (!didWriteSuccessful) {
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
        if (!didWriteSuccessful) {
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
        if (!didWriteSuccessful) {
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
}

+ (BOOL)deleteFile:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    return success;
}

+ (NSString *)filePathForName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
