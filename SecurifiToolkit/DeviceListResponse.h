//
//  DeviceListResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceListResponse : NSObject
@property BOOL isSuccessful;
@property unsigned int deviceCount;
@property NSString *reason;
@property NSMutableArray *deviceList;
@property NSString *almondMAC; //For dynamic update

@end