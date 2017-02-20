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
#import "Client.h"
#import "RouterParser.h"
#import "NotificationPreferenceListResponse.h"
#import "NotificationPreferenceListRequest.h"
#import "LocalNetworkManagement.h"
#import "AlmondManagement.h"

//#import "SFIRouterSummary.h"

@implementation DeviceParser

-(void)commandTesting{
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
                                                                            @"Value":@"true"
                                                                            },
                                                                    @"2":@{
                                                                            @"Name":@"LOW BATTERY",
                                                                            @"Value":@"0"
                                                                            },
                                                                    @"3":@{
                                                                            @"Name":@"TAMPER",
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
                                                                         @"Value":@"true"
                                                                         },
                                                                 @"2":@{
                                                                         @"Name":@"LOW BATTERY",
                                                                         @"Value":@"0"
                                                                         },
                                                                 @"3":@{
                                                                         @"Name":@"TAMPER",
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
                                                                           @"Value":@"true"
                                                                           },
                                                                   @"2":@{
                                                                           @"Name":@"LOW BATTERY",
                                                                           @"Value":@"10"
                                                                           },
                                                                   @"3":@{
                                                                           @"Name":@"TAMPER",
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

- (instancetype)init {
    self = [super init];
    if(self){
        [self initNotification];
    }
    return self;
}

-(void)initNotification{
    NSLog(@"init device notification");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(parseDeviceListAndDynamicDeviceResponse:)
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondRouterCommandResponse:)
                   name:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER
                 object:nil];// router summery response to store DB
    
    [center addObserver:self
               selector:@selector(onNotificationPrefDidChange:)
                   name:kSFINotificationPreferencesDidChange
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDynamicNotificationPreference:)
                   name:NOTIFICATION_CommandType_NOTIFICATION_PREF_CHANGE_DYNAMIC_RESPONSE
                 object:nil];
}

-(void)parseDeviceListAndDynamicDeviceResponse:(id)sender{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || dataInfo[@"data"]==nil ) {
        return;
    }
    
    if(local){
        payload = dataInfo[@"data"];
    }else{
        NSLog(@"cloud data");
        if(![dataInfo[@"data"] isKindOfClass:[NSData class]])
        return;
        payload = [dataInfo[@"data"] objectFromJSONData];
    }
    
