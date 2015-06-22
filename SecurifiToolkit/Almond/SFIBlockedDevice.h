//
//  SFIBlockedDevice.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 12/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

//todo badly named: something more descriptive and accurate like AlmondBlockedClient
//todo badly modeled: "blocked" and "connected" should not be distinct types

@interface SFIBlockedDevice : NSObject
//<BlockedMAC>10:60:4b:d9:60:84</BlockedMAC>
@property(nonatomic, copy) NSString *deviceMAC;
@end
