//
//  AlmondListManagement.m
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondListManagement.h"

@implementation AlmondListManagement

+ (void)onAlmondListResponse:(AlmondListResponse *)obj network:(Network *)network {
    
    SecurifiToolkit* toolKit = [SecurifiToolkit sharedInstance];
    
    if (!obj.isSuccessful) {
        return;
    }
    
    NSArray *almondList = obj.almondPlusMACList;
    
    // Store the new list
    [toolKit.dataManager writeAlmondList:almondList];
    
    // Ensure Current Almond is consistent with new list
    SFIAlmondPlus *plus = [self manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
    if(plus!=nil)
    // After requesting the Almond list, we then want to get additional info
    [toolKit asyncInitializeConnection2:network];
    
    // Tell the world
    [toolKit postNotification:kSFIDidUpdateAlmondList data:plus];
}

+ (void)onDynamicAlmondListAdd:(AlmondListResponse *)obj {
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    if (obj == nil) {
        return;
    }
    if (!obj.isSuccessful) {
        return;
    }
    
    NSArray *almondList = obj.almondPlusMACList;
    
    // Store the new list
    [toolkit.dataManager writeAlmondList:almondList];
    
    // Ensure Current Almond is consistent with new list
    SFIAlmondPlus *plus = [self manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:YES];
    
    // Tell the world that this happened
    [toolkit postNotification:kSFIDidUpdateAlmondList data:plus];
}

+ (void)onDynamicAlmondListDelete:(AlmondListResponse *)obj network:(Network *)network {
    if (!obj.isSuccessful) {
        return;
    }
    
    SecurifiToolkit *toolKit = [SecurifiToolkit sharedInstance];
    NSArray *newAlmondList = @[];
    for (SFIAlmondPlus *deleted in obj.almondPlusMACList) {
        // remove cached data about the Almond and sensors
        newAlmondList = [toolKit.dataManager deleteAlmond:deleted];
        
        if (toolKit.config.enableNotifications) {
            // clear out Notification settings
            [network.networkState clearAlmondMode:deleted.almondplusMAC];
            [toolKit.notificationsDb deleteNotificationsForAlmond:deleted.almondplusMAC];
        }
    }
    
    // Ensure Current Almond is consistent with new list
    SFIAlmondPlus *plus = [self manageCurrentAlmondOnAlmondListUpdate:newAlmondList manageCurrentAlmondChange:YES];
//    [toolKit.devices removeAllObjects];
//    [toolKit.clients removeAllObjects];
//    [toolKit.scenesArray removeAllObjects];
//    [toolKit.ruleList removeAllObjects];
    [toolKit postNotification:kSFIDidUpdateAlmondList data:plus];
}

+ (void)onDynamicAlmondNameChange:(DynamicAlmondNameChangeResponse *)obj {
   
    SecurifiToolkit *toolKit = [SecurifiToolkit sharedInstance];
    NSString *almondName = obj.almondplusName;
    if (almondName.length == 0) {
        return;
    }
    
    SFIAlmondPlus *changed = [toolKit.dataManager changeAlmondName:almondName almondMac:obj.almondplusMAC];
    if (changed) {
        SFIAlmondPlus *current = [toolKit currentAlmond];
        if ([current isEqualAlmondPlus:changed]) {
            changed.colorCodeIndex = current.colorCodeIndex;
            [toolKit currentAlmond].almondplusName=almondName;
            //[self setCurrentAlmond:changed];
        }
        
        // Tell the world so they can update their view
        [toolKit postNotification:kSFIDidChangeAlmondName data:obj];
    }
}

// When the cloud almond list is changed, ensure the Current Almond setting is consistent with the list.
// This method has side-effects and can change settings.
// Returns the current Almond, which might or might not be the same as the old one. May return nil.
+ (SFIAlmondPlus *)manageCurrentAlmondOnAlmondListUpdate:(NSArray *)almondList manageCurrentAlmondChange:(BOOL)doManage {
    // if current is "local only" then no need to inspect the almond list; just return the current one.
    NSLog(@"i am called");
    SecurifiToolkit * toolKit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *current = [toolKit currentAlmond];
    if (current.linkType == SFIAlmondPlusLinkType_local_only) {
        return current;
    }
    
    // Manage the "Current selected Almond" value
    if (almondList.count == 0) {
        [toolKit purgeStoredData];
        return nil;
    }
    
    
    
    else if (almondList.count == 1) {
        SFIAlmondPlus *currentAlmond = almondList[0];
        if (doManage) {
            
            [toolKit setCurrentAlmond:currentAlmond];
        }
        else {
            [AlmondManagement writeCurrentAlmond:currentAlmond];
        }
        return currentAlmond;
    }
    else {
        if (current) {
            for (SFIAlmondPlus *almond in almondList) {
                if ([almond.almondplusMAC isEqualToString:current.almondplusMAC]) {
                    // Current one is still in list, so leave it as current.
                    return almond;
                }
            }
        }
        
        // Current one is not in new list.
        // Just pick the first one in this case
        SFIAlmondPlus *currentAlmond = almondList[0];
        if (doManage) {
            [toolKit setCurrentAlmond:currentAlmond];
        }
        else {
            [AlmondManagement writeCurrentAlmond:currentAlmond];
        }
        return currentAlmond;
    }
}

@end
