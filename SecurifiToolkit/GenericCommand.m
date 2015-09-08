//
//  GenericCommand.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "GenericCommand.h"
#import "BaseCommandRequest.h"
#import "DeviceValueRequest.h"
#import "DeviceListRequest.h"

@implementation GenericCommand

+ (instancetype)jsonPayloadCommand:(NSDictionary *)payload commandType:(CommandType)commandType {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:&error];

    if (error) {
        NSLog(@"jsonPayloadCommand: Error serializing JSON, command:%i, payload:%@, error:%@", commandType, payload, error.description);
        return nil;
    }

    GenericCommand *cmd = [GenericCommand new];
    cmd.command = data;
    cmd.commandType = commandType;

    return cmd;
}

+ (instancetype)websocketSensorDeviceListCommand {
    return [self internalWebsocketSensorDeviceListCommand:CommandType_DEVICE_DATA];
}

+ (instancetype)websocketSensorDeviceValueListCommand {
    return [self internalWebsocketSensorDeviceListCommand:CommandType_DEVICE_VALUE];
}

+ (GenericCommand *)internalWebsocketSensorDeviceListCommand:(enum CommandType)commandType {
    BaseCommandRequest *bcmd = [BaseCommandRequest new];

    NSDictionary *payload = @{
            @"mii" : @(bcmd.correlationId).stringValue,
            @"cmd" : @"devicelist"
    };

    return [GenericCommand jsonPayloadCommand:payload commandType:commandType];
}

+ (instancetype)cloudSensorDeviceListCommand:(NSString *)almondMac {
    DeviceListRequest *deviceListCommand = [DeviceListRequest new];
    deviceListCommand.almondMAC = almondMac;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DEVICE_DATA;
    cmd.command = deviceListCommand;
}

+ (instancetype)cloudSensorDeviceValueListCommand:(NSString *)almondMac {
    DeviceValueRequest *command = [DeviceValueRequest new];
    command.almondMAC = almondMac;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DEVICE_VALUE;
    cmd.command = command;

    return cmd;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.command=%@", self.command];
    [description appendFormat:@", self.commandType=%u", self.commandType];
    [description appendString:@">"];
    return description;
}

- (NSString *)debugDescription {
    return [self description];
}

@end
