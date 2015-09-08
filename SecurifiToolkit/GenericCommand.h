//
//  GenericCommand.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandTypes.h"

@interface GenericCommand : NSObject

// convenience method for generating a command structure for sending to a web service that consumes JSON.
// the dictionary will be serialized as JSON (NSData)
+ (instancetype)jsonPayloadCommand:(NSDictionary *)payload commandType:(CommandType)type;

// constructs a generic command for requesting the sensor list
+ (instancetype)websocketSensorDeviceListCommand;

// constructs a generic command for requesting the sensor values
+ (instancetype)websocketSensorDeviceValueListCommand;

// constructs a generic command for requesting the sensor list for the specified Almond
+ (instancetype)cloudSensorDeviceListCommand:(NSString *)almondMac;

// constructs a generic command for requesting the sensor values for the specified Almond
+ (instancetype)cloudSensorDeviceValueListCommand:(NSString *)almondMac;

@property(nonatomic) id command;
@property(nonatomic) CommandType commandType;

- (NSString *)description;

- (NSString *)debugDescription;

@end
