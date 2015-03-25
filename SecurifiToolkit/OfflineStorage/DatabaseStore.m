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
@property(nonatomic, readonly) ZHDatabase *db;
@property(nonatomic, readonly) ZHDatabaseStatement *insert_notification;
@property(nonatomic, readonly) ZHDatabaseStatement *read_metadata;
@property(nonatomic, readonly) ZHDatabaseStatement *insert_metadata;
@property(nonatomic, readonly) ZHDatabaseStatement *insert_syncpoint;
@property(nonatomic, readonly) ZHDatabaseStatement *delete_syncpoint;
@property(nonatomic, readonly) ZHDatabaseStatement *read_syncpoint;
@end

@implementation DatabaseStore

- (void)setup {
    NSString *db_path = [self databaseInDocumentsFolderPath:@"toolkit_notifications.db"];
    BOOL exists = [self fileExists:db_path];

    _db = [[ZHDatabase alloc] initWithPath:db_path];

    if (!exists) {
        [self.db execute:@"drop table if exists notifications"];
        [self.db execute:@"create table notifications (id integer primary key, external_id varchar(128) unique not null, mac varchar(24), users varchar(128), date_bucket double, time double, data text, deviceid integer, devicename varchar(256), devicetype integer, value_index integer, value_indexname varchar(256), indexvalue varchar(20), viewed integer);"];
        [self.db execute:@"create index notifications_bucket on notifications (date_bucket, time);"];
        [self.db execute:@"create index notifications_time on notifications (time);"];
        [self.db execute:@"create index notifications_mac on notifications (mac, time);"];
        [self.db execute:@"create index notifications_mac_bucket on notifications (mac, date_bucket, time);"];

        // a table for holding key-value pairs (schema version, last sync state, etc.)
        [self.db execute:@"drop table if exists notifications_meta"];
        [self.db execute:@"create table notifications_meta (meta_key varchar(128) primary key, meta_value varchar(128), updated double);"];
        [self.db execute:@"create index notifications_meta_key on notifications_meta (meta_key);"];

        // a queue of sync points pending processing
        [self.db execute:@"drop table if exists notifications_syncpoints"];
        [self.db execute:@"create table notifications_syncpoints (syncpoint varchar(128) primary key, created double);"];
        [self.db execute:@"create index notifications_syncpoints_syncpoint on notifications_syncpoints (syncpoint);"];
        [self.db execute:@"create index notifications_syncpoints_created on notifications_syncpoints (created);"];
    }

    _insert_notification = [self.db newStatement:@"insert into notifications (external_id, mac, users, date_bucket, time, data, deviceid, devicename, devicetype, value_index, value_indexname, indexvalue, viewed) values (?,?,?,?,?,?,?,?,?,?,?,?,?)"];
    _read_metadata = [self.db newStatement:@"select meta_value, updated from notifications_meta where meta_key=?"];
    _insert_metadata = [self.db newStatement:@"insert or replace into notifications_meta (meta_key, meta_value, updated) values (?,?,?);"];

    _insert_syncpoint = [self.db newStatement:@"insert into notifications_syncpoints (syncpoint, created) values (?,?)"];
    _delete_syncpoint = [self.db newStatement:@"delete from notifications_syncpoints where syncpoint=?"];
    _read_syncpoint = [self.db newStatement:@"select syncpoint from notifications_syncpoints order by created desc limit 1"];
}

- (id <SFINotificationStore>)newStore {
    return [[NotificationStoreImpl alloc] initWithDb:self.db];
}

- (BOOL)storeNotification:(SFINotification *)notification {
    if (!notification) {
        return NO;
    }

    BOOL success = [self insertRecord:notification];
    [self trimRecords:MAX_NOTIFICATIONS];
    return success;
}

- (void)deleteNotificationsForAlmond:(NSString *)almondMAC {
    ZHDatabaseStatement *stmt = [self.db newStatement:@"delete from notifications where mac=?"];
    [stmt bindNextText:almondMAC];
    [stmt execute];
}

- (void)purgeAllNotifications {
    [self.db execute:@"delete from notifications"];
}

- (BOOL)copyDatabaseTo:(NSString *)filePath {
    return [self.db copyTo:filePath];
}

#pragma mark - Private methods