//    payload = [self parseJson:@"DeviceListResponse"];
    NSLog(@"devices - payload: %@", payload);

    BOOL isMatchingAlmondOrLocal = ([payload[ALMONDMAC] isEqualToString:almond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
    NSString *commandType = payload[COMMAND_TYPE];
    if([commandType isEqualToString:DEVICE_LIST] || [commandType isEqualToString:@"DynamicDeviceList"]){
        NSDictionary *devicesPayload = payload[DEVICES];
        NSArray *devicePosKeys = devicesPayload.allKeys;
        NSArray *sortedPostKeys = [devicePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
        }];
        
        NSMutableArray *deviceList = [NSMutableArray new];
        for (NSString *devicePosition in sortedPostKeys) {
            NSDictionary *deviceDic = devicesPayload[devicePosition];
            Device *device = [self parseDeviceForPayload:deviceDic];
            device.ID = [devicePosition intValue];
            [deviceList addObject:device];
        }
        
        NSLog(@"addobjects");
        toolkit.devices = deviceList;
        if(!local){
            [self asyncRequestNotificationPreferenceList:almond.almondplusMAC];
            
            //temp fix - to fetch almond list after firmware update
            if([commandType isEqualToString:@"DynamicDeviceList"]){
                NSLog(@"sending almond list payload");
                [toolkit requestAlmondList];
            }
        }
        
//        //    genericdevices
//        NSMutableArray *genericDeviceTypesArray = [Device getDeviceTypes];
//        [self addModeClientRebootDeviceTypes:genericDeviceTypesArray];
//        NSDictionary *genericDeviceDict = [DataBaseManager getDevicesForIds:genericDeviceTypesArray];
//        toolkit.genericDevices = [self parseGenericDevicesDict:genericDeviceDict];
////
//        //    genericindexes
//        NSMutableArray *genericIndexesArray = [Device getGenericIndexes];
//        [self addCommonGenericIndexes:genericIndexesArray];
//        [self addClientGenericIndexes:genericIndexesArray];
//        [self addModeClientRebootIndexes:genericIndexesArray];
//        NSDictionary *genericIndexesDict = [DataBaseManager getDeviceIndexesForIds:genericIndexesArray];
//        toolkit.genericIndexes = [self parseGenericIndexesDict:genericIndexesDict];
        
    }
    else if([commandType isEqualToString:DYNAMIC_DEVICE_ADDED]) {
        NSDictionary *devicesPayload = payload[DEVICES];
        NSString *deviceID = [[devicesPayload allKeys] objectAtIndex:0]; // Assumes payload always has one device.
        NSDictionary *addedDevicePayload = [devicesPayload objectForKey:deviceID];
        Device *device = [Device getDeviceForID:[deviceID intValue]];
        if(device)
            [self updateDevice:device payload:addedDevicePayload];
        else{
            device = [self parseDeviceForPayload:addedDevicePayload];
            device.ID = (sfi_id) [deviceID intValue];
            [toolkit.devices addObject:device];
        }   
    }
    
    else if([commandType isEqualToString:DYNAMIC_DEVICE_UPDATED]){
        NSDictionary *devicesPayload = payload[DEVICES];
        NSString *deviceID = [[devicesPayload allKeys] objectAtIndex:0]; // Assumes payload always has one device.
        NSDictionary *updatedDevicePayload = [devicesPayload objectForKey:deviceID];
        
        for(Device *device in toolkit.devices){
            if(device.ID == [deviceID intValue]){
                [self updateDevice:device payload:updatedDevicePayload];
                break;
            }
        }
    }

    else if([commandType isEqualToString:DYNAMIC_DEVICE_REMOVED]){
        NSString *removedDeviceID = [payload[DEVICES] allKeys].firstObject;
        Device *toBeRemovedDevice;
        for(Device *device in toolkit.devices){
            if(device.ID == [removedDeviceID intValue]){
                toBeRemovedDevice = device;
            }
        }
        [toolkit.devices removeObject:toBeRemovedDevice];
    }
    else if([commandType isEqualToString:DYNAMIC_ALL_DEVICES_REMOVED]){
        [toolkit.devices removeAllObjects];
    }

    else if([commandType isEqualToString:DYNAMIC_INDEX_UPDATE]){
        NSDictionary *updatedDevice = payload[@"Devices"];
        for(Device *device in toolkit.devices){
            NSDictionary *valuesDic = updatedDevice[@(device.ID).stringValue];
            if(valuesDic != nil){
                NSDictionary *DeviceValuesDict = valuesDic[@"DeviceValues"];
                for(DeviceKnownValues *knownValue in device.knownValues){
                    NSDictionary *knownValueDic = DeviceValuesDict[@(knownValue.index).stringValue];
                    if (knownValueDic != nil) {
                        [self updateKnownValue:knownValueDic knownValues:knownValue];
                        break;
                    }
                }
            }
        }
    }
    toolkit.devices = [self getSortedDevices];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER object:nil];
}

-(NSMutableArray*)getSortedDevices{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *secondDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, secondDescriptor, nil];
    return [[toolkit.devices sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

- (void)asyncRequestNotificationPreferenceList:(NSString *)almondMAC {
    NSLog(@"toolkit - asyncRequestNotificationPreferenceList");
    if (almondMAC == nil) {
        SLog(@"asyncRequestRegisterForNotification : almond MAC is nil");
        return;
    }
    
    NotificationPreferenceListRequest *req = [NotificationPreferenceListRequest new];
    req.almondplusMAC = almondMAC;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST;
    cmd.command = req;
    
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:cmd];
}

- (void)onNotificationPrefDidChange:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];

    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSString *cloudMAC = data[@"data"];
    if([almond.almondplusMAC isEqualToString:cloudMAC] == NO){
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self configureNotificationModesForDevices];
    });
}

-(void)configureNotificationModesForDevices{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSArray *notificationList = [toolkit notificationPrefList:[AlmondManagement currentAlmond].almondplusMAC];
    for (Device *device in toolkit.devices) {
        [self configureNotificationMode:device preferences:notificationList];
    }
}

- (void)configureNotificationMode:(Device *)device preferences:(NSArray *)notificationList {
    sfi_id device_id = device.ID;
    
    //Check if current device ID is in the notification list
    for (SFINotificationDevice *currentDevice in notificationList) {
        if (currentDevice.deviceID == device_id) {
            //Set the notification mode for that notification preference
            NSLog(@"device name: %@, current device notification mode: %d", device.name, currentDevice.notificationMode);
            device.notificationMode = currentDevice.notificationMode;
            return;
        }
    }
    // missing preference means none has been set and is equivalent to 'off'
    device.notificationMode = SFINotificationMode_off;
}

