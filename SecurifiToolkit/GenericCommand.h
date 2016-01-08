//
//  GenericCommand.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandTypes.h"
#import "SecurifiTypes.h"

@class SFIDeviceKnownValues;
@class SFIDevice;
@class SFIWirelessSetting;
@class Network;
@class GenericCommand;

// return YES to continue processing; NO to halt it
typedef BOOL (^NetworkPrecondition)(Network *, GenericCommand *);

@interface GenericCommand : NSObject

+ (instancetype)websocketAlmondNameAndMac;

+ (instancetype)websocketSensorDevice:(SFIDevice *)device name:(NSString *)newName location:(NSString *)newLocation almondMac:(NSString *)almondMac;

+ (instancetype)cloudSensorDevice:(SFIDevice *)device name:(NSString *)newName location:(NSString *)newLocation almondMac:(NSString *)almondMac;

+ (instancetype)cloudUpdateWirelessSettings:(SFIWirelessSetting *)newSettings almondMac:(NSString*)almondMac;

+ (instancetype)websocketChangeAlmondMode:(SFIAlmondMode)newMode userId:(NSString *)userId almondMac:(NSString *)almondMac;

+ (instancetype)cloudChangeAlmondMode:(SFIAlmondMode)newMode userId:(NSString *)userId almondMac:(NSString *)almondMac;

+ (instancetype)websocketRequestAlmondWifiClients;

+ (instancetype)cloudRequestAlmondWifiClients:(NSString *)almondMac;

// constructs a generic command for requesting the sensor list
+ (instancetype)websocketSensorDeviceListCommand;

// constructs a generic command for requesting the sensor values
+ (instancetype)websocketSensorDeviceValueListCommand;

// constructs a generic command for updating a sensor's index value
+ (instancetype)websocketSetSensorDevice:(SFIDevice *)device value:(SFIDeviceKnownValues *)newValue ;

// constructs a generic command for requesting the sensor list for the specified Almond
+ (instancetype)cloudSensorDeviceListCommand:(NSString *)almondMac;

// constructs a generic command for requesting the sensor values for the specified Almond
+ (instancetype)cloudSensorDeviceValueListCommand:(NSString *)almondMac;

// constructs a generic command for updating a sensor's index value
+ (instancetype)cloudSetSensorDevice:(SFIDevice *)device value:(SFIDeviceKnownValues *)newValue almondMac:(NSString *)almondMac;

// convenience method for generating a command structure for sending to a web service that consumes JSON.
// the dictionary will be serialized as JSON (NSData)
+ (instancetype)jsonPayloadCommand:(NSDictionary *)payload commandType:(CommandType)type;

//scene list request
+ (instancetype)websocketRequestAlmondSceneList;
@property(nonatomic) id command;
@property(nonatomic) CommandType commandType;

// optional function that will be called upon submission of the command to a network for processing.
// can be used for storing state and validating that the command should continue processing.
@property(nonatomic, copy) NetworkPrecondition networkPrecondition;

// property for tracking when this request was made; can be used for expiring it
@property(nonatomic, readonly) sfi_id correlationId;
@property(nonatomic, readonly) NSDate *created;

// can be used to determine whether the request should be expired
- (BOOL)shouldExpireAfterSeconds:(NSTimeInterval)timeOutSecsAfterCreation;

// Called to check against standard expiration time, which is 5 seconds.
- (BOOL)isExpired;

- (NSString *)description;

- (NSString *)debugDescription;

@end
