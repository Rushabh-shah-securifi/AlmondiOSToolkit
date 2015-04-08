//
// Created by Matthew Sinclair-Day on 2/11/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NotificationStoreImpl.h"
#import "ZHDatabase.h"
#import "ZHDatabaseStatement.h"
#import "SFINotification.h"
#import "SFIDeviceKnownValues.h"


@interface NotificationStoreImpl ()
@property(nonatomic, readonly) ZHDatabase *db;
@property(nonatomic, readonly) ZHDatabaseStatement *fetch_notification;
@property(nonatomic, readonly) ZHDatabaseStatement *fetch_date_buckets;
@property(nonatomic, readonly) ZHDatabaseStatement *count_for_date_bucket;
@property(nonatomic, readonly) ZHDatabaseStatement *fetch_recs_for_date_buckets;
@property(nonatomic, readonly) ZHDatabaseStatement *mark_viewed_notification;
@property(nonatomic, readonly) ZHDatabaseStatement *mark_all_viewed_notification;
@property(nonatomic, readonly) ZHDatabaseStatement *delete_notification;
@end

@implementation NotificationStoreImpl

- (instancetype)initWithDb:(ZHDatabase *)db {
    self = [super init];
    if (self) {
        _db = db;
        _fetch_notification = [self.db newStatement:@"select id, mac, time, deviceid, devicename, value_index, value_indexname, indexvalue from notifications order by time desc limit ?"];
        _fetch_date_buckets = [self.db newStatement:@"select distinct(date_bucket) from notifications order by time desc limit ?"];
        _count_for_date_bucket = [self.db newStatement:@"select count(*) from notifications where date_bucket=?"];
        _fetch_recs_for_date_buckets = [self.db newStatement:@"select id, mac, time, deviceid, devicename, devicetype, value_index, value_indexname, indexvalue, viewed from notifications where date_bucket=? order by time desc limit ? offset ?"];
        _mark_viewed_notification = [self.db newStatement:@"update notifications set viewed=? where id=?"];
        _mark_all_viewed_notification = [self.db newStatement:@"update notifications set viewed=? where time <= ?"];
        _delete_notification = [self.db newStatement:@"delete from notifications where id=?"];
    }
    return self;
}

- (NSUInteger)countUnviewedNotifications {
    return (NSUInteger) [self.db executeReturnInteger:@"select count(*) from notifications where viewed=0"];
}

- (NSUInteger)countNotificationsForBucket:(NSDate *)date {
    if (date == nil) {
        return 0;
    }

    ZHDatabaseStatement *stmt = self.count_for_date_bucket;

    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextTimeInterval:date.timeIntervalSince1970];
        return (NSUInteger) [stmt executeReturnInteger];
    }
}

- (NSArray *)fetchDateBuckets:(NSUInteger)limit {
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
        return results;
    }
}

- (NSArray *)fetchNotifications:(NSUInteger)limit {
    ZHDatabaseStatement *stmt = self.fetch_notification;

    @synchronized (stmt) {
        [stmt reset];
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

- (SFINotification *)fetchNotificationForBucket:(NSDate *)bucket index:(NSUInteger)pos {
    ZHDatabaseStatement *stmt = self.fetch_recs_for_date_buckets;

    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextTimeInterval:bucket.timeIntervalSince1970];
        [stmt bindNextInteger:1];
        [stmt bindNextInteger:pos];

        if (![stmt step]) {
            [stmt reset];
            return nil;
        }

        SFINotification *obj = [self readRecord:stmt];
        [stmt reset];

        return obj;
    }
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
    }
}

- (void)markAllViewedTo:(SFINotification *)notification {
    if (!notification) {
        return;
    }

    ZHDatabaseStatement *stmt = self.mark_all_viewed_notification;
    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextBool:YES];
        [stmt bindNextTimeInterval:notification.time];
        [stmt execute];
    }
}


- (void)markDeleted:(SFINotification *)notification {
    if (!notification) {
        return;
    }

    ZHDatabaseStatement *stmt = self.delete_notification;
    @synchronized (stmt) {
        [stmt reset];
        [stmt bindNextInteger:notification.notificationId];
        [stmt execute];
    }
}

- (void)deleteAllNotifications {
    [self.db execute:@"delete from notifications"];
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

@end