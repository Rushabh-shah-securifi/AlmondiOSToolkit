//
//  SFIDatabaseUpdateService.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 23/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIDatabaseUpdateService.h"
#import <SecurifiToolkit/SecurifiToolkit.h>

@interface SFIDatabaseUpdateService ()
@property BOOL started;
@end

@implementation SFIDatabaseUpdateService

- (void)startDatabaseUpdateService {
    if (self.started) {
        return;
    }
    self.started = YES;


}

- (void)stopDatabaseUpdateService {

}

#pragma mark - Cloud command handlers

- (void)deviceDataCloudResponseCallback:(id)sender {
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
            NSArray *offlineDeviceValueList = [SFIOfflineDataManager readDeviceValueList:currentMAC];

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

- (void)deviceValueListResponseCallback:(id)sender {
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
        mobileDeviceValueList = [NSMutableArray arrayWithArray:[SFIOfflineDataManager readDeviceValueList:currentMAC]];

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




@end
