//
//  SFIConnectedDevices.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

//todo badly modeled: no needed for a value holder for an array of ConnectedDevice

@interface SFIDevicesList : NSObject

+ (instancetype)parseJson:(NSDictionary *)payload;

@property(nonatomic) unsigned int deviceCount;
@property(nonatomic, retain) NSArray *deviceList; //SFIConnectedDevice and SFIBlockedDevice

@end
