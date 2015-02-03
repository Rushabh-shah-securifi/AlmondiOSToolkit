//
// Created by Matthew Sinclair-Day on 1/29/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import "DatabaseStore.h"
#import "ZHDatabase.h"
#import "SFINotification.h"
#import "ZHDatabaseStatement.h"
#import "SFIDeviceKnownValues.h"
#import "NSDate+Convenience.h"

#define MAX_NOTIFICATIONS 100

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
@property(nonatomic, readonly) ZHDatabaseStatement *fetch_date_buckets;
@property(nonatomic, readonly) ZHDatabaseStatement *count_for_date_bucket;
@property(nonatomic, readonly) ZHDatabaseStatement *fetch_recs_for_date_buckets;
@property(nonatomic, readonly) ZHDatabaseStatement *mark_viewed_notification;
@end

@implementation DatabaseStore

- (void)setup {
    NSString *db_path = [self databaseInDocumentsFolderPath:@"toolkit_store.db"];
    BOOL exists = [self fileExists:db_path];

    _db = [[ZHDatabase alloc] initWithPath:db_path];

    if (!exists) {
//        [self.db execute:@"drop table notifications"];
        [self.db execute:@"create table notifications (id integer primary key, mac varchar(24), users varchar(128), date_bucket double, time double, data text, deviceid integer, devicename varchar(256), devicetype integer, value_index integer, value_indexname varchar(256), indexvalue varchar(20), viewed integer);"];
        [self.db execute:@"create index notifications_bucket on notifications (date_bucket, time);"];
        [self.db execute:@"create index notifications_time on notifications (time);"];
        [self.db execute:@"create index notifications_mac on notifications (mac, time);"];
        [self.db execute:@"create index notifications_mac_bucket on notifications (mac, date_bucket, time);"];
    }

    _insert_notification = [self.db newStatement:@"insert into notifications (mac, users, date_bucket, time, data, deviceid, devicename, devicetype, value_index, value_indexname, indexvalue, viewed) values (?,?,?,?,?,?,?,?,?,?,?,?)"];
    _fetch_date_buckets = [self.db newStatement:@"select distinct(date_bucket) from notifications order by time desc limit ?"];
    _count_for_date_bucket = [self.db newStatement:@"select count(*) from notifications where date_bucket=?"];
    _fetch_recs_for_date_buckets = [self.db newStatement:@"select id, mac, time, deviceid, devicename, devicetype, value_index, value_indexname, indexvalue, viewed from notifications where date_bucket=? order by time desc limit ?"];
    _mark_viewed_notification = [self.db newStatement:@"update notifications set viewed=? where id=?"];
}

- (void)storeNotification:(SFINotification *)notification {
    if (!notification) {
        return;
    }

    [self insertRecord:notification];
    [self trimRecords:MAX_NOTIFICATIONS];
}

- (NSInteger)countUnviewedNotifications {
    return [self.db executeReturnInteger:@"select count(*) from notifications where viewed=0"];
}

- (NSInteger)countNotificationsForBucket:(NSDate *)date {
    if (date == nil) {
        return 0;
    }

    ZHDatabaseStatement *stmt = self.count_for_date_bucket;

    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextTimeInterval:date.timeIntervalSince1970];
        NSInteger value = stmt.executeReturnInteger;
        [stmt reset];
        return value;
    }
}

- (NSArray *)fetchDateBuckets:(int)limit {
    ZHDatabaseStatement *stmt = self.fetch_date_buckets;
    NSMutableArray *results = [NSMutableArray new];

    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextInteger:limit];

        while ([stmt step]) {
            NSTimeInterval interval = stmt.stepNextTimeInterval;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
            [results addObject:date];
        }

        [stmt reset];
    }

    return results;
}

- (NSArray *)fetchNotifications:(int)limit {
    ZHDatabaseStatement *stmt = [self.db newStatement:@"select id, mac, time, deviceid, devicename, value_index, value_indexname, indexvalue from notifications order by time desc limit ?"];
    [stmt bindNextInteger:limit];

    NSMutableArray *results = [NSMutableArray array];
    while ([stmt step]) {
        SFINotification *obj = [self readRecord:stmt];
        [results addObject:obj];
    }

    [stmt reset];
    return results;
}

- (NSArray *)fetchNotificationsForBucket:(NSDate *)bucket limit:(int)limit {
    ZHDatabaseStatement *stmt = self.fetch_recs_for_date_buckets;

    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextTimeInterval:bucket.timeIntervalSince1970];
        [stmt bindNextInteger:limit];

        NSMutableArray *results = [NSMutableArray array];
        while ([stmt step]) {
            SFINotification *obj = [self readRecord:stmt];
            [results addObject:obj];
        }

        [stmt reset];
        return results;
    }
}

- (void)deleteNotificationsForAlmond:(NSString *)almondMAC {
    ZHDatabaseStatement *stmt = [self.db newStatement:@"delete from notifications where mac=?"];
    [stmt bindNextText:almondMAC];
    [stmt execute];
}

- (void)purgeAll {
    [self.db execute:@"delete from notifications"];
}

- (void)markViewed:(SFINotification *)notification {
    if (!notification) {
        return;
    }

    ZHDatabaseStatement *stmt = self.mark_viewed_notification;
    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextBool:YES];
        [stmt bindNextInteger:notification.notificationId];
        [stmt execute];
        [stmt reset];
    }
}

#pragma mark - Private methods

- (void)insertRecord:(SFINotification *)notification {
    ZHDatabaseStatement *stmt = self.insert_notification;

    NSString *valueType = [SFIDeviceKnownValues propertyTypeToName:notification.valueType];

    // Make bucket time as of midnight of that day
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:notification.time];
    NSDate *midnight = [date dateAtMidnight];
    NSTimeInterval midnightTimeInterval = midnight.timeIntervalSince1970;

    @synchronized (stmt) {
        [stmt reset];
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
    }
}
//id, mac, time, deviceid, devicename, value_index, value_indexname, indexvalue
- (SFINotification *)readRecord:(ZHDatabaseStatement *)stmt {
    SFINotification *obj = [SFINotification new];

    obj.notificationId = stmt.stepNextInteger; // id
    obj.almondMAC = stmt.stepNextString; // mac
    obj.time = stmt.stepNextTimeInterval; // time

    obj.deviceId = (sfi_id) stmt.stepNextInteger; // deviceid
    obj.deviceName = stmt.stepNextString; // devicename
    obj.deviceType = (SFIDeviceType) stmt.stepNextInteger; //devicetype

    obj.valueIndex = (sfi_id) stmt.stepNextInteger; // value_index
    NSString *valueTypeName = stmt.stepNextString; // value_indexname
    obj.valueType = [SFIDeviceKnownValues nameToPropertyType:valueTypeName];
    obj.value = stmt.stepNextString; // indexvalue

    obj.viewed = stmt.stepNextBool; // viewed

    return obj;
}

// deletes any records past the limit number, keeping the database bounded. oldest records are deleted first.
- (void)trimRecords:(int)limit {
    NSString *sql = [NSString stringWithFormat:@"delete from notifications order by time desc offset %d", limit];
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

@end