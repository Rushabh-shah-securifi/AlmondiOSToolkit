//
//  DeviceListResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, DeviceListResponseType) {
    DeviceListResponseType_updated = 0,
    DeviceListResponseType_added,
    DeviceListResponseType_removed,
    DeviceListResponseType_removed_all,
    DeviceListResponseType_deviceList,
    DeviceListResponseType_websocket_added
};

@interface DeviceListResponse : NSObject

+ (instancetype)parseJson:(NSDictionary *)payload;

@property(nonatomic) enum DeviceListResponseType type;

@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) BOOL updatedDevicesOnly; // when true, the data only represents the devices that were changed and does not represent the complete set of devices; used in web socket mode which only sends partial data; cloud sends all data.
@property(nonatomic) unsigned int deviceCount;
@property(nonatomic, copy) NSString *reason;

@property(nonatomic, copy) NSString *almondMAC; //For dynamic update
@property(nonatomic) NSMutableArray *deviceList; // SFIDevice
@property(nonatomic) NSMutableArray *deviceValueList; // SFIDeviceValue optional list set when processing local connections; this is a hack!

- (NSString *)description;

@end
