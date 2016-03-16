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
#import "Formatter.h"
#import "GenericIndexClass.h"
#import "GenericDeviceClass.h"
#import "GenericValue.h"
#import "DeviceIndex.h"
#import "AlmondJsonCommandKeyConstants.h"

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
    BOOL isMatchingAlmondOrLocal = ([[payload valueForKey:@"AlmondMAC"] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
    
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
    
    NSDictionary *genericDeviceDict = [DataBaseManager getDevicesForIds:[Device getDeviceTypes]];
    NSDictionary *genericIndexesDict = [DataBaseManager getDeviceIndexesForIds:[Device getGenericIndexes]];
    toolkit.genericDevices = [self parseGenericDevicesDict:genericDeviceDict];
    toolkit.genericIndexes = [self parseGenericIndexesDict:genericIndexesDict];
    
}

//@property NSString *name;
//@property NSString *type;
//@property NSString *defaultIcon;
//@property BOOL isActuator;
//@property BOOL isTriggerDevice;
//@property NSDictionary *Indexes;
//@end

//generic device key constants
//#define DEVICE_NAME @"name"
//#define DEVICE_DEFAULT_ICON @"defaultIcon"
//#define IS_ACTION_DEVICE @"isActionDevice"
//#define IS_ACTUATOR @"isActuator"
//#define IS_TRIGGER_DEVICE @"isTriggerDevice"
//#define INDEXES @"Indexes"

//generic device parsing methods
+(NSDictionary*)parseGenericDevicesDict:(NSDictionary*)genericDevicesDict{
    NSArray *genericDevicesKeys = genericDevicesDict.allKeys;
    GenericDeviceClass *genericIndexObject;
    NSMutableDictionary *mutableDeviceDict = [NSMutableDictionary new];
    for(NSString *deviceType in genericDevicesKeys){
        genericIndexObject = [self createGenericDeviceForDict:genericDevicesDict[deviceType] forType:deviceType];
        [mutableDeviceDict setObject:genericIndexObject forKey:deviceType];
    }
    return mutableDeviceDict;
}

+(GenericDeviceClass *)createGenericDeviceForDict:(NSDictionary*)genericDeviceDict forType:(NSString*)deviceType{
    GenericDeviceClass *genericDeviceObject = [[GenericDeviceClass alloc] initWithName:genericDeviceDict[DEVICE_NAME]
                                                                                  type:genericDeviceDict[deviceType]
                                                                           defaultIcon:genericDeviceDict[DEVICE_DEFAULT_ICON]
                                                                            isActuator:genericDeviceDict[IS_ACTUATOR]
                                                                       isTriggerDevice:genericDeviceDict[IS_TRIGGER_DEVICE]
                                                                               indexes:[self createDeviceIndexesDict:genericDeviceDict[INDEXES]]];
    return genericDeviceObject;
    
}

+(NSDictionary*)createDeviceIndexesDict:(NSDictionary*)indexesDict{
    NSMutableDictionary *indexes = [NSMutableDictionary new];
    NSArray *indexesKeys = indexesDict.allKeys;
    for(NSString *index in indexesKeys){
        NSDictionary *indexDict = indexesDict[index];
        DeviceIndex *deviceIndex = [[DeviceIndex alloc]initWithIndex:index
                                                        genericIndex:indexDict[GENERIC_INDEX_ID]
                                                               rowID:indexDict[ROW_NO]];
        [indexes setObject:deviceIndex forKey:index];
    }
    return indexes;
}

//genericindexes parsing methods
+(NSDictionary*)parseGenericIndexesDict:(NSDictionary*)genericIndexesDict{
    NSArray *genericIndexKeys = genericIndexesDict.allKeys;
    GenericIndexClass *genericIndexObject;
    NSMutableDictionary *mutableGenericIndex = [NSMutableDictionary new];
    for(NSString *genericIndexID in genericIndexKeys){
        genericIndexObject = [self createGenericIndexForDic:genericIndexesDict[genericIndexID] forID:genericIndexID];
        [mutableGenericIndex setObject:genericIndexObject forKey:genericIndexID];
    }
    return mutableGenericIndex;
}
+(GenericIndexClass*)createGenericIndexForDic:(NSDictionary*)genericIndexDict forID:(NSString*)ID{
    GenericIndexClass *genericIndexObject = [[GenericIndexClass alloc]
                                             initWithLabel:genericIndexDict[LABEL]
                                             icon:genericIndexDict[INDEX_DEFAULT_ICON]
                                             identifier:ID
                                             placement:genericIndexDict[PLACEMENT]
                                             values:[self createGenericValues:genericIndexDict[VALUES]]
                                             formatter:[self createFormatterFromIndexDicIfExists:genericIndexDict[FORMATTER]]
                                             layoutType:genericIndexDict[LAYOUT]];
    return genericIndexObject;
}

+(Formatter*)createFormatterFromIndexDicIfExists:(NSDictionary*)formatterDict{
    if(formatterDict){
        Formatter *formatter = [[Formatter alloc]initWithFactor:[formatterDict[FACTOR] floatValue] min:[formatterDict[MIN] intValue] max:[formatterDict[MAX] intValue] units:formatterDict[UNIT]];
        return formatter;
    }
    return nil;
}

+(NSMutableDictionary *)createGenericValues:(NSDictionary*)genericValuesDict{
    NSArray *valueKeys = genericValuesDict.allKeys;
    NSMutableDictionary *genericValues = [NSMutableDictionary new];
    for(NSString *value in valueKeys){
        NSDictionary *valueDict = genericValuesDict[value];
        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:valueDict[LABEL] icon:valueDict[ICON] formattedValue:nil toggleValue:valueDict[TOGGLE_VALUE] isIconText:false];
        genericValue.value = value;
        [genericValues setObject:genericValue forKey:value];
    }
    return genericValues;
}



//DeviceListAndDynamicDeviceResponse parsing methods
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
