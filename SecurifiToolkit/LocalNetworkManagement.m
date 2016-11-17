//
//  LocalNetworkMangement.m
//  SecurifiToolkit
//
//  Created by Masood on 10/24/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "LocalNetworkManagement.h"
#import "Securifitoolkit.h"
#import "AlmondManagement.h"

@implementation LocalNetworkManagement

+ (SFIAlmondLocalNetworkSettings *)localNetworkSettingsForAlmond:(NSString *)almondMac {
    return [[SecurifiToolkit sharedInstance].dataManager readAlmondLocalNetworkSettings:almondMac];
}

+ (void)removeLocalNetworkSettingsForAlmond:(NSString *)almondMac {
    NSLog(@"i am called");
    if (!almondMac) {
        return;
    }
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    [toolkit.dataManager deleteLocalNetworkSettingsForAlmond:almondMac];
    
    SFIAlmondPlus *currentAlmond = toolkit.currentAlmond;
    
    if (currentAlmond!=nil && [currentAlmond.almondplusMAC isEqualToString:almondMac]) {
        
        if([toolkit currentConnectionMode]==SFIAlmondConnectionMode_local){
            NSLog(@"Current Almond equals is ");
            [toolkit tearDownNetwork];
        }
        
        [AlmondManagement removeCurrentAlmond];
        
        NSArray *cloud = toolkit.almondList;
        if (cloud.count > 0) {
            [toolkit setCurrentAlmond:cloud.firstObject];
        }
        else {
            NSArray *local = toolkit.localLinkedAlmondList;
            if (local.count > 0) {
                [toolkit setCurrentAlmond:local.firstObject];
            }
        }
    }
    
    [toolkit postNotification:kSFIDidUpdateAlmondList data:nil];
}

+ (void)storeLocalNetworkSettings:(SFIAlmondLocalNetworkSettings *)settings {
    // guard against bad data
    if (![settings hasCompleteSettings]) {
        NSLog(@"storeLocalNetworkSettings");
        return;
    }
    
    [[SecurifiToolkit sharedInstance].dataManager writeAlmondLocalNetworkSettings:settings];
}

+ (void)tryUpdateLocalNetworkSettingsForAlmond:(NSString *)almondMac withRouterSummary:(const SFIRouterSummary *)summary {
    NSLog(@"tryUpdateLocalNetworkSettingsForAlmond - mac: %@", almondMac);
    SFIAlmondLocalNetworkSettings *settings = [self localNetworkSettingsForAlmond:almondMac];
    NSLog(@"settings: %@", settings);
    NSLog(@"summary: %@", summary);
    if (!settings) {
        settings = [SFIAlmondLocalNetworkSettings new];
        settings.almondplusMAC = almondMac;
        
        // very important: copy name to settings, if possible
        SFIAlmondPlus *plus = [AlmondManagement cloudAlmond:almondMac];
        if (plus) {
            settings.almondplusName = plus.almondplusName;
        }
    }
    
    if (summary.login) {
        settings.login = summary.login;
    }
    if (summary.password) {
        NSLog(@"summary.password = %@, uptime: %@",summary.password, summary.uptime);
        NSString *decrypted = [summary decryptPassword:almondMac];
        NSLog(@"decrypted: %@", decrypted);
        if (decrypted) {
            settings.password = decrypted;
        }
        NSLog(@"settings.password: %@", settings.password);
    }
    if (summary.url) {
        settings.host = summary.url;
    }
    
    [self storeLocalNetworkSettings:settings];
}


@end