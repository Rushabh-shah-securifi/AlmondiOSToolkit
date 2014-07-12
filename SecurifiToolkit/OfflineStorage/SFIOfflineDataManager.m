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
#import "SecurifiCloudResources-Prefix.pch"

@interface SFIOfflineDataManager ()
@property(nonatomic, readonly) NSObject *syncLocker;
@end

@implementation SFIOfflineDataManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once_predicate;
    static SFIOfflineDataManager *singleton = nil;

    dispatch_once(&once_predicate, ^{
        singleton = [SFIOfflineDataManager new];
    });

    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        _syncLocker = [NSObject new];
    }

    return self;
}


//Write AlmondList for the current user to offline storage
+ (BOOL)writeAlmondList:(NSArray *)arrayAlmondList {
    return [[SFIOfflineDataManager sharedInstance] _writeAlmondList:arrayAlmondList];
}

- (BOOL)_writeAlmondList:(NSArray *)arrayAlmondList {
    @synchronized (self.syncLocker) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:ALMONDLIST_FILENAME];

        NSArray *arAlmondList = [arrayAlmondList copy];
        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:arAlmondList toFile:filePath];
        // BOOL didWriteSuccessful = [arAlmondList writeToFile:filePath atomically:YES];
        return didWriteSuccessful;
    }
}


//Read AlmondList for the current user from offline storage
+ (NSMutableArray *)readAlmondList {
    return [[SFIOfflineDataManager sharedInstance] _readAlmondList];
}

//Read AlmondList for the current user from offline storage
- (NSMutableArray *)_readAlmondList {
    @synchronized (self.syncLocker) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:ALMONDLIST_FILENAME];

        //NSArray * arAlmondList = [NSArray arrayWithContentsOfFile:filePath];
        NSArray *arAlmondList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        // [SNLog Log:@"Method Name: %s Almond List: Size: %d", __PRETTY_FUNCTION__,[arAlmondList count]];
        return [NSMutableArray arrayWithArray:arAlmondList];
    }
}

//Write HashList for the current user to offline storage
+ (BOOL)writeHashList:(NSString *)strHashValue currentMAC:(NSString *)strCurrentMAC {
    return [[SFIOfflineDataManager sharedInstance] _writeHashList:strHashValue currentMAC:strCurrentMAC];
}

//Write HashList for the current user to offline storage
- (BOOL)_writeHashList:(NSString *)strHashValue currentMAC:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:HASH_FILENAME];

        NSMutableDictionary *mutableDictHashList = [NSMutableDictionary dictionary];
        [mutableDictHashList setValue:strHashValue forKey:strCurrentMAC];

        NSDictionary *dictHashList = [mutableDictHashList copy];

        //Write
        BOOL didWriteSuccessful = [dictHashList writeToFile:filePath atomically:YES];
        return didWriteSuccessful;
    }
}

//Read HashList for the current user from offline storage
+ (NSString *)readHashList:(NSString *)strCurrentMAC {
    return [[SFIOfflineDataManager sharedInstance] _readHashList:strCurrentMAC];
}

//Read HashList for the current user from offline storage
- (NSString *)_readHashList:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        // [SNLog Log:@"Method Name: %s Read from file! Hash List", __PRETTY_FUNCTION__];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:HASH_FILENAME];

        NSDictionary *dictHashList = [NSDictionary dictionaryWithContentsOfFile:filePath];
        //Read the current almond's device list from the hashmap
        NSString *strHashValue = [dictHashList valueForKey:strCurrentMAC];
        return strHashValue;
    }
}

+ (BOOL)purgeAll {
    return [[SFIOfflineDataManager sharedInstance] _purgeAll];
}

- (BOOL)_purgeAll {
    @synchronized (self.syncLocker) {
        [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
        [SFIOfflineDataManager deleteFile:HASH_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
        return YES;
    }
}

+ (NSArray*)deleteAlmond:(SFIAlmondPlus *)deletedAlmond {
    return [[SFIOfflineDataManager sharedInstance] _deleteAlmond:deletedAlmond];
}

- (NSArray*)_deleteAlmond:(SFIAlmondPlus *)deletedAlmond {
    @synchronized (self.syncLocker) {
        // Diff the current list, removing the deleted almond
        NSArray *currentAlmondList = [self _readAlmondList];
        NSMutableArray *newAlmondList = [NSMutableArray array];

        NSString *mac = deletedAlmond.almondplusMAC;

        // Update Almond List
        for (SFIAlmondPlus *current in currentAlmondList) {
            if (![current.almondplusMAC isEqualToString:mac]) {
                [newAlmondList addObject:current];
            }
        }

        [self _writeAlmondList:newAlmondList];

        [SFIOfflineDataManager deleteHashForAlmond:mac];
        [SFIOfflineDataManager deleteDeviceDataForAlmond:mac];
        [SFIOfflineDataManager deleteDeviceValueForAlmond:mac];

        return newAlmondList;
    }
}

//Delete HashList for the deleted almond from offline storage
+ (void)deleteHashForAlmond:(NSString *)strCurrentMAC {
    return [[SFIOfflineDataManager sharedInstance] _deleteHashForAlmond:strCurrentMAC];
}

//Delete HashList for the deleted almond from offline storage
- (void)_deleteHashForAlmond:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        // [SNLog Log:@"Method Name: %s Read from file! Delete Almond Hash", __PRETTY_FUNCTION__];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:HASH_FILENAME];

        //Remove current hash from the dictionary
        NSMutableDictionary *mutableDictHashList = [[NSDictionary dictionaryWithContentsOfFile:filePath] mutableCopy];
        [mutableDictHashList removeObjectForKey:strCurrentMAC];
        NSDictionary *dictHashList = [mutableDictHashList copy];
        [dictHashList writeToFile:filePath atomically:YES];
    }
}

