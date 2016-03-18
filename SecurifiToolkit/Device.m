//
//  Device.m
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "Device.h"
#import "DeviceKnownValues.h"
#import "SecurifiToolkit.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "GenericDeviceClass.h"
#import "DeviceIndex.h"

@implementation Device

+(Device*)getDeviceForID:(sfi_id)deviceID{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for(Device *device in toolkit.devices){
        if(device.ID == deviceID){
            return device;
        }
    }
    return nil;
}

+(NSMutableArray*)getDeviceTypes{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSMutableSet *deviceTypes = [NSMutableSet new];
    for(Device *device in toolkit.devices){
        [deviceTypes addObject:@(device.type).stringValue];
    }
    return [[deviceTypes allObjects] mutableCopy];
}

+(NSMutableArray*)getGenericIndexes{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSMutableSet *genericIndexesSet = [NSMutableSet new];
    for(Device *device in toolkit.devices){
        GenericDeviceClass *genericDeviceObj = toolkit.genericDevices[@(device.type).stringValue];
        for(NSString *index in genericDeviceObj.Indexes.allKeys){
            DeviceIndex *indexObj = genericDeviceObj.Indexes[index];
            [genericIndexesSet addObject:indexObj.genericIndex];
        }
    }
    return [[genericIndexesSet allObjects] mutableCopy];
}


@end
