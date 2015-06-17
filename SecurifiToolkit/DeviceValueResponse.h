//
//  DeviceValueResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceValueResponse : NSObject

+ (instancetype)parseJson:(NSDictionary *)payload;

@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) unsigned int deviceCount;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) NSMutableArray *deviceValueList; // list of SFIDeviceValue
@property(nonatomic, copy) NSString *almondMAC;
@end
