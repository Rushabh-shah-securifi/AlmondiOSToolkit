//
//  AlmondListManagement.h
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#ifndef AlmondListManagement_h
#define AlmondListManagement_h

#import <Foundation/Foundation.h>
#import "AlmondListResponse.h"
#import "SecurifiToolKit.h"
#import "Network.h"
#import "NetworkState.h"
#import "AlmondManagement.h"


@interface AlmondListManagement : NSObject
+ (void)onAlmondListResponse:(AlmondListResponse *)obj network:(Network *)network;
+ (void)onDynamicAlmondListAdd:(AlmondListResponse *)obj;
+ (void)onDynamicAlmondListDelete:(AlmondListResponse *)obj network:(Network *)network;
+ (void)onDynamicAlmondNameChange:(NSData *)data;
+ (SFIAlmondPlus *)manageCurrentAlmondOnAlmondListUpdate:(NSArray *)almondList manageCurrentAlmondChange:(BOOL)doManage;

@end

#endif /* AlmondListManagement_h */
