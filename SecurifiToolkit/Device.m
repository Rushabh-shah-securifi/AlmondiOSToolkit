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

+ (NSString *)getValueForIndex:(int)deviceIndex deviceID:(int)deviceID{
    Device *device = [Device getDeviceForID:deviceID];
    return [self getValueFormKnownValues:device.knownValues forIndex:deviceIndex];
}

+(Device*)getDeviceForID:(sfi_id)deviceID{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for(Device *device in toolkit.devices){
        if(device.ID == deviceID){
            return device;
        }
    }
    return nil;
}

+(NSString*)getValueFormKnownValues:(NSArray*)knownValues forIndex:(int)deviceIndex{
    for(DeviceKnownValues *knownValue in knownValues){
        if(knownValue.index == deviceIndex){
            return knownValue.value;
        }
    }
    return nil;
}

+(Device *)getDeviceCopy:(Device*)device{
    Device *deviceNew = [Device new];
    deviceNew.type = device.type;
    deviceNew.name = device.name;
    deviceNew.location = device.location;
    deviceNew.almondMAC = device.almondMAC;
    deviceNew.notificationMode = device.notificationMode;
    deviceNew.knownValues = device.knownValues;
    return  deviceNew;
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

+ (int)getTypeForID:(int)deviceId{
   Device *device = [self getDeviceForID:deviceId];
    return device.type;
}

+ (void)updateValueForID:(int)deviceID index:(int)index value:(NSString*)value{
    Device *device = [self getDeviceForID:deviceID];
    for(DeviceKnownValues *knownValue in device.knownValues){
        if(knownValue.index == index)
            knownValue.value = value;
    }
}

+ (void)updateDeviceData:(DeviceCommandType)deviceCmdType value:(NSString*)value deviceID:(int)deviceID{
    Device *device = [self getDeviceForID:deviceID];
    if(deviceCmdType == DeviceCommand_UpdateDeviceName){
        device.name = value;
    }else if(deviceCmdType == DeviceCommand_UpdateDeviceLocation){
        device.location = value;
    }else if(deviceCmdType == DeviceCommand_NotifyMe){
        device.notificationMode = [value intValue];
    }
}
+(NSDictionary*)getCommonIndexesDict{
    return @{@"Name":@"-1", @"Location":@"-2", @"NotifyMe":@"-3"};
}

+ (void)setDeviceNameLocation:(Device*)device forGenericID:(int)genericID value:(NSString*)value{
    switch (genericID) {
        case -1:
            device.name = value;
            break;
        case -2:
            device.location = value;
            break;
        default:
            break;
    }
}

- (NSArray *)updateNotificationMode:(SFINotificationMode)mode deviceValue:(NSArray *)knownValues {
    if (mode == SFINotificationMode_unknown) {
        NSLog(@"updateNotificationMode: illegal mode 'SFINotificationMode_unknown'; ignoring change");
        return @[];
    }
    
    // Note side-effect on this instance
//    self.notificationMode = mode;
    
    // When changing mode, we have to set the preference for each index and send the list to the cloud.
    // Notification will be sent for all changes to the devices known values; one preference setting for each device property.
    // It seems like the cloud could provide a simple API for doing this work for us.
    //
    // The list of indexes whose preference setting has to be changed
    NSArray *deviceValuesList;
    
//    if (self.type == SFIDeviceType_SmartACSwitch_22 || self.type == SFIDeviceType_SecurifiSmartSwitch_50) {
//        // Special case these two: we only toggle the setting for the main state index
//        // otherwise the notifications will be too many
//        SFIDeviceKnownValues *deviceValue = [value knownValuesForProperty:self.statePropertyType];
//        deviceValuesList = @[deviceValue];
//    }
//    else {
//        // General case: change all indexes
//        deviceValuesList = [value knownDevicesValues];
//    }
    
    // The list of preference settings
    NSMutableArray *settings = [[NSMutableArray alloc] init];
    
    for (DeviceKnownValues *knownValue in knownValues) {
        SFINotificationDevice *notificationDevice = [[SFINotificationDevice alloc] init];
        notificationDevice.deviceID = self.ID;
        notificationDevice.notificationMode = self.notificationMode;
        notificationDevice.valueIndex = knownValue.index;
        
        [settings addObject:notificationDevice];
    }
    
    return settings;
}

@end