- (void)onDynamicNotificationPreference:(id)sender{
    NSLog(@"onDynamicNotificationPreference");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NotificationPreferenceListResponse *prefResponse = data[@"data"];
    if(prefResponse.almondMAC.length == 0 || ![prefResponse.almondMAC isEqualToString:almond.almondplusMAC])
        return;
    
    NSArray *notificationList = prefResponse.notificationDeviceList;
    SFINotificationDevice *updatedDevice = notificationList.firstObject;
    NSLog(@"dynamic mode: %d", updatedDevice.notificationMode);
    for (Device *device in toolkit.devices) {
        if(device.ID == updatedDevice.deviceID){
            device.notificationMode = updatedDevice.notificationMode;
            NSLog(@"updated");
            break;
        }
    }
}


//-(void)addModeClientRebootDeviceTypes:(NSMutableArray*)genericDeviceTypes{
//    [genericDeviceTypes addObjectsFromArray:@[@"0", @"500", @"501"]];
//}
//
//-(void)addCommonGenericIndexes:(NSMutableArray *)genericIndexesArray{
//    NSDictionary *commonIndexes = [Device getCommonIndexesDict];
//    for(NSString *value in commonIndexes.allValues){
//        [genericIndexesArray addObject:value];
//    }
//}
//
//-(void)addClientGenericIndexes:(NSMutableArray*)genericIndexesArray{
//    for(NSNumber *clientIndex in [Client getClientGenericIndexes]){
//        [genericIndexesArray addObject:clientIndex.stringValue];
//    }
//}
//
//-(void)addModeClientRebootIndexes:(NSMutableArray*)genericIndexesArray{
//    [genericIndexesArray addObjectsFromArray:@[@"0", @"-30", @"-31"]];
//}


//DeviceListAndDynamicDeviceResponse parsing methods
- (Device *)parseDeviceForPayload:(NSDictionary *)payload {
    Device *device = [Device new];
    [self updateDevice:device payload:payload];
    return device;
}

- (void)updateDevice:(Device*)device payload:(NSDictionary*)payloadDevice{
    NSDictionary *payload = payloadDevice[@"Data"];
    device.name = payload[D_NAME];
    device.location = payload[LOCATION];
    device.type =[payload[D_TYPE] intValue];

    NSDictionary *valuesDic = payloadDevice[DEVICE_VALUE];
    if(valuesDic != nil)
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

- (void)updateKnownValue:(NSDictionary*)payload knownValues:(DeviceKnownValues*)values{
    values.valueName = payload[D_NAME];
    values.value = ![payload[VALUE] isKindOfClass:[NSString class]]? [payload[VALUE] stringValue]: payload[VALUE];
    values.genericIndex = payload[TYPE];
}

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
                                                                                  type:deviceType
                                                                           defaultIcon:genericDeviceDict[DEVICE_DEFAULT_ICON]
                                                                            isActuator:[genericDeviceDict[IS_ACTUATOR] boolValue]
                                                                           excludeFrom:genericDeviceDict[EXCLUDE_FROM]
                                                                               indexes:[self createDeviceIndexesDict:genericDeviceDict[INDEXES]]
                                                                             isTrigger:genericDeviceDict[ISTRIGGER]];
    return genericDeviceObject;
    
}

