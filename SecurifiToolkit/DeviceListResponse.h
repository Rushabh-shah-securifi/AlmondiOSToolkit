//
//  DeviceListResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceListResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) unsigned int deviceCount;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) NSMutableArray *deviceList;
@property(nonatomic, copy) NSString *almondMAC; //For dynamic update

@end
