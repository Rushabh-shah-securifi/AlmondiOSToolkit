//
//  GenericCommand.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <libkern/OSAtomic.h>
#import "GenericCommand.h"
#import "DeviceValueRequest.h"
#import "DeviceListRequest.h"
#import "SFIDeviceKnownValues.h"
#import "SFIDevice.h"
#import "MobileCommandRequest.h"
#import "SensorChangeRequest.h"
#import "SFIWirelessSetting.h"
#import "GenericCommandRequest.h"
#import "AlmondModeChangeRequest.h"
#import "MDJSON.h"

@implementation GenericCommand

+ (instancetype)websocketAlmondNameAndMac {
    sfi_id cid = [GenericCommand nextCorrelationId];
    
    NSDictionary *payload = @{
                              @"MobileInternalIndex" : @(cid),
                              @"CommandType" : @"GetAlmondNameAndMAC",
                              };
    
    return [GenericCommand jsonPayloadCommand:payload commandType:CommandType_ALMOND_NAME_AND_MAC_REQUEST];
}

+ (instancetype)websocketSensorDevice:(SFIDevice *)device name:(NSString *)newName location:(NSString *)newLocation almondMac:(NSString *)almondMac {
    SensorChangeRequest *request = [SensorChangeRequest new];
    request.almondMAC = almondMac;
    request.deviceId = device.deviceID;
    request.changedName = newName;
    request.changedLocation = newLocation;
    
    GenericCommand *cmd = [GenericCommand commandWithCorrelationId:request.correlationId];
    cmd.commandType = CommandType_MOBILE_COMMAND;
    cmd.command = [request toJson];
    
    return cmd;
}

+ (instancetype)cloudSensorDevice:(SFIDevice *)device name:(NSString *)newName location:(NSString *)newLocation almondMac:(NSString *)almondMac {
    SensorChangeRequest *request = [SensorChangeRequest new];
    request.almondMAC = almondMac;
    request.deviceId = device.deviceID;
    request.changedName = newName;
    request.changedLocation = newLocation;
    
    GenericCommand *cmd = [GenericCommand commandWithCorrelationId:request.correlationId];
    cmd.commandType = CommandType_MOBILE_COMMAND;
    cmd.command = request;
    
    return cmd;
}

+ (instancetype)cloudUpdateWirelessSettings:(SFIWirelessSetting *)newSettings almondMac:(NSString *)almondMac {
    GenericCommandRequest *req = [[GenericCommandRequest alloc] init];
    req.almondMAC = almondMac;
    req.data = [newSettings toXml];
    
    GenericCommand *cmd = [GenericCommand commandWithCorrelationId:req.correlationId];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = req;
    
    return cmd;
}

+ (instancetype)websocketChangeAlmondMode:(SFIAlmondMode)newMode userId:(NSString *)userId almondMac:(NSString *)almondMac {
    AlmondModeChangeRequest *request = [AlmondModeChangeRequest new];
    request.almondMAC = almondMac;
    request.mode = newMode;
    request.userId = userId;
    
    GenericCommand *cmd = [GenericCommand commandWithCorrelationId:request.correlationId];
    cmd.commandType = CommandType_ALMOND_MODE_CHANGE_REQUEST;
    cmd.command = request.toJson;
    
    return cmd;
}

+ (instancetype)cloudChangeAlmondMode:(SFIAlmondMode)newMode userId:(NSString*)userId almondMac:(NSString *)almondMac {
    AlmondModeChangeRequest *request = [AlmondModeChangeRequest new];
    request.almondMAC = almondMac;
    request.mode = newMode;
    request.userId = userId;
    
    GenericCommand *cmd = [GenericCommand commandWithCorrelationId:request.correlationId];
    cmd.commandType = CommandType_ALMOND_MODE_CHANGE_REQUEST;
    cmd.command = request;
    
    return cmd;
}



+ (instancetype)websocketSetSensorDevice:(SFIDevice *)device value:(SFIDeviceKnownValues *)newValue {
    sfi_id correlationId = [GenericCommand nextCorrelationId];
    
    NSDictionary *payload = @{
                              @"mii" : @(correlationId).stringValue,
                              @"cmd" : @"setdeviceindex",
                              @"devid" : @(device.deviceID).stringValue,
                              @"index" : @(newValue.index).stringValue,
                              @"value" : newValue.value,
                              };
    
    return [GenericCommand jsonPayloadCommand:payload commandType:CommandType_MOBILE_COMMAND];
}




+ (instancetype)cloudSetSensorDevice:(SFIDevice *)device value:(SFIDeviceKnownValues *)newValue almondMac:(NSString *)almondMac {
    MobileCommandRequest *request = [MobileCommandRequest new];
    request.almondMAC = almondMac;
    request.deviceID = [NSString stringWithFormat:@"%d", device.deviceID];
    request.deviceType = device.deviceType;
    request.indexID = [NSString stringWithFormat:@"%d", newValue.index];
    request.changedValue = newValue.value;
    
    GenericCommand *cmd = [GenericCommand commandWithCorrelationId:request.correlationId];
    cmd.commandType = CommandType_MOBILE_COMMAND;
    cmd.command = request;
    
    return cmd;
}