+(NSDictionary*)createDeviceIndexesDict:(NSDictionary*)indexesDict{
    NSMutableDictionary *indexes = [NSMutableDictionary new];
    NSArray *indexesKeys = indexesDict.allKeys;
    for(NSString *index in indexesKeys){
        NSDictionary *indexDict = indexesDict[index];
        DeviceIndex *deviceIndex = [[DeviceIndex alloc]initWithIndex:index
                                                        genericIndex:indexDict[GENERIC_INDEX_ID]
                                                               rowID:indexDict[ROW_NO]
                                                           placement:indexDict[@"Placement"]
                                                                 min:indexDict[@"min"]
                                                                 max:indexDict[@"max"]
                                                            appLabel:indexDict[APP_LABEL]? NSLocalizedString(indexDict[APP_LABEL], @""): nil];
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
        genericIndexObject = [self createGenericIndexForDic:genericIndexesDict[genericIndexID]
                                                      forID:genericIndexID];
        [mutableGenericIndex setObject:genericIndexObject forKey:genericIndexID];
    }
    return mutableGenericIndex;
}
+(GenericIndexClass*)createGenericIndexForDic:(NSDictionary*)genericIndexDict forID:(NSString*)ID{
    BOOL readOnly =[genericIndexDict[TYPE] isEqualToString:ACTUATOR]?NO:YES;
    GenericIndexClass *genericIndexObject = [[GenericIndexClass alloc]
                                             initWithLabel:NSLocalizedString(genericIndexDict[APP_LABEL],genericIndexDict[APP_LABEL])
                                             icon:genericIndexDict[INDEX_DEFAULT_ICON]
                                             type:genericIndexDict[TYPE]
                                             identifier:ID
                                             placement:genericIndexDict[PLACEMENT]
                                             values:[self createGenericValues:genericIndexDict[VALUES]]
                                             formatter:[self createFormatterFromIndexDicIfExists:genericIndexDict[FORMATTER]]
                                             layoutType:genericIndexDict[LAYOUT]
                                             commandType:[GenericIndexClass getCommandType:genericIndexDict[DEVICE_COMMAND_TYPE]]
                                             readOnly:readOnly
                                             excludeFrom:genericIndexDict[EXCLUDE_FROM]
                                             showToggleInRules:[genericIndexDict[@"ShowToggleInRules"] boolValue]
                                             indexName:genericIndexDict[INDEX_NAME]
                                             categoryLabel:genericIndexDict[@"Title"]?: @"3"
                                             property:genericIndexDict[PROPERTY]?:@"displayHere"
                                             header:genericIndexDict[D_HEADER]
                                             footer:genericIndexDict[D_FOOTER]
                                             elements:[self getElements:genericIndexDict genId:ID] navigateElements:[self getElements:genericIndexDict genId:ID] ];
    return genericIndexObject;
}
+ (NSArray *)getNevigateElements:(NSDictionary *)dict genId:(NSString *)genId{
    if(dict[NAVIGATEELEMENT])
        return dict[NAVIGATEELEMENT];
    else{
        return @[genId];
    }
}

+ (NSArray *)getElements:(NSDictionary *)dict genId:(NSString *)genId{
    if(dict[ELEMENTS])
        return dict[ELEMENTS];
    else{
//        NSMutableArray *array = [NSMutableArray new];
//        [array addObject:[NSNumber numberWithInteger:genId.integerValue]];
        return @[genId];
    }
}

+(Formatter*)createFormatterFromIndexDicIfExists:(NSDictionary*)formatterDict{
    if(formatterDict){
        float factor = formatterDict[FACTOR]? [formatterDict[FACTOR] floatValue]: 1;
        Formatter *formatter = [[Formatter alloc]initWithFactor:factor min:[formatterDict[MINMUM] intValue] max:[formatterDict[MAXIMUM] intValue] units:formatterDict[UNIT] prefix:NSLocalizedString(formatterDict[PREFIX],formatterDict[PREFIX])];
        return formatter;
    }
    return nil;
}

+(NSMutableDictionary *)createGenericValues:(NSDictionary*)genericValuesDict{
    if(genericValuesDict){//NSLocalizedString(@"'s Smoke is gone.", @"'s Smoke is gone.")
        NSArray *valueKeys = genericValuesDict.allKeys;
        NSMutableDictionary *genericValues = [NSMutableDictionary new];
        for(NSString *value in valueKeys){
            NSDictionary *valueDict = genericValuesDict[value];
            GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:NSLocalizedString(valueDict[APP_LABEL],valueDict[APP_LABEL])
                                                                             icon:valueDict[ICON]
                                                                      toggleValue:valueDict[TOGGLE_VALUE]
                                                                            value:value
                                                                      excludeFrom:valueDict[EXCLUDE_FROM]
                                                                        eventType:valueDict[EVENT_TYPE] notificationText:NSLocalizedString(valueDict[NOTIFICATION],valueDict[NOTIFICATION])];
            [genericValues setObject:genericValue forKey:value];
        }
        return genericValues;
    }
    return nil;
}/*NSLocalizedString(genericIndexDict[APP_LABEL],genericIndexDict[APP_LABEL])*/


- (NSDictionary*)parseJson:(NSString*)fileName{
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

-(void)onAlmondRouterCommandResponse:(id)sender{
    NSLog(@"Device parser - onAlmondRouterCommandResponse");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    
    SFIGenericRouterCommand *genericRouterCommand = (SFIGenericRouterCommand *) data[@"data"];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    switch (genericRouterCommand.commandType) {
        case SFIGenericRouterCommandType_WIRELESS_SUMMARY: {
            SFIRouterSummary *routerSummary = (SFIRouterSummary *)genericRouterCommand.command;
            NSLog(@"routersummary: %@", routerSummary);
            if([toolkit currentConnectionMode] == SFIAlmondConnectionMode_cloud)
                [LocalNetworkManagement tryUpdateLocalNetworkSettingsForAlmond:[AlmondManagement currentAlmond].almondplusMAC withRouterSummary:routerSummary];
            break;
        }
    }
}
@end
