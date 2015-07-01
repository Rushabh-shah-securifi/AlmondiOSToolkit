//
//  DeviceValueResponse.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "DeviceValueResponse.h"
#import "SFIDeviceValue.h"

@implementation DeviceValueResponse

/*
{
  "commandtype": "SensorUpdate",
  "data": {
    "4": {
      "1": {
        "index": "1",
        "name": "SWITCH BINARY",
        "value": "true"
      }
    }
  }
}
 */

+ (instancetype)parseJson:(NSDictionary *)payload {
    DeviceValueResponse *res = [DeviceValueResponse new];
    res.isSuccessful = YES;

    NSMutableArray *deviceValueList = [NSMutableArray array];

    NSDictionary *data = payload[@"data"];

    NSArray *devicePosKeys = data.allKeys;
    NSArray *sortedPostKeys = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];

    for (NSString *device_id in sortedPostKeys) {
        NSDictionary *deviceValuesDic = data[device_id];

        SFIDeviceValue *deviceValue = [self parseValue:deviceValuesDic];
        deviceValue.deviceID = (unsigned int) device_id.intValue;

        [deviceValueList addObject:deviceValue];
    }

    res.deviceValueList = deviceValueList;

    return res;
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