- (BOOL)insertRecord:(SFINotification *)notification {
    ZHDatabaseStatement *stmt = self.insert_notification;

    NSString *valueType = [SFIDeviceKnownValues propertyTypeToName:notification.valueType];

    // Make bucket time as of midnight of that day
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:notification.time];
    NSDate *midnight = [date dateAtMidnight];
    NSTimeInterval midnightTimeInterval = midnight.timeIntervalSince1970;

    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextText:notification.externalId]; // external ID is unique across all records
        [stmt bindNextText:notification.almondMAC];
        [stmt bindNextText:@""]; // users
        [stmt bindNextTimeInterval:midnightTimeInterval]; // date_bucket
        [stmt bindNextTimeInterval:notification.time]; // time
        [stmt bindNextText:@""]; // data

        [stmt bindNextInteger:notification.deviceId]; // deviceid
        [stmt bindNextText:notification.deviceName]; // devicename
        [stmt bindNextInteger:notification.deviceType]; // devicetype

        [stmt bindNextInteger:notification.valueIndex]; // value_index
        [stmt bindNextText:valueType];  // value_indexname
        [stmt bindNextText:notification.value]; // indexvalue

        [stmt bindNextBool:NO]; // viewed

        BOOL success = [stmt execute];
        if (!success) {
            NSLog(@"Failed to insert notification into database, obj:%@", notification);
        }

        [stmt reset];

        return success;
    }
}

// deletes any records past the limit number, keeping the database bounded. oldest records are deleted first.
- (void)trimRecords:(int)limit {
    NSString *sql = [NSString stringWithFormat:@"delete from notifications where id in (select id from notifications order by time desc limit 1 offset %d)", limit];
    [self.db execute:sql];
}

#pragma mark - File system utilities

- (NSString *)databaseInDocumentsFolderPath:(NSString *)aDatabaseFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = paths[0];
    NSString *dbPath = [docsDir stringByAppendingPathComponent:aDatabaseFilename];
    return dbPath;
}

- (BOOL)fileExists:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (BOOL)storeNotifications:(NSArray *)notifications syncPoint:(NSString *)syncPoint {
    for (SFINotification *n in notifications) {
        [self insertRecord:n];
    }

    [self removeSyncPoint:syncPoint];
    return YES;
}

- (NSInteger)countTrackedSyncPoints {
    return [self.db executeReturnInteger:@"select count(*) from notifications_syncpoints"];
}

- (NSString *)nextTrackedSyncPoint {
    ZHDatabaseStatement *stmt = self.read_syncpoint;

    @synchronized (stmt) {
        [stmt reset];

        NSString *next;
        if ([stmt step]) {
            next = [stmt stepNextString];
        }

        [stmt reset];
        return next;
    }
}

- (void)removeSyncPoint:(NSString *)pageState {
    if (![self ensureDefinedSyncPoint:pageState]) {
        return;
    }

    ZHDatabaseStatement *stmt = self.delete_syncpoint;
    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextText:pageState];

        [stmt execute];
        [stmt reset];
    }
}

- (void)trackSyncPoint:(NSString *)pageState {
    if (![self ensureDefinedSyncPoint:pageState]) {
        return;
    }

    NSDate *date = [NSDate date];
    NSTimeInterval now = date.timeIntervalSince1970;

    ZHDatabaseStatement *stmt = self.insert_syncpoint;
    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextText:pageState];
        [stmt bindNextTimeInterval:now];
        [stmt execute];
        [stmt reset];
    }
}

- (BOOL)ensureDefinedSyncPoint:(NSString *)syncPoint {
    return syncPoint.length > 0 && ![syncPoint isEqualToString:@"undefined"];
}

- (NSString *)getMetaValue:(NSString *)metaKey {
    ZHDatabaseStatement *stmt = self.read_metadata;

    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextText:metaKey];

        NSString *syncPoint;
        if (stmt.step) {
            syncPoint = stmt.stepNextString;
        }

        [stmt reset];
        return (syncPoint.length == 0) ? nil : syncPoint;
    }
}

- (void)setMetaData:(NSString *)value forKey:(NSString *)key {
    NSDate *date = [NSDate date];
    NSTimeInterval now = date.timeIntervalSince1970;

    ZHDatabaseStatement *stmt = self.insert_metadata;
    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextText:key];
        [stmt bindNextText:value];
        [stmt bindNextTimeInterval:now];

        BOOL success = [stmt execute];
        if (!success) {
            NSLog(@"Failed to insert notification metadata into database, key:%@, value:%@, updated:%f", key, value, now);
        }

        [stmt reset];
    }
}

@end