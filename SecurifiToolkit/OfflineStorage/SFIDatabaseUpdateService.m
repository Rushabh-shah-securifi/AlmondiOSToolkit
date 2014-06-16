//
//  SFIDatabaseUpdateService.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 23/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIDatabaseUpdateService.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SFIOfflineDataManager.h"

@implementation SFIDatabaseUpdateService

+ (void)startDatabaseUpdateService {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDataCloudResponseCallback:)
                                                 name:DEVICE_DATA_CLOUD_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceValueListResponseCallback:)
                                                 name:DEVICE_VALUE_CLOUD_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dynamicAlmondListAddCallback:)
                                                 name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dynamicAlmondListDeleteCallback:)
                                                 name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dynamicAlmondNameChangeCallback:)
                                                 name:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER
                                               object:nil];
}

+ (void)stopDatabaseUpdateService {
    // [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DEVICE_DATA_CLOUD_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DEVICE_VALUE_CLOUD_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DYNAMIC_ALMOND_NAME_CHANGE_NOTIFIER
                                                  object:nil];
}

#pragma mark - Cloud command handlers

+ (void)deviceDataCloudResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        DeviceListResponse *obj = (DeviceListResponse *) [data valueForKey:@"data"];

        BOOL isSuccessful = obj.isSuccessful;
        if (isSuccessful) {
            NSMutableArray *deviceList = obj.deviceList;
            NSString *currentMAC = obj.almondMAC;

            //Update offline storage
            [SFIOfflineDataManager writeDeviceList:deviceList currentMAC:currentMAC];

            //Compare the list with device value list size and correct the list accordingly if any device was deleted
            //Read device value list from storage
            NSMutableArray *offlineDeviceValueList = [SFIOfflineDataManager readDeviceValueList:currentMAC];

            //Compare the size
            if ([deviceList count] < [offlineDeviceValueList count]) {
                for (SFIDevice *currentDevice in deviceList) {
                    for (SFIDeviceValue *offlineDeviceValue in offlineDeviceValueList) {
                        if (currentDevice.deviceID == offlineDeviceValue.deviceID) {
                            offlineDeviceValue.isPresent = TRUE;
                            break;
                        }
                    }
                }

                //Delete from the device value list
                NSMutableArray *tempDeviceValueList = [[NSMutableArray alloc] init];
                for (SFIDeviceValue *offlineDeviceValue in offlineDeviceValueList) {
                    if (offlineDeviceValue.isPresent) {
                        [tempDeviceValueList addObject:offlineDeviceValue];
                    }
                }

                [SFIOfflineDataManager writeDeviceValueList:tempDeviceValueList currentMAC:currentMAC];
            }
        }
    }
}

+ (void)deviceValueListResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        DeviceValueResponse *obj = (DeviceValueResponse *) [data valueForKey:@"data"];

        NSString *currentMAC = obj.almondMAC;

        NSMutableArray *cloudDeviceValueList;
        NSMutableArray *mobileDeviceValueList;
        NSMutableArray *mobileDeviceKnownValues;
        NSMutableArray *cloudDeviceKnownValues;

        cloudDeviceValueList = obj.deviceValueList;
        mobileDeviceValueList = [SFIOfflineDataManager readDeviceValueList:currentMAC];

        if (mobileDeviceValueList != nil) {
            BOOL isDeviceFound = FALSE;
            for (SFIDeviceValue *currentMobileValue in mobileDeviceValueList) {

                for (SFIDeviceValue *currentCloudValue in cloudDeviceValueList) {
                    if (currentMobileValue.deviceID == currentCloudValue.deviceID) {
                        isDeviceFound = TRUE;
                        currentCloudValue.isPresent = TRUE;
                        mobileDeviceKnownValues = currentMobileValue.knownValues;
                        cloudDeviceKnownValues = currentCloudValue.knownValues;

                        for (SFIDeviceKnownValues *currentMobileKnownValue in mobileDeviceKnownValues) {

                            for (SFIDeviceKnownValues *currentCloudKnownValue in cloudDeviceKnownValues) {
                                if (currentMobileKnownValue.index == currentCloudKnownValue.index) {
                                    //Update Value
                                    [currentMobileKnownValue setValue:currentCloudKnownValue.value];
                                    break;
                                }
                            }
                        }
                        [currentMobileValue setKnownValues:mobileDeviceKnownValues];
                    }
                }
            }

            if (!isDeviceFound) {
                //Traverse the list and add the new value to offline list
                for (SFIDeviceValue *currentCloudValue in cloudDeviceValueList) {
                    if (!currentCloudValue.isPresent) {
                        [mobileDeviceValueList addObject:currentCloudValue];
                    }
                }
            }
        }
        else {
            mobileDeviceValueList = cloudDeviceValueList;
        }

        //deviceValueList = mobileDeviceValueList;
        //Update offline storage
        [SFIOfflineDataManager writeDeviceValueList:mobileDeviceValueList currentMAC:currentMAC];
    }
}

+ (void)dynamicAlmondListAddCallback:(id)sender {
    // [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
        if (obj.isSuccessful) {
            //Write Almond List offline - New list with added almond
            [SFIOfflineDataManager writeAlmondList:obj.almondPlusMACList];
        }
    }
}

+ (void)dynamicAlmondListDeleteCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];

        if (obj.isSuccessful) {
            NSMutableArray *offlineAlmondList = [SFIOfflineDataManager readAlmondList];
            NSMutableArray *deletedAlmondList = obj.almondPlusMACList;
            NSMutableArray *newAlmondList = [[NSMutableArray alloc] init];
            SFIAlmondPlus *deletedAlmond = deletedAlmondList[0];

            //Update Almond List
            for (SFIAlmondPlus *currentOfflineAlmond in offlineAlmondList) {
                if (![currentOfflineAlmond.almondplusMAC isEqualToString:deletedAlmond.almondplusMAC]) {
                    //Add the current Almond from list except the deleted one
                    [newAlmondList addObject:currentOfflineAlmond];
                }
            }

            [SFIOfflineDataManager writeAlmondList:newAlmondList];

            //Update Hash List
            [SFIOfflineDataManager deleteHashForAlmond:deletedAlmond.almondplusMAC];

            //Update Device List
            [SFIOfflineDataManager deleteDeviceDataForAlmond:deletedAlmond.almondplusMAC];

            //Update Device Value List
            [SFIOfflineDataManager deleteDeviceValueForAlmond:deletedAlmond.almondplusMAC];
        }

    }
}

+ (void)dynamicAlmondNameChangeCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        DynamicAlmondNameChangeResponse *obj = (DynamicAlmondNameChangeResponse *) [data valueForKey:@"data"];
        NSMutableArray *offlineAlmondList = [SFIOfflineDataManager readAlmondList];

        for (SFIAlmondPlus *currentOfflineAlmond in offlineAlmondList) {
            if ([currentOfflineAlmond.almondplusMAC isEqualToString:obj.almondplusMAC]) {
                //Change the name of the current almond in the offline list
                currentOfflineAlmond.almondplusName = obj.almondplusName;
                break;
            }
        }

        //Update the list
        [SFIOfflineDataManager writeAlmondList:offlineAlmondList];
    }
}
@end
