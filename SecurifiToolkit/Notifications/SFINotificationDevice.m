//
//  SFINotificationDevice.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 14/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "SFINotificationDevice.h"

@implementation SFINotificationDevice

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.deviceID = (sfi_id) [coder decodeIntForKey:@"self.deviceID"];
        self.valueIndex = (unsigned int) [coder decodeIntForKey:@"self.valueIndex"];
        self.notificationMode = (SFINotificationMode) (unsigned int) [coder decodeIntegerForKey:@"self.notificationMode"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.deviceID forKey:@"self.deviceID"];
    [coder encodeInt:self.valueIndex forKey:@"self.valueIndex"];
    [coder encodeInt:self.notificationMode forKey:@"self.notificationMode"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.deviceID=%u", self.deviceID];
    [description appendFormat:@", self.valueIndex=%u", self.valueIndex];
    [description appendFormat:@", self.notificationMode=%u", self.notificationMode];
    [description appendString:@">"];
    return description;
}

- (id)copyWithZone:(NSZone *)zone {
    SFINotificationDevice *copy = (SFINotificationDevice *) [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.deviceID = self.deviceID;
        copy.valueIndex = self.valueIndex;
        copy.notificationMode = self.notificationMode;
    }

    return copy;
}

+ (NSArray *)addNotificationDevices:(NSArray *)devicesToAdd to:(NSArray *)devicesList {
    NSMutableDictionary *deviceIndexMap = [self deviceIndexMap:devicesList];
    for (SFINotificationDevice *device  in devicesToAdd) {
        [self tryAddDeviceNotificationToMap:deviceIndexMap deviceNotification:device];
    }

    return [self collectAllValues:deviceIndexMap];
}

+ (NSArray *)removeNotificationDevices:(NSArray *)devicesToRemove from:(NSArray *)devicesList {
    NSMutableDictionary *deviceIndexMap = [self deviceIndexMap:devicesList];
    for (SFINotificationDevice *device  in devicesToRemove) {
        sfi_id sfi = device.deviceID;
        NSNumber *id_num = @(sfi);

        NSMutableDictionary *index_pref_map = deviceIndexMap[id_num];
        if (index_pref_map) {
            NSNumber *index_key = @(device.valueIndex);
            [index_pref_map removeObjectForKey:index_key];
        }
    }

    return [self collectAllValues:deviceIndexMap];
}

// generates a map keyed by device ID whose value is a map keyed by index ID and whose value is the actual SFINotificationDevice
+ (NSMutableDictionary *)deviceIndexMap:(NSArray *)devicesList {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (SFINotificationDevice *d in devicesList) {
        [self tryAddDeviceNotificationToMap:dict deviceNotification:d];
    }

    return dict;
}

// adds the specified deviceNotification instance into the dictionary (device_id :: (index_id :: SFINotificationDevice))
+ (void)tryAddDeviceNotificationToMap:(NSMutableDictionary *)dict deviceNotification:(SFINotificationDevice *)dn {
    sfi_id sfi = dn.deviceID;
    NSNumber *id_num = @(sfi);

    NSMutableDictionary *index_pref_map = dict[id_num];
    if (index_pref_map == nil) {
        index_pref_map = [NSMutableDictionary dictionary];
        dict[id_num] = index_pref_map;
    }

    NSNumber *index_key = @(dn.valueIndex);
    index_pref_map[index_key] = dn;
}

// flattens the dictionary into an array of SFINotificationDevice
+ (NSArray *)collectAllValues:(NSDictionary *)devicesToIndexMap {
    NSMutableArray *values = [NSMutableArray array];

    for (NSDictionary *indexToValueMap in devicesToIndexMap.allValues) {
        NSArray *instances = indexToValueMap.allValues;
        [values addObjectsFromArray:instances];
    }

    return values;
}

@end