//Write Device List for the current MAC to offline storage
+ (BOOL)writeDeviceList:(NSArray *)deviceList currentMAC:(NSString *)strCurrentMAC {
    return [[SFIOfflineDataManager sharedInstance] _writeDeviceList:deviceList currentMAC:strCurrentMAC];
}

//Write Device List for the current MAC to offline storage
- (BOOL)_writeDeviceList:(NSArray *)deviceList currentMAC:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        DLog(@"writing device list: %@ %@", strCurrentMAC, deviceList);

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICELIST_FILENAME];

        //Read the entire dictionary from the list
        NSMutableDictionary *dictDeviceList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (dictDeviceList == nil) {
            // [SNLog Log:@"Method Name: %s First time write!", __PRETTY_FUNCTION__];
            dictDeviceList = [[NSMutableDictionary alloc] init];
        }
        [dictDeviceList setObject:deviceList forKey:strCurrentMAC];
        //Create NSDictionary for List and AlmondPlusMAC
        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:dictDeviceList toFile:filePath];
        return didWriteSuccessful;
    }
}

//Read DeviceList for the current MAC from offline storage
+ (NSMutableArray *)readDeviceList:(NSString *)strCurrentMAC {
    return [[SFIOfflineDataManager sharedInstance] _readDeviceList:strCurrentMAC];
}

//Read DeviceList for the current MAC from offline storage
- (NSMutableArray *)_readDeviceList:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICELIST_FILENAME];

        NSMutableDictionary *dictDeviceList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

        NSMutableArray *deviceList = nil;
        if (dictDeviceList != nil) {
            deviceList = [dictDeviceList valueForKey:strCurrentMAC];
        }
        return deviceList;
    }
}

//Delete DeviceList for the deleted almond from offline storage
+ (void)deleteDeviceDataForAlmond:(NSString *)strCurrentMAC {
    return [[SFIOfflineDataManager sharedInstance] _deleteDeviceDataForAlmond:strCurrentMAC];
}

//Delete DeviceList for the deleted almond from offline storage
- (void)_deleteDeviceDataForAlmond:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICELIST_FILENAME];

        NSMutableDictionary *dictDeviceList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        //Remove the current almond's device list from the hashmap
        [dictDeviceList removeObjectForKey:strCurrentMAC];
        [NSKeyedArchiver archiveRootObject:dictDeviceList toFile:filePath];
    }
}


//Write DeviceValueList for the current MAC to offline storage
+ (BOOL)writeDeviceValueList:(NSArray *)deviceValueList currentMAC:(NSString *)strCurrentMAC {
    return [[SFIOfflineDataManager sharedInstance] _writeDeviceValueList:deviceValueList currentMAC:strCurrentMAC];
}

//Write DeviceValueList for the current MAC to offline storage
- (BOOL)_writeDeviceValueList:(NSArray *)deviceValueList currentMAC:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        DLog(@"writing device value list: %@ %@", strCurrentMAC, deviceValueList);

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICEVALUE_FILENAME];

        //Read the entire dictionary from the list
        NSMutableDictionary *dictDeviceValueList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (dictDeviceValueList == nil) {
            // [SNLog Log:@"Method Name: %s First time write!", __PRETTY_FUNCTION__];
            dictDeviceValueList = [[NSMutableDictionary alloc] init];
        }
        [dictDeviceValueList setObject:deviceValueList forKey:strCurrentMAC];
        //Create NSDictionary for List and AlmondPlusMAC
        BOOL didWriteSuccessful = [NSKeyedArchiver archiveRootObject:dictDeviceValueList toFile:filePath];
        return didWriteSuccessful;
    }
}

//Read DeviceValueList for the current MAC from offline storage
+ (NSArray *)readDeviceValueList:(NSString *)strCurrentMAC {
    return [[SFIOfflineDataManager sharedInstance] _readDeviceValueList:strCurrentMAC];
}

//Read DeviceValueList for the current MAC from offline storage
- (NSArray *)_readDeviceValueList:(NSString *)strCurrentMAC {
    @synchronized (self.syncLocker) {
        // [SNLog Log:@"Method Name: %s Read from file! Device Value List", __PRETTY_FUNCTION__];
        NSMutableArray *deviceValueList = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICEVALUE_FILENAME];

        NSMutableDictionary *dictDeviceValueList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        //Read the current almond's device list from the hashmap
        if (dictDeviceValueList != nil) {
            deviceValueList = [dictDeviceValueList valueForKey:strCurrentMAC];
        }
        return deviceValueList;
    }
}

//Delete DeviceValueList for the deleted almond from offline storage
+ (void)deleteDeviceValueForAlmond:(NSString *)strCurrentMAC {
    // [SNLog Log:@"Method Name: %s Read from file! Delete Almond Device Value List", __PRETTY_FUNCTION__];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DEVICEVALUE_FILENAME];

    NSMutableDictionary *dictDeviceValueList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    //Remove the current almond's device list from the hashmap
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
@end
