//
//  DeviceListResponse.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "DeviceListResponse.h"
#import "SFIDeviceValue.h"
#import "SFIDevice.h"

@implementation DeviceListResponse

/*
  "data": {
    "4": {
      "devicename": "Ott-light",
      "friendlydevicetype": "BinarySwitch",
      "devicetype": "1",
      "deviceid": "4",
      "location": "Office",
      "devicevalues": {
        "1": {
          "index": "1",
          "name": "SWITCH BINARY",
          "value": "false"
        }
      }
    },
    "5": {
      "devicename": "Office Door",
      "friendlydevicetype": "ContactSwitch",
      "devicetype": "12",
      "deviceid": "5",
      "location": "Office 2",
      "devicevalues": {
        "1": {
          "index": "1",
          "name": "STATE",
          "value": "false"
        },
        "2": {
          "index": "2",
          "name": "LOW BATTERY",
          "value": "false"
        },
        "3": {
          "index": "3",
          "name": "TAMPER",
          "value": "true"
        }
      }
    },
 */

+ (instancetype)parseJson:(NSDictionary *)payload {
    DeviceListResponse *res = [DeviceListResponse new];
    res.isSuccessful = YES;

    NSMutableArray *devices = [NSMutableArray array];
    NSMutableArray *deviceValueList = [NSMutableArray array];

    NSDictionary *data = payload[@"data"];

    NSArray *devicePosKeys = data.allKeys;
    NSArray *sortedPostKeys = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];

    for (NSString *devicePosition in sortedPostKeys) {
        NSDictionary *deviceDic = data[devicePosition];

        SFIDevice *device = [self parseDevice:deviceDic];
        [devices addObject:device];

        NSDictionary *valuesDic = deviceDic[@"devicevalues"];
        SFIDeviceValue *deviceValue = [self parseValue:valuesDic];
        deviceValue.deviceID = device.deviceID;

        [deviceValueList addObject:deviceValue];
    }

    res.deviceList = devices;
    res.deviceCount = (unsigned int) devices.count;
    res.deviceValueList = deviceValueList;
    
    return res;
}

+ (SFIDevice *)parseDevice:(NSDictionary *)payload {
    SFIDevice *device = [SFIDevice new];
    device.deviceName = payload[@"devicename"];
    device.location = payload[@"location"];
    device.friendlyDeviceType = payload[@"friendlydevicetype"];

    NSString *str;

    str = payload[@"devicetype"];
    device.deviceType = (SFIDeviceType) str.intValue;

    str = payload[@"deviceid"];
    device.deviceID = (sfi_id) str.intValue;

    return device;
}

+ (SFIDeviceValue *)parseValue:(NSDictionary*)payload {
    NSMutableArray *values = [NSMutableArray array];

    for (NSString *index in payload) {
        NSDictionary *knownValuesDic = payload[index];
        SFIDeviceKnownValues *knownValues = [self parseKnownValues:knownValuesDic];

        [values addObject:knownValues];
    }

    SFIDeviceValue *deviceValue = [SFIDeviceValue new];
    [deviceValue replaceKnownDeviceValues:values];

    return deviceValue;
}

+ (SFIDeviceKnownValues*)parseKnownValues:(NSDictionary *)payload {
    SFIDeviceKnownValues *values = [SFIDeviceKnownValues new];

    NSString *index = payload[@"index"];
    values.index = (unsigned int) index.intValue;

    NSString *valueName = payload[@"name"];
    values.valueName = valueName;

    values.value = payload[@"value"];
    values.propertyType = [SFIDeviceKnownValues nameToPropertyType:valueName];

    return values;
}

@end
