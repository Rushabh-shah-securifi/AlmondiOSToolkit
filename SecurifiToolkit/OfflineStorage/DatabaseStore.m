//
// Created by Matthew Sinclair-Day on 1/29/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "DatabaseStore.h"
#import "ZHDatabase.h"
#import "SFINotification.h"
#import "ZHDatabaseStatement.h"
#import "SFIDeviceKnownValues.h"
#import "SFINotificationStore.h"
#import "NSDate+Convenience.h"
#import "NotificationStoreImpl.h"

#define MAX_NOTIFICATIONS 1000
#define KEY_BADGE_COUNT @"badge_count"

/*

mac             => mac
users           => users
time            => time
data            => data
DevID           => deviceid
devicename      => devicename
devicetype      => devicetype
Index           => index
IndexName       => indexname
Value           => indexvalue


create table notifications (
    id integer primary key,
    mac varchar(24),
    users varchar(128),
    date_bucket double,
    time double,
    data text,
    deviceid integer,
    devicename varchar(256),
    value_index integer,
    value_indexname varchar(256),
    indexvalue varchar(20),
    viewed integer
);

create index notifications_time on notifications (time);
create index notifications_mac on notifications (mac, time);

 */

@interface DatabaseStore ()
@property(nonatomic, readonly) NSString *dbFilename;
@property(nonatomic, readonly) ZHDatabase *db;
@property(nonatomic, readonly) ZHDatabaseStatement *insert_notification;
@property(nonatomic, readonly) ZHDatabaseStatement *count_notification;
@property(nonatomic, readonly) ZHDatabaseStatement *trim_notifications;
@property(nonatomic, readonly) ZHDatabaseStatement *delete_notification;
@property(nonatomic, readonly) ZHDatabaseStatement *update_unread_count;
@property(nonatomic, readonly) ZHDatabaseStatement *read_metadata;
@property(nonatomic, readonly) ZHDatabaseStatement *insert_metadata;
@property(nonatomic, readonly) ZHDatabaseStatement *insert_syncpoint;
@property(nonatomic, readonly) ZHDatabaseStatement *delete_syncpoint;
@property(nonatomic, readonly) ZHDatabaseStatement *read_syncpoint;
@property(nonatomic, readonly) ZHDatabaseStatement *exists_syncpoint;
@property(nonatomic, readonly) dispatch_queue_t queue;
@property(nonatomic, readonly) BOOL trimRecords;
@end

@implementation DatabaseStore

+ (instancetype)notificationsDatabase {
    return [[DatabaseStore alloc] initWithDbFilename:@"toolkit_notifications.db" trimRecords:YES];
}

+ (instancetype)deviceLogsDatabase {
    return [[DatabaseStore alloc] initWithDbFilename:@"toolkit_devicelogs.db" trimRecords:NO];
}

- (instancetype)initWithDbFilename:(NSString *)dbFilename trimRecords:(BOOL)trimRecords {
    self = [super init];
    if (self) {
        _dbFilename = [dbFilename copy];
        _trimRecords = trimRecords;
        [self setup];
    }

    return self;
}

