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
#import "SFIDeviceKnownValues.h"
#import "SFIDevice.h"
#import "MobileCommandRequest.h"

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

+ (instancetype)websocketSetSensorDevice:(SFIDevice *)device value:(SFIDeviceKnownValues *)newValue {
    BaseCommandRequest *bcmd = [BaseCommandRequest new];

    NSDictionary *payload = @{
            @"mii" : @(bcmd.correlationId).stringValue,
            @"cmd" : @"setdeviceindex",
            @"devid" : @(device.deviceID).stringValue,
            @"index" : @(newValue.index).stringValue,
            @"value" : newValue.value,
    };

    return [GenericCommand jsonPayloadCommand:payload commandType:CommandType_MOBILE_COMMAND];
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

    return cmd;
}

+ (instancetype)cloudSensorDeviceValueListCommand:(NSString *)almondMac {
    DeviceValueRequest *command = [DeviceValueRequest new];
    command.almondMAC = almondMac;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_DEVICE_VALUE;
    cmd.command = command;

    return cmd;
}

+ (instancetype)cloudSetSensorDevice:(SFIDevice *)device value:(SFIDeviceKnownValues *)newValue almondMac:(NSString *)almondMac {
    MobileCommandRequest *request = [MobileCommandRequest new];
    request.almondMAC = almondMac;
    request.deviceID = [NSString stringWithFormat:@"%d", device.deviceID];
    request.deviceType = device.deviceType;
    request.indexID = [NSString stringWithFormat:@"%d", newValue.index];
    request.changedValue = newValue.value;

    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_MOBILE_COMMAND;
    cmd.command = request;
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
