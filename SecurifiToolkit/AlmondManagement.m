    //
//  AlmondManagement.m
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondManagement.h"
#import "SecurifiToolKit.h"

@implementation AlmondManagement

+ (void)removeCurrentAlmond {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kPREF_CURRENT_ALMOND];
    [prefs synchronize];
}

+ (void)setCurrentAlmond:(SFIAlmondPlus *)almond {
    if (!almond) {
        return;
    }
    [self writeCurrentAlmond:almond];
    [self manageCurrentAlmondChange:almond];
    [[SecurifiToolkit sharedInstance] postNotification:kSFIDidChangeCurrentAlmond data:almond];
}

+ (void)writeCurrentAlmond:(SFIAlmondPlus *)almond {
   if (!almond) {
        return;
    }
    NSLog(@"i am called");
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:almond];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:kPREF_CURRENT_ALMOND];
    [defaults synchronize];
}

+ (void)manageCurrentAlmondChange:(SFIAlmondPlus *)almond {
    NSLog(@"toolkit - manageCurrentAlmondChange");
    if (!almond) {
        return;
    }
    
    NSString *mac = almond.almondplusMAC;
    SecurifiToolkit* toolKit = [SecurifiToolkit sharedInstance];
    // reset connections
    if([toolKit currentConnectionMode]==SFIAlmondConnectionMode_local){
        [toolKit tryShutdownAndStartNetworks:toolKit.currentConnectionMode];
        return;
    }
    [toolKit cleanUp];
    
    NSLog(@"almond.linktype: %d", almond.linkType);
    
    GenericCommand * cmd = [toolKit tryRequestAlmondMode:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    NSLog(@"device request send");
    cmd = [GenericCommand requestSensorDeviceList:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    NSLog(@"clients request send");
    cmd = [GenericCommand requestAlmondClients:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    NSLog(@"scene request send ");
    cmd = [GenericCommand requestSceneList:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    NSLog(@" rule request send ");
    cmd = [GenericCommand requestAlmondRules:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    NSLog(@" requestRouterSummary request send ");
    cmd = [GenericCommand requestRouterSummary:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    // refresh notification preferences; currently, we cannot rely on receiving dynamic updates for these values and so always refresh.
    //    [self asyncRequestNotificationPreferenceList:mac]; //mk, currently requesting it on almond list response in device parser
}

+ (SFIAlmondPlus *)currentAlmond {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kPREF_CURRENT_ALMOND];
    if (data) {
        SFIAlmondPlus *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return object;
    }
    else {
        return nil;
    }
}

+ (SFIAlmondPlus *)cloudAlmond:(NSString *)almondMac {
    return [[SecurifiToolkit sharedInstance].dataManager readAlmond:almondMac];
}

+ (NSArray *)almondList {
    return [[SecurifiToolkit sharedInstance].dataManager readAlmondList];
}

+ (BOOL)almondExists:(NSString *)almondMac {
    NSArray *list = [self almondList];
    for (SFIAlmondPlus *almond in list) {
        if ([almond.almondplusMAC isEqualToString:almondMac]) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray *)localLinkedAlmondList {
    if (![SecurifiToolkit sharedInstance].config.enableLocalNetworking) {
        return nil;
    }
    
    // Below is an important filtering process:
    // in effect, we choose to use the Cloud Almond representation for matching
    // local network configs, because the Almond#linkType property will indicate
    // the almond supports both local and cloud network connections. This will ensure the
    // UI can do the right thing and show the right message to the user when connection modes
    // are switched.

    // Note for large lists of almonds, the way the data manger internally manages cloud almond lists
    // is inefficient for these sorts of operations, and a dictionary data structure would allow for
    // fast look up, instead of iteration.
    NSMutableSet *cloud_set = [NSMutableSet setWithArray:[self almondList]];
    
    NSDictionary *local_settings = [[SecurifiToolkit sharedInstance].dataManager readAllAlmondLocalNetworkSettings];
    NSMutableArray *local_almonds = [NSMutableArray array];
    
    for (NSString *mac in local_settings.allKeys) {
        SFIAlmondPlus *localAlmond;
        
        for (SFIAlmondPlus *cloud in cloud_set) {
            if ([cloud.almondplusMAC isEqualToString:mac]) {
                localAlmond = cloud;
                [cloud_set removeObject:cloud];
                break;
            }
        }
        
        if (!localAlmond) {
            SFIAlmondLocalNetworkSettings *setting = local_settings[mac];
            localAlmond = setting.asLocalLinkAlmondPlus;
        }
        
        if (localAlmond) {
            [local_almonds addObject:localAlmond];
        }
    }
    
    if (local_almonds.count == 0) {
        return nil;
    }
    
    // Sort the local Almonds alphabetically
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"almondplusName" ascending:YES];
    [local_almonds sortUsingDescriptors:@[sort]];
    
    return local_almonds;
}

#pragma mark - Almond List Management

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
    [toolKit postNotification:kSFIDidUpdateAlmondList data:plus];
}

+ (void)onDynamicAlmondNameChange:(DynamicAlmondNameChangeResponse *)obj {
    
    SecurifiToolkit *toolKit = [SecurifiToolkit sharedInstance];
    NSString *almondName = obj.almondplusName;
    if (almondName.length == 0) {
        return;
    }
    NSLog(@"Came here onDynamicAlmondNameChange %@",almondName);
    SFIAlmondPlus *changed = [toolKit.dataManager changeAlmondName:almondName almondMac:obj.almondplusMAC];
    if (changed) {
        SFIAlmondPlus *current = [toolKit currentAlmond];
        NSLog(@"Came here onDynamicAlmondNameChange inside changed %@",almondName);
        if ([current isEqualAlmondPlus:changed]) {
            changed.colorCodeIndex = current.colorCodeIndex;
            //[toolKit currentAlmond].almondplusName=almondName;
            NSLog(@"Came here after settings %@",[toolKit currentAlmond].almondplusName);
            [toolKit writeCurrentAlmond:changed];
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
