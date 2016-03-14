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
#import "DataBaseManager.h"

@implementation DeviceParser

+(void)commandTesting{
    NSDictionary *devicelistresponsedata =@{
                                            @"MobileInternalIndex":@"<random key>",
                                            @"CommandType":@"DeviceList",
                                            @"Devices":@{
                                                    @"3":@{
                                                            @"Name":@"ContactSwitch #1",
                                                            @"FriendlyDeviceType":@"ContactSwitch",
                                                            @"Type":@"12",
                                                            @"Location":@"Default",
                                                            @"DeviceValues":@{
                                                                    @"1":@{
                                                                            @"Name":@"STATE",
                                                                            @"GenericIndex":@"50",
                                                                            @"Value":@"true"
                                                                            },
                                                                    @"2":@{
                                                                            @"Name":@"LOW BATTERY",
                                                                            @"GenericIndex":@"50",
                                                                            @"Value":@"0"
                                                                            },
                                                                    @"3":@{
                                                                            @"Name":@"TAMPER",
                                                                            @"GenericIndex":@"50",
                                                                            @"Value":@"true"
                                                                            }
                                                                    }
                                                            },
                                                    @"4":@{
                                                        @"Name":@"BinarySwitch #2",
                                                        @"FriendlyDeviceType":@"BinarySwitch",
                                                        @"Type":@"1",
                                                        @"Location":@"Default",
                                                        @"DeviceValues":@{
                                                                          @"1":@{
                                                                                  @"Name":@"SWITCH BINARY",
                                                                                  @"GenericIndex":@"50",
                                                                                  @"Value":@"true"
                                                                                  }
                                                                          }
                                                    }
                                             }
                                            };
    NSDictionary *dynamicDeviceAdded = @{@"CommandType":@"DynamicDeviceAdded",
                                         @"Devices":@{
                                                 @"10":@{
                                                         @"Name":@"ContactSwitch #1",
                                                         @"FriendlyDeviceType":@"ContactSwitch",
                                                         @"Type":@"12",
                                                         @"Location":@"Default",
                                                         @"DeviceValues":@{
                                                                 @"1":@{
                                                                         @"Name":@"STATE",
                                                                         @"GenericIndex":@"50",
                                                                         @"Value":@"true"
                                                                         },
                                                                 @"2":@{
                                                                         @"Name":@"LOW BATTERY",
                                                                         @"GenericIndex":@"50",
                                                                         @"Value":@"0"
                                                                         },
                                                                 @"3":@{
                                                                         @"Name":@"TAMPER",
                                                                         @"GenericIndex":@"50",
                                                                         @"Value":@"true"
                                                                         }
                                                                 }
                                                         }
                                            }
                                         };
    
    NSDictionary *dynamicDeviceUpdated = @{@"CommandType":@"DynamicDeviceUpdated",
                                           @"Devices":@{
                                                   @"3":@{
                                                           @"Name":@"ContactSwitch name updated",
                                                           @"FriendlyDeviceType":@"ContactSwitch",
                                                           @"Type":@"12",
                                                           @"Location":@"Default",
                                                           @"DeviceValues":@{
                                                                   @"1":@{
                                                                           @"Name":@"STATE",
                                                                           @"GenericIndex":@"50",
                                                                           @"Value":@"true"
                                                                           },
                                                                   @"2":@{
                                                                           @"Name":@"LOW BATTERY",
                                                                           @"GenericIndex":@"50",
                                                                           @"Value":@"10"
                                                                           },
                                                                   @"3":@{
                                                                           @"Name":@"TAMPER",
                                                                           @"GenericIndex":@"50",
                                                                           @"Value":@"true"
                                                                           }
                                                                   }
                                                           }
                                                   }
                                           };
    NSDictionary *dynamicDeviceRemove = @{
                                   
                                   @"CommandType":@"DynamicDeviceRemoved",
                                   @"ID":@"10"
                                   
                                   };
    NSDictionary *dynamicRemoveAll = @{@"CommandType":@"DynamicDeviceRemoveAll"};
    
    NSDictionary *dynamicIndexUpdate = @{
                                    @"CommandType":@"DynamicIndexUpdated",
                                    @"Data":@{
                                              @"3":@{
                                                      @"2":@{
                                                              @"Name":@"LOW BATTERY",
                                                              @"GenericIndex":@"50",
                                                              @"Value":@"20"
                                                              },
                                                      }
                                              }
                                    };
    
    [self parseDeviceListAndDynamicDeviceResponse:devicelistresponsedata];
    [self parseDeviceListAndDynamicDeviceResponse:dynamicDeviceAdded];
    [self parseDeviceListAndDynamicDeviceResponse:dynamicDeviceUpdated];
    [self parseDeviceListAndDynamicDeviceResponse:dynamicDeviceRemove];
    [self parseDeviceListAndDynamicDeviceResponse:dynamicIndexUpdate];
    [self parseDeviceListAndDynamicDeviceResponse:dynamicRemoveAll];
}

