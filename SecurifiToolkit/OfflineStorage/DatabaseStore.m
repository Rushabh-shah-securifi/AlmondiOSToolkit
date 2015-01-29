//
// Created by Matthew Sinclair-Day on 1/29/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import "DatabaseStore.h"
#import "ZHDatabase.h"
#import "SFINotification.h"
#import "ZHDatabaseStatement.h"
#import "SFIDeviceKnownValues.h"

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
    time double,
    data text,
    deviceid integer,
    devicename varchar(256),
    value_index integer,
    value_indexname varchar(256),
    indexvalue varchar(20),
    message text,
    viewed integer
);

create index notifications_time on notifications (time);
create index notifications_mac on notifications (mac, time);

 */

@interface DatabaseStore ()
@property(nonatomic, readonly) ZHDatabase *db;
@property(nonatomic, readonly) ZHDatabaseStatement *insert_notification;
@property(nonatomic, readonly) ZHDatabaseStatement *mark_viewed_notification;
@end

@implementation DatabaseStore

- (void)setup {
    NSString *db_path = [self databaseInDocumentsFolderPath:@"toolkit_store.db"];
    BOOL exists = [self fileExists:db_path];

    _db = [[ZHDatabase alloc] initWithPath:db_path];

    if (!exists) {
        [self.db execute:@"create table notifications (id integer primary key, mac varchar(24), users varchar(128), time double, data text, deviceid integer, devicename varchar(256), value_index integer, value_indexname varchar(256), indexvalue varchar(20), message text, viewed integer);"];
        [self.db execute:@"create index notifications_time on notifications (time);"];
        [self.db execute:@"create index notifications_mac on notifications (mac, time);"];
    }

    _insert_notification = [self.db newStatement:@"insert into notifications (mac, users, time, data, deviceid, devicename, value_index, value_indexname, indexvalue, message, viewed) values (?,?,?,?,?,?,?,?,?,?,?)"];
    _mark_viewed_notification = [self.db newStatement:@"update notifications set viewed=? where id=?"];
}

- (void)storeNotification:(SFINotification*)notification {
    if (!notification) {
        return;
    }

    [self insertRecord:notification];
    [self trimRecords:MAX_NOTIFICATIONS];
}

- (NSInteger)countUnviewedNotifications {
    return [self.db executeReturnInteger:@"select count(*) from notifications where viewed=0"];
}

- (NSArray*)fetchNotifications:(int)limit {
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

    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextText:notification.almondMAC];
        [stmt bindNextText:@""]; // users
        [stmt bindNextTimeInterval:notification.time];
        [stmt bindNextText:@""]; // data
        [stmt bindNextInteger:notification.deviceId];
        [stmt bindNextText:notification.deviceName];
        [stmt bindNextInteger:notification.valueIndex];

        [stmt bindNextText:valueType];

        [stmt bindNextText:notification.value];
        [stmt bindNextText:notification.message];
        [stmt bindNextBool:NO]; // viewed

        BOOL success = [stmt execute];
        if (!success) {
            NSLog(@"Failed to insert notification into database, obj:%@", notification);
        }

        [stmt reset];
    }
}

- (SFINotification *)readRecord:(ZHDatabaseStatement *)stmt {
    SFINotification *obj = [SFINotification new];

    obj.notificationId = stmt.stepNextInteger;
    obj.almondMAC = stmt.stepNextString;
    obj.time = stmt.stepNextTimeInterval;
    obj.deviceId = (sfi_id) stmt.stepNextInteger;
    obj.deviceName = stmt.stepNextString;
    obj.deviceType = (SFIDeviceType) stmt.stepNextInteger;
    obj.valueIndex = (sfi_id) stmt.stepNextInteger;

    NSString *valueTypeName = stmt.stepNextString;
    obj.valueType = [SFIDeviceKnownValues nameToPropertyType:valueTypeName];

    obj.value = stmt.stepNextString;
    obj.message = stmt.stepNextString;
    obj.viewed = stmt.stepNextBool;

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

- (BOOL)fileExists:(NSString*)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

@end