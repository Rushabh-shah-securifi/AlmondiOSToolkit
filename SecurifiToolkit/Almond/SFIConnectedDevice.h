//
//  SFIConnectedDevice.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

//todo badly named; something more descriptive and accurate like AlmondConnectedClient

@interface SFIConnectedDevice : NSObject
//<ConnectedDevice><Name>ashutosh</Name><IP>1678379540</IP><MAC>10:60:4b:d9:60:84</MAC></ConnectedDevice>
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *deviceIP;
@property(nonatomic, copy) NSString *deviceMAC;
@end