- (void)setup {
    NSURL *db_url = [self fileInDocumentsDirectoryPath:self.dbFilename];
    NSString *db_path = db_url.path;
    BOOL exists = [self fileExists:db_path];

    _db = [[ZHDatabase alloc] initWithPath:db_path];

//    exists = NO;
    if (!exists) {
        [self.db execute:@"drop table if exists notifications"];
        [self.db execute:@"create table notifications (id integer primary key, external_id varchar(128) unique not null, mac varchar(24), users varchar(128), date_bucket double, time double, data text, deviceid integer, devicename varchar(256), devicetype integer, value_index integer, value_indexname varchar(256), indexvalue varchar(20), viewed integer);"];
        [self.db execute:@"create index notifications_bucket on notifications (date_bucket, time);"];
        [self.db execute:@"create index notifications_time on notifications (time);"];
        [self.db execute:@"create index notifications_mac on notifications (mac, time);"];
        [self.db execute:@"create index notifications_mac_bucket on notifications (mac, date_bucket, time);"];
        [self.db execute:@"create index notifications_mac_bucket on notifications (mac, deviceid, date_bucket, time);"];
        [self.db execute:@"create index notifications_external_id on notifications (external_id);"];

        // a table for holding key-value pairs (schema version, last sync state, etc.)
        [self.db execute:@"drop table if exists notifications_meta"];
        [self.db execute:@"create table notifications_meta (meta_key varchar(128) primary key, meta_value_str varchar(128), meta_value_int integer, updated double);"];
        [self.db execute:@"create index notifications_meta_key on notifications_meta (meta_key);"];

        // a queue of sync points pending processing
        [self.db execute:@"drop table if exists notifications_syncpoints"];
        [self.db execute:@"create table notifications_syncpoints (syncpoint varchar(128) primary key, created double);"];
        [self.db execute:@"create index notifications_syncpoints_created on notifications_syncpoints (created);"];
    }

    // for security reasons, do not allow backups to iCloud
    [self markExcludeFileFromBackup:db_url];

    _insert_notification = [self.db newStatement:@"insert into notifications (external_id, mac, users, date_bucket, time, data, deviceid, devicename, devicetype, value_index, value_indexname, indexvalue, viewed) values (?,?,?,?,?,?,?,?,?,?,?,?,?)"];
    _count_notification = [self.db newStatement:@"select count(*) from notifications where external_id=?"];
    _trim_notifications = [self.db newStatement:@"delete from notifications where id in (select id from notifications order by time desc limit ? offset ?)"];
    _update_unread_count = [self.db newStatement:@"update notifications set viewed=? where time <= (select time from notifications order by time desc limit 1 offset ?)"];
    _delete_notification = [self.db newStatement:@"delete from notifications where mac=?"];

    _read_metadata = [self.db newStatement:@"select meta_value_str, meta_value_int, updated from notifications_meta where meta_key=?"];
    _insert_metadata = [self.db newStatement:@"insert or replace into notifications_meta (meta_key, meta_value_str, meta_value_int, updated) values (?,?,?,?);"];

    _insert_syncpoint = [self.db newStatement:@"insert into notifications_syncpoints (syncpoint, created) values (?,?)"];
    _delete_syncpoint = [self.db newStatement:@"delete from notifications_syncpoints where syncpoint=?"];
    _read_syncpoint = [self.db newStatement:@"select syncpoint from notifications_syncpoints order by created desc limit 1"];
    _exists_syncpoint = [self.db newStatement:@"select count(*) from notifications_syncpoints where syncpoint=?"];

    _queue = dispatch_queue_create("DatabaseStore", DISPATCH_QUEUE_SERIAL);
}

- (id <SFINotificationStore>)newNotificationStore {
    __block NotificationStoreImpl *n;

    dispatch_sync(self.queue, ^() {
        n = [[NotificationStoreImpl alloc] initWithDb:self.db queue:self.queue];
    });

    return n;
}

- (id <SFIDeviceLogStore>)newDeviceLogStore:(NSString *)almondMac deviceId:(sfi_id)deviceId delegate:(id <SFIDeviceLogStoreDelegate>)delegate {
    __block NotificationStoreImpl *n;

    dispatch_sync(self.queue, ^() {
        n = [[NotificationStoreImpl alloc] initWithDb:self.db queue:self.queue almondMac:almondMac deviceID:deviceId];
        n.delegate = delegate;
    });

    return n;
}

- (void)deleteNotificationsForAlmond:(NSString *)almondMAC {
    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.delete_notification;
        [stmt reset];
        [stmt bindNextText:almondMAC];
        [stmt execute];
    });
}

- (void)purgeAll {
    dispatch_sync(self.queue, ^() {
        [self.db execute:@"delete from notifications"];
        [self.db execute:@"delete from notifications_syncpoints"];
        [self.db execute:@"delete from notifications_meta"];
    });
}