+(void)parseDeviceListAndDynamicDeviceResponse:(id)sender{
//    NSNotification *notifier = (NSNotification *) sender;
//    NSDictionary *dataInfo = [notifier userInfo];
//    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
//        return;
//    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
//    if(local){
//        payload = [dataInfo valueForKey:@"data"];
//    }else{
//        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
//    }
    payload = [self parseJson:@"DeviceListResponse"];
//    BOOL isMatchingAlmondOrLocal = ([[payload valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
//    if(!isMatchingAlmondOrLocal) //for cloud
//        return;
    
    if([[payload valueForKey:@"CommandType"] isEqualToString:@"DeviceList"]){
        NSDictionary *devicesPayload = payload[@"Devices"];
        NSArray *devicePosKeys = devicesPayload.allKeys;
        NSArray *sortedPostKeys = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
        }];
        
        for (NSString *devicePosition in sortedPostKeys) {
            NSDictionary *deviceDic = devicesPayload[devicePosition];
            Device *device = [self parseDeviceForPayload:deviceDic];
            device.ID = [devicePosition intValue];
            [toolkit.devices addObject:device];
        }
    }
    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicDeviceAdded"]) {
        NSDictionary *devicesPayload = payload[@"Devices"];
        NSString *deviceID = [[devicesPayload allKeys] objectAtIndex:0]; // Assumes payload always has one device.
        NSDictionary *addedDevicePayload = [devicesPayload objectForKey:deviceID];
        Device *device = [self parseDeviceForPayload:addedDevicePayload];
        device.ID = (sfi_id) [deviceID intValue];
        [toolkit.devices addObject:device];
        
    }
    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicDeviceUpdated"]){
        NSDictionary *devicesPayload = payload[@"Devices"];
        NSString *deviceID = [[devicesPayload allKeys] objectAtIndex:0]; // Assumes payload always has one device.
        NSDictionary *updatedDevicePayload = [devicesPayload objectForKey:deviceID];
        for(Device *device in toolkit.devices){
            if(device.ID == [deviceID intValue]){
                [self updateDevice:device payload:updatedDevicePayload];
                break;
            }
        }
        
    }
    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicDeviceRemoved"]){
        NSString *removedDeviceID = payload[@"ID"];
        Device *toBeRemovedDevice;
        for(Device *device in toolkit.devices){
            if(device.ID == [removedDeviceID intValue]){
                toBeRemovedDevice = device;
            }
        }
        [toolkit.devices removeObject:toBeRemovedDevice];
    }
    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicDeviceRemoveAll"]){
        [toolkit.devices removeAllObjects];
    }
    else if([[payload valueForKey:@"CommandType"] isEqualToString:@"DynamicIndexUpdated"]){
        NSDictionary *updatedDevice = payload[@"Data"];
        for(Device *device in toolkit.devices){
            NSDictionary *valuesDic = updatedDevice[@(device.ID).stringValue];
            if(valuesDic != nil){
                for(DeviceKnownValues *knownValue in device.knownValues){
                    NSDictionary *knownValueDic = valuesDic[@(knownValue.index).stringValue];
                    if (knownValueDic != nil) {
                        [self updateKnownValue:knownValueDic knownValues:knownValue];
                        break;
                    }
                }
            }
        }
    }
    toolkit.devicesJSON = [DataBaseManager getDevicesForIds:[Device getDeviceTypes]];
    toolkit.genericIndexesJson = [DataBaseManager getDeviceIndexesForIds:[Device getGenericIndexes]];
//    NSLog(@"devices json: %@, indexesjson: %@", toolkit.devicesJSON, toolkit.indexesJSON);
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
+ (Device *)parseDeviceForPayload:(NSDictionary *)payload {
    Device *device = [Device new];
    [self updateDevice:device payload:payload];
    return device;
}

+ (void)updateDevice:(Device*)device payload:(NSDictionary*)payload{
    device.name = payload[@"Name"];
    device.location = payload[@"Location"];
    NSString *str;
    str = payload[@"Type"];
    if (str.length > 0) {
        device.type =str.intValue;
    }
    NSDictionary *valuesDic = payload[@"DeviceValues"];
    device.knownValues = [self parseValues:valuesDic];

}

+ (NSMutableArray*)parseValues:(NSDictionary*)payload{
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *index in payload) {
        NSDictionary *knownValuesDic = payload[index];
        DeviceKnownValues *knownValues = [self parseKnownValue:knownValuesDic];
        knownValues.index = index.intValue;
        [values addObject:knownValues];
    }
    return values;
}

+ (DeviceKnownValues*)parseKnownValue:(NSDictionary *)payload {
    DeviceKnownValues *values = [DeviceKnownValues new];
    [self updateKnownValue:payload knownValues:values];
    return values;
}

+ (void)updateKnownValue:(NSDictionary*)payload knownValues:(DeviceKnownValues*)values{
    NSString *index = payload[@"GenericIndex"];
    if (index.length > 0) {
        values.genericIndex = (unsigned int) index.intValue;
    }
    values.valueName = payload[@"Name"];
    values.value = payload[@"Value"];
}

+(NSDictionary*)parseJson:(NSString*)fileName{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                         options:kNilOptions
                                                           error:&error];
    
    if (error != nil) {
        NSLog(@"Error: was not able to load json file: %@.",fileName);
    }
    return data;
}

@end
