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
#import "Network.h"
#import "NetworkState.h"
#import "AlmondListResponse.h"
#import "DynamicAlmondNameChangeResponse.h"
#import "AlmondModeResponse.h"
#import "DynamicAlmondModeChange.h"
#import "GenericCommandResponse.h"

@class SFIGenericRouterCommand;

@interface AlmondManagement : NSObject

+ (NSMutableArray*)getOwnedAlmondList;
+ (NSMutableArray*)getSharedAlmondList;
+ (void)initializeValues;
+ (void)removeCurrentAlmond;
+ (void)setCurrentAlmond:(SFIAlmondPlus *)almond;
+ (void)writeCurrentAlmond:(SFIAlmondPlus *)almond;
+ (NSArray *)almondList;
+ (void)manageCurrentAlmondChange:(SFIAlmondPlus *)almond;
+ (SFIAlmondPlus *)currentAlmond;
+ (SFIAlmondPlus *)cloudAlmond:(NSString *)almondMac;
+ (NSArray *)localLinkedAlmondList;
+ (BOOL)almondExists:(NSString *)almondMac;

//Almond List Management
+ (void)onAlmondListResponse:(AlmondListResponse *)obj network:(Network *)network;
+ (void)onDynamicAlmondListAdd:(AlmondListResponse *)obj;
+ (void)onDynamicAlmondListDelete:(AlmondListResponse *)obj network:(Network *)network;
+ (void)onDynamicAlmondNameChange:(DynamicAlmondNameChangeResponse *)data;
+ (SFIAlmondPlus *)manageCurrentAlmondOnAlmondListUpdate:(NSArray *)almondList manageCurrentAlmondChange:(BOOL)doManage;

//Almond mode change  callbacks
+ (void)onAlmondModeChangeCompletion:(NSDictionary*)res network:(Network *)network;
+ (void)onAlmondModeResponse:(AlmondModeResponse *)res network:(Network *)network;
+ (void)onDynamicAlmondModeChange:(DynamicAlmondModeChange *)res network:(Network *)network;
+ (void)storeAlmondList: (NSDictionary*)dictionary;

//Almond RouterResponse Callbacks
+ (void)onAlmondRouterGenericNotification:(GenericCommandResponse *)res network:(Network *)network;
+ (void)onAlmondRouterGenericCommandResponse:(GenericCommandResponse *)res network:(Network *)network;
+ (void)onAlmondRouterCommandResponse:(SFIGenericRouterCommand *)res network:(Network *)network;

@end
#endif /* AlmondManagement_h */