- (BOOL)copyDatabaseTo:(NSString *)filePath {
    __block BOOL success;
    dispatch_sync(self.queue, ^() {
        success = [self.db copyTo:filePath];
    });
    return success;
}

#pragma mark - Private methods

- (BOOL)insertRecord:(SFINotification *)notification {
    if (!notification) {
        return NO;
    }

    BOOL exists = [self notificationExists:notification];
    if (exists) {
        return NO;
    }

    NSString *valueType = [SFIDeviceKnownValues propertyTypeToName:notification.valueType];

    // Make bucket time as of midnight of that day
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:notification.time];
    NSDate *midnight = [date dateAtMidnight];
    NSTimeInterval midnightTimeInterval = midnight.timeIntervalSince1970;

    __block BOOL success;
    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.insert_notification;
        [stmt reset];
        [stmt bindNextText:notification.externalId]; // external ID is unique across all records
        [stmt bindNextText:notification.almondMAC];
        [stmt bindNextText:@""]; // users
        [stmt bindNextTimeInterval:midnightTimeInterval]; // date_bucket
        [stmt bindNextTimeInterval:notification.time]; // time
        [stmt bindNextText:@""]; // data

        [stmt bindNextInteger:(ZHDatabase_int) notification.deviceId]; // deviceid
        [stmt bindNextText:notification.deviceName]; // devicename
        [stmt bindNextInteger:notification.deviceType]; // devicetype

        [stmt bindNextInteger:(ZHDatabase_int) notification.valueIndex]; // value_index
        [stmt bindNextText:valueType];  // value_indexname
        [stmt bindNextText:notification.value]; // indexvalue

        [stmt bindNextBool:notification.viewed]; // normally, this is NO for new notifications, but caller can control this

        success = [stmt execute];
        if (!success) {
            NSLog(@"Failed to insert notification into database, obj:%@", notification);
        }
    });

    return success;
}

- (BOOL)notificationExists:(SFINotification *)notification {
    NSString *externalId = notification.externalId;
    if (!externalId) {
        return NO;
    }

    __block long count = 0;

    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.count_notification;
        [stmt reset];
        [stmt bindNextText:externalId];

        if ([stmt step]) {
            count = [stmt stepNextInteger];
        }

        [stmt reset];
    });

    return count > 0;
}

// deletes up to numToDelete records number past the default offset. oldest records are deleted first.
// this keeps the database bounded
- (void)trimRecords:(int)numToDelete {
    if (!self.trimRecords) {
        return;
    }

    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.trim_notifications;
        [stmt reset];
        [stmt bindNextInteger:numToDelete];
        [stmt bindNextInteger:MAX_NOTIFICATIONS];
        [stmt execute];
    });
}

#pragma mark - File system utilities

//- (NSString *)fileInDocumentsDirectoryPath:(NSString *)aDatabaseFilename {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docsDir = paths[0];
//    NSString *dbPath = [docsDir stringByAppendingPathComponent:aDatabaseFilename];
//    return dbPath;
//}

- (BOOL)fileExists:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (NSURL *)fileInDocumentsDirectoryPath:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = paths[0];
    NSString *dbPath = [docsDir stringByAppendingPathComponent:filename];

    return [NSURL fileURLWithPath:dbPath];
//
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
//    // store in /Library/Application Support/BUNDLE_IDENTIFIER/
//    // make sure Application Support folder exists
//    NSError *error;
//    NSURL *dir = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
//    if (error) {
//        NSLog(@"DataStore: Could not create application support directory. %@", error);
//        return nil;
//    }
//
//    return [dir URLByAppendingPathComponent:filename isDirectory:NO];
}

