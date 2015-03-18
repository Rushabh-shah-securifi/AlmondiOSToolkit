//
// Created by Matthew Sinclair-Day on 1/29/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
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
@end

@implementation DatabaseStore

- (void)setup {
    NSString *db_path = [self databaseInDocumentsFolderPath:@"toolkit_store.db"];
    BOOL exists = [self fileExists:db_path];

    _db = [[ZHDatabase alloc] initWithPath:db_path];

    if (!exists) {
        [self.db execute:@"drop table if exists notifications"];
        [self.db execute:@"create table notifications (id integer primary key, mac varchar(24), users varchar(128), date_bucket double, time double, data text, deviceid integer, devicename varchar(256), devicetype integer, value_index integer, value_indexname varchar(256), indexvalue varchar(20), viewed integer);"];
        [self.db execute:@"create index notifications_bucket on notifications (date_bucket, time);"];
        [self.db execute:@"create index notifications_time on notifications (time);"];
        [self.db execute:@"create index notifications_mac on notifications (mac, time);"];
        [self.db execute:@"create index notifications_mac_bucket on notifications (mac, date_bucket, time);"];
    }

    _insert_notification = [self.db newStatement:@"insert into notifications (mac, users, date_bucket, time, data, deviceid, devicename, devicetype, value_index, value_indexname, indexvalue, viewed) values (?,?,?,?,?,?,?,?,?,?,?,?)"];
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

- (void)purgeAll {
    [self.db execute:@"delete from notifications"];
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

@end