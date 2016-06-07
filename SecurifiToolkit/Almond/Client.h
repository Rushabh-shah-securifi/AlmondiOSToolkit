//
//  Client.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

typedef NS_ENUM(NSInteger, DeviceAllowedType){
    DeviceAllowed_Always=0,
    DeviceAllowed_Blocked=1,
    DeviceAllowed_OnSchedule=2
};

@interface Client : NSObject <NSCopying>
//<ConnectedDevice><Name>ashutosh</Name><IP>1678379540</IP><MAC>10:60:4b:d9:60:84</MAC></ConnectedDevice>
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *deviceIP;
@property(nonatomic, strong) NSString *manufacturer;
@property(nonatomic, strong) NSString *rssi;
@property(nonatomic, retain) NSString *deviceMAC;
@property(nonatomic, retain) NSString *deviceConnection;
@property(nonatomic, retain) NSString *deviceID;
@property(nonatomic, retain) NSString *deviceType;
@property(nonatomic, assign) NSInteger timeout;
@property(nonatomic, retain) NSString *deviceLastActiveTime;
@property(nonatomic, assign) BOOL deviceUseAsPresence;
@property(nonatomic, assign) BOOL isActive;

@property(nonatomic) DeviceAllowedType deviceAllowedType;
@property(nonatomic) NSString *deviceSchedule;
@property(nonatomic) NSString *category;
@property(nonatomic) BOOL *canBeBlocked;

@property(nonatomic) SFINotificationMode notificationMode;

- (NSString *)iconName;

- (NSString *)getNotificationTypeByName:(NSString *)name;

- (NSString *)getNotificationNameByType:(NSString *)type;

+ (Client *)findClientByID:(NSString *)clientID;

+(NSArray*) getClientGenericIndexes;

+(NSString*)getOrSetValueForClient:(Client*)client genericIndex:(int)genericIndex newValue:(NSString*)newValue ifGet:(BOOL)get;

+(NSString *)getScheduleById:(NSString*)clientId;

+ (BOOL)findClientByMAC:(NSString *)mac;

+ (Client *)getClientByMAC:(NSString *)mac;

@end
