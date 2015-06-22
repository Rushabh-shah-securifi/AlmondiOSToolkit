//
//  DeviceListResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, DeviceListResponseType) {
    DeviceListResponseType_updated = 0,
    DeviceListResponseType_added,
    DeviceListResponseType_removed,
    DeviceListResponseType_removed_all,
};

@interface DeviceListResponse : NSObject

+ (instancetype)parseJson:(NSDictionary *)payload;

@property(nonatomic) enum DeviceListResponseType type;

@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) unsigned int deviceCount;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) NSMutableArray *deviceList; // SFIDevice
@property(nonatomic, copy) NSString *almondMAC; //For dynamic update

@property(nonatomic) NSMutableArray *deviceValueList; // SFIDeviceValue optional list set when processing local connections; this is a hack!

@end
