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
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *deviceIP;
@property(nonatomic, retain) NSString *deviceMAC;
@property(nonatomic, retain) NSString *deviceConnection;
@property(nonatomic, retain) NSString *deviceID;
@property(nonatomic, retain) NSString *deviceType;
@property(nonatomic, assign) NSInteger timeout;
@property(nonatomic, retain) NSString *deviceLastActiveTime;
@property(nonatomic, assign) BOOL deviceUseAsPresence;
@property(nonatomic, assign) BOOL isActive;

- (NSString *)iconName;

- (NSString *)getNotificationTypeByName:(NSString *)name;

- (NSString *)getNotificationNameByType:(NSString *)type;
@end
