    //
//  AlmondManagement.m
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondManagement.h"

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
    
    NSArray *devices = [self deviceList:mac];
    if (devices.count == 0) {
        DLog(@"%s: devices empty: requesting device list for current almond: %@", __PRETTY_FUNCTION__, mac);
        [self asyncRequestDeviceList:mac];
    }
    
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

+ (BOOL)isCurrentTemperatureFormatFahrenheit {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [defaults boolForKey:kCURRENT_TEMPERATURE_FORMAT];
    return value;
}

+ (void)setCurrentTemperatureFormatFahrenheit:(BOOL)format {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:format forKey:kCURRENT_TEMPERATURE_FORMAT];
    [defaults synchronize];
}

+ (int)convertTemperatureToCurrentFormat:(int)temperature {
    if ([self isCurrentTemperatureFormatFahrenheit]) {
        return temperature;
    } else {
        return (int) lround((temperature - 32) / 1.8);
    }
}

+ (NSString *)getTemperatureWithCurrentFormat:(int)temperature {
    if ([self isCurrentTemperatureFormatFahrenheit]) {
        return [NSString stringWithFormat:@"%d °F", temperature];
    } else {
        return [NSString stringWithFormat:@"%d °C", (int) lround((temperature - 32) / 1.8)];
    }
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
    //
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

+ (NSArray *)deviceList:(NSString *)almondMac {
    return [[SecurifiToolkit sharedInstance].dataManager readDeviceList:almondMac];
}

+ (NSArray *)deviceValuesList:(NSString *)almondMac {
    return [[SecurifiToolkit sharedInstance].dataManager readDeviceValueList:almondMac];
}

+ (NSArray *)notificationPrefList:(NSString *)almondMac {
    return [[SecurifiToolkit sharedInstance].dataManager readNotificationPreferenceList:almondMac];
}

#pragma mark - Device and Device Value Management

+ (void)asyncRequestDeviceList:(NSString *)almondMac {
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        NetworkState *state = aNetwork.networkState;
        if ([state willFetchDeviceListFetchedForAlmond:almondMac]) {
            return NO;
        }
        
        [state markWillFetchDeviceListForAlmond:almondMac];
        return YES;
    };
    
    BOOL local = [[SecurifiToolkit sharedInstance] useLocalNetwork:almondMac];
}

+ (void)asyncRequestDeviceValueList:(NSString *)almondMac {
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        [aNetwork.networkState markDeviceValuesFetchedForAlmond:almondMac];
        return YES;
    };
    
    BOOL local = [[SecurifiToolkit sharedInstance] useLocalNetwork:almondMac];
}

+ (BOOL)tryRequestDeviceValueList:(NSString *)almondMac {
    SecurifiToolkit *toolKit = [SecurifiToolkit sharedInstance];
    BOOL local = [toolKit useLocalNetwork:almondMac];
    Network *network = local ? [toolKit setUpNetwork] : toolKit.network;
    
    NetworkState *state = network.networkState;
    if ([state wasDeviceValuesFetchedForAlmond:almondMac]) {
        return NO;
    }
    [state markDeviceValuesFetchedForAlmond:almondMac];
    
    [self asyncRequestDeviceValueList:almondMac];
    
    return YES;
}

@end
