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
    NSMutableSet *typesSet = [NSMutableSet new];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for(Device *device in toolkit.devices){
        for(DeviceKnownValues *knownValue in device.knownValues){
            [typesSet addObject:@(knownValue.genericIndex).stringValue];
        }
    }
    return [[typesSet allObjects] mutableCopy];
}

+(NSString*)getValueForGenericIndex:(NSString*)genericIndex forDevice:(Device*)device{
    for(DeviceKnownValues *knownValue in device.knownValues){
        if(knownValue.genericIndex == genericIndex.intValue){
            return knownValue.value;
        }
    }
    return nil;
}

@end