- (void)markExcludeFileFromBackup:(NSURL*)filePath {
    NSError *error;
    BOOL success = [filePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (success) {
        NSLog(@"DataStore: Marked for backup exclusion: %@", filePath);
    }
    else {
        NSLog(@"DataStore: Error excluding %@ from backup %@", filePath, error);
    }
}

#pragma mark - Notifications api

- (NSInteger)storeNotifications:(NSArray *)notifications syncPoint:(NSString *)syncPoint {
    NSInteger count = 0;

    for (SFINotification *n in notifications) {
        BOOL stored = [self insertRecord:n];
        if (!stored) {
            break;
        }
        count++;
    }

    // keep the database tidy
    [self trimRecords:(int) notifications.count];

    [self removeSyncPoint:syncPoint];
    return count;
}

- (NSInteger)countTrackedSyncPoints {
    __block NSInteger count;

    dispatch_sync(self.queue, ^() {
        count = [self.db executeReturnInteger:@"select count(*) from notifications_syncpoints"];
    });

    return count;
}

- (NSString *)nextTrackedSyncPoint {
    __block NSString *next;

    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.read_syncpoint;
        [stmt reset];

        if ([stmt step]) {
            next = [stmt stepNextString];
        }

        [stmt reset];
    });

    return next;
}

- (void)removeSyncPoint:(NSString *)pageState {
    if (![self ensureDefinedSyncPoint:pageState]) {
        return;
    }

    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.delete_syncpoint;
        [stmt reset];
        [stmt bindNextText:pageState];
        [stmt execute];
    });
}

- (void)trackSyncPoint:(NSString *)pageState {
    if (![self ensureDefinedSyncPoint:pageState]) {
        return;
    }

    NSDate *date = [NSDate date];
    NSTimeInterval now = date.timeIntervalSince1970;

    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.insert_syncpoint;
        [stmt reset];
        [stmt bindNextText:pageState];
        [stmt bindNextTimeInterval:now];
        [stmt execute];
    });
}

- (BOOL)isTrackedSyncPoint:(NSString *)pageState {
    if (![self ensureDefinedSyncPoint:pageState]) {
        return NO;
    }

    __block BOOL exists;
    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.exists_syncpoint;
        [stmt reset];
        [stmt bindNextText:pageState];
        ZHDatabase_int count = [stmt executeReturnInteger];
        exists = (count != 0);
    });

    return exists;
}

- (BOOL)ensureDefinedSyncPoint:(NSString *)syncPoint {
    return syncPoint.length > 0 && ![syncPoint isEqualToString:@"undefined"];
}

- (NSString *)getMetaValueString:(NSString *)metaKey {
    __block NSString *value;

    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.read_metadata;

        [stmt reset];
        [stmt bindNextText:metaKey];

        NSString *syncPoint;
        if (stmt.step) {
            syncPoint = stmt.stepNextString;
        }

        [stmt reset];
        value = (syncPoint.length == 0) ? nil : syncPoint;
    });

    return value;
}

- (long)getMetaValueInt:(NSString *)metaKey {
    __block long value = 0;

    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.read_metadata;

        [stmt bindNextText:metaKey];

        if (stmt.step) {
            [stmt stepNextString];
            value = stmt.stepNextInteger;
        }

        [stmt reset];
    });

    return value;
}

- (void)setMetaData:(NSString *)strValue intValue:(NSInteger)intValue forKey:(NSString *)key {
    NSDate *date = [NSDate date];
    NSTimeInterval now = date.timeIntervalSince1970;

    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.insert_metadata;
        [stmt reset];
        [stmt bindNextText:key];
        [stmt bindNextText:strValue];
        [stmt bindNextInteger:intValue];
        [stmt bindNextTimeInterval:now];

        BOOL success = [stmt execute];
        if (!success) {
            NSLog(@"Failed to insert notification metadata into database, key:%@, str value:%@, int value:%li, updated:%f", key, strValue, (long) intValue, now);
        }
    });
}

- (void)storeBadgeCount:(NSInteger)count {
    [self setMetaData:@"" intValue:count forKey:KEY_BADGE_COUNT];

    dispatch_sync(self.queue, ^() {
        ZHDatabaseStatement *stmt = self.update_unread_count;
        [stmt bindNextBool:YES];
        [stmt bindNextInteger:count];
        [stmt execute];
    });
}

- (NSInteger)badgeCount {
    return [self getMetaValueInt:KEY_BADGE_COUNT];
}


@end