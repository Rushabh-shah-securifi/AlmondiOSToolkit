//
//  AlmondManagement.h
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#ifndef AlmondManagement_h
#define AlmondManagement_h
#import <Foundation/Foundation.h>
#import "SFIAlmondPlus.h"
#import "SecurifiToolKit.h"
#import "Network.h"
#import "NetworkState.h"
#import "SFIAlmondLocalNetworkSettings.h"

@interface AlmondManagement : NSObject

+ (void)removeCurrentAlmond;
+ (void)setCurrentAlmond:(SFIAlmondPlus *)almond;
+ (void)writeCurrentAlmond:(SFIAlmondPlus *)almond;
+ (void)manageCurrentAlmondChange:(SFIAlmondPlus *)almond;
+ (SFIAlmondPlus *)currentAlmond;
+ (SFIAlmondPlus *)cloudAlmond:(NSString *)almondMac;
+ (NSArray *)localLinkedAlmondList;
+ (BOOL)almondExists:(NSString *)almondMac;

@end
#endif /* AlmondManagement_h */
