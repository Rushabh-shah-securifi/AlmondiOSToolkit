//
//  DeviceParser.m
//  SecurifiToolkit
//
//  Created by Masood on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DeviceParser.h"
#import "AlmondPlusSDKConstants.h"
#import "SecurifiToolkit.h"
#import "Device.h"
#import "DeviceKnownValues.h"

@implementation DeviceParser

- (instancetype)init {
    self = [super init];
    [self initNotification];
    return self;
}

-(void)initNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onDeviceListResAndDynamicCallback:) name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER object:nil];
}


-(void)onDeviceListResAndDynamicCallback:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    BOOL isMatchingAlmondOrLocal = ([[payload valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
    if([[payload valueForKey:@"CommandType"] isEqualToString:@"DeviceList"]){
        NSDictionary *devices = payload[@"Devices"];
        
        NSArray *devicePosKeys = devices.allKeys;
        NSArray *sortedPostKeys = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
        }];
        
        for (NSString *devicePosition in sortedPostKeys) {
            NSDictionary *deviceDic = devices[devicePosition];
            Device *device = [self parseDeviceForPayload:deviceDic];
            [toolkit.devices addObject:device];
        }
        
    }else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicDeviceAdded"]) {
        NSDictionary *addedDevicePayload = payload[@"Devices"];
        Device *device = [self parseDeviceForPayload:addedDevicePayload];
        [toolkit.devices addObject:device];
        
    }else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicDeviceUpdated"]){
        NSDictionary *updatedDevicePayload = payload[@"Devices"];
        for(Device *device in toolkit.devices){
            if(device.ID == [updatedDevicePayload[@"ID"] intValue]){
                [self updateDevice:device payload:updatedDevicePayload];
            }
        }
    }else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicDeviceRemoved"]){
        NSString *removedDeviceID = payload[@"ID"];
        Device *toBeRemovedDevice;
        for(Device *device in toolkit.devices){
            if(device.ID == [removedDeviceID intValue]){
                toBeRemovedDevice = device;
            }
        }
        [toolkit.devices removeObject:toBeRemovedDevice];
    }else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicDeviceRemoveAll"]){
        [toolkit.devices removeAllObjects];
    }else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicIndexUpdate"]){
        NSDictionary *updatedDevice = payload[@"Data"];
        for(Device *device in toolkit.devices){
            NSDictionary *valuesDic = updatedDevice[@(device.ID).stringValue];
            if(valuesDic != nil){
                for(DeviceKnownValues *knownValue in device.knownValues){
                    NSDictionary *knownValueDic = valuesDic[@(knownValue.index).stringValue];
                    if (knownValueDic != nil) {
                        [self updateKnownValue:knownValueDic knownValues:knownValue];
                    }
                }
            }
        }
    }
}



/*
 "{
 ""CommandType"":""DynamicIndexUpdated"",
 ""Data"":{
 ""<device id>"":{
 ""<index id>"":{
 ""Name"":""<index name>"",
 ""Value"":""<index value>""
 }
 }
 }
 }"
 */
- (Device *)parseDeviceForPayload:(NSDictionary *)payload {
    Device *device = [Device new];
    [self updateDevice:device payload:payload];
    return device;
}

- (void)updateDevice:(Device*)device payload:(NSDictionary*)payload{
    device.name = payload[@"Name"];
    device.location = payload[@"Location"];
    NSString *str;
    str = payload[@"Type"];
    if (str.length > 0) {
        device.type =str.intValue;
    }
    str = payload[@"ID"];
    if (str.length > 0) {
        device.ID = (sfi_id) str.intValue;
    }
    NSDictionary *valuesDic = payload[@"DeviceValues"];
    device.knownValues = [self parseValues:valuesDic];

}

- (NSMutableArray*)parseValues:(NSDictionary*)payload{
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *index in payload) {
        NSDictionary *knownValuesDic = payload[index];
        DeviceKnownValues *knownValues = [self parseKnownValue:knownValuesDic];
        knownValues.index = index.intValue;
        [values addObject:knownValues];
    }
    return values;
}

- (DeviceKnownValues*)parseKnownValue:(NSDictionary *)payload {
    DeviceKnownValues *values = [DeviceKnownValues new];
    [self updateKnownValue:payload knownValues:values];
    return values;
}

-(void)updateKnownValue:(NSDictionary*)payload knownValues:(DeviceKnownValues*)values{
    NSString *index = payload[@"GenericIndex"];
    if (index.length > 0) {
        values.genericIndex = (unsigned int) index.intValue;
    }
    values.valueName = payload[@"Name"];
    values.value = payload[@"Value"];
}
@end