+ (instancetype)requestSensorDeviceList:(NSString*)mac {
    sfi_id correlationId = [GenericCommand nextCorrelationId];
    
    NSDictionary *payload = @{
                              @"MobileInternalIndex" : @(correlationId).stringValue,
                              @"CommandType" : @"DeviceList",
                              @"AlmondMAC":mac? mac: @"",
                              @"Action" : @"get"
                              };
    
    return [self jsonPayloadCommand:payload commandType:CommandType_DEVICE_LIST_AND_DYNAMIC_RESPONSES];
}

+ (instancetype)requestRouterSummary:(NSString *)almondMac {
    
    sfi_id correlationId = [GenericCommand nextCorrelationId];
    NSDictionary *payload = @{
                              @"MobileInternalIndex" : @(correlationId).stringValue,
                              @"CommandType" : @"RouterSummary",
                              @"AppID" : @"1001",
                              @"AlmondMAC" : almondMac? almondMac: @""
                              };
    
    return [self jsonPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
}

+ (instancetype)requestAlmondClients:(NSString *)almondMac {
    
    sfi_id correlationId = [GenericCommand nextCorrelationId];
    NSDictionary *payload = @{
                              @"MobileInternalIndex" : @(correlationId).stringValue,
                              @"CommandType" : @"ClientList",
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"Action" : @"get"
                              };
    
    return [self jsonPayloadCommand:payload commandType:CommandType_CLIENT_LIST_AND_DYNAMIC_RESPONSES];
}

+ (instancetype)requestSceneList:(NSString *)almondMac{

    sfi_id correlationId = [GenericCommand nextCorrelationId];
    NSDictionary * payload =@{
                               @"MobileInternalIndex" : @(correlationId).stringValue,
                               @"CommandType" : @"DynamicSceneList",
                               @"AlmondMAC":almondMac? almondMac: @"",
                               @"Action" : @"get"
                               };
    return [self jsonPayloadCommand:payload commandType:CommandType_SCENE_LIST_AND_DYNAMIC_RESPONSES];
}

//Rules
+ (instancetype)requestAlmondRules:(NSString *)almondMac {
    sfi_id correlationId = [GenericCommand nextCorrelationId];
    almondMac=(almondMac==nil)?@"":almondMac;
    NSDictionary *payload = @{
                              @"CommandType" : @"RuleList",
                              @"MobileInternalIndex" : @(correlationId).stringValue,
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"Action" : @"get"
                              };
    return [self jsonPayloadCommand:payload commandType:CommandType_RULE_LIST_AND_DYNAMIC_RESPONSES];
}

+ (instancetype)requestRai2UpMobile{
    sfi_id correlationId = [GenericCommand nextCorrelationId];
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"Rai2UpMobile",
                              @"MobileInternalIndex":@(correlationId).stringValue
                              };
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_REQUEST];
    genericCmd.isMeshCmd = YES;
    return genericCmd;
}

+ (instancetype)requestRai2DownMobile{
    sfi_id correlationId = [GenericCommand nextCorrelationId];
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"Rai2DownMobile",
                              @"MobileInternalIndex":@(correlationId).stringValue
                              };
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_REQUEST];
    genericCmd.isMeshCmd = YES;
    return genericCmd;
}

+ (instancetype)jsonPayloadCommand:(NSDictionary *)payload commandType:(enum CommandType)commandType {
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

+ (instancetype)jsonStringPayloadCommand:(NSDictionary *)payload commandType:(enum CommandType)commandType {
    GenericCommand *cmd = [GenericCommand new];
    cmd.command = [payload JSONString];
    cmd.commandType = commandType;
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

- (instancetype)init {
    self = [super init];
    if (self) {
        _correlationId = [GenericCommand nextCorrelationId];
        _created = [NSDate date];
    }
    
    return self;
}

- (instancetype)initWithCorrelationId:(sfi_id)correlationId {
    self = [super init];
    if (self) {
        _correlationId = correlationId;
        _created = [NSDate date];
    }
    
    return self;
}

- (BOOL)shouldExpireAfterSeconds:(NSTimeInterval)timeOutSecsAfterCreation {
    NSTimeInterval elapsed = [self.created timeIntervalSinceNow];
    elapsed = fabs(elapsed);
    return elapsed >= timeOutSecsAfterCreation;
}

- (BOOL)isExpired {
    return [self shouldExpireAfterSeconds:5];
}

+ (instancetype)commandWithCorrelationId:(sfi_id)correlationId {
    return [[self alloc] initWithCorrelationId:correlationId];
}


+ (sfi_id)nextCorrelationId {
    static int32_t counter = 0;
    
    int32_t localCounter;
    int32_t newCounter;
    
    do {
        localCounter = counter;
        newCounter = localCounter + 1;
        newCounter = newCounter <= 0 ? 0 : newCounter;
    } while (!OSAtomicCompareAndSwap32(localCounter, newCounter, &counter));
    
    return (sfi_id) counter;
}

@end
