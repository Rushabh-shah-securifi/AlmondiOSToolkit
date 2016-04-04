//
//  GenericIndexClass.m
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericIndexClass.h"

@implementation GenericIndexClass
-(id)initWithLabel:(NSString*)label icon:(NSString*)icon type:(NSString*)type identifier:(NSString*)ID placement:(NSString*)placement values:(NSDictionary*)values formatter:(Formatter*)formatter layoutType:(NSString*)layoutType commandType:(DeviceCommandType)commandType{
    self = [super init];
    if(self){
        self.groupLabel = label;
        self.icon = icon;
        self.type = type;
        self.ID = ID;
        self.placement = placement;
        self.values = values;
        self.formatter = formatter;
        self.layoutType = layoutType;
        self.commandType = commandType;
    }
    return self;
}

+(DeviceCommandType)getCommandType:(NSString*)command{
    if(command){
        if([command isEqualToString:@"NameChanged"])
            return DeviceCommand_UpdateDeviceName;
        else if([command isEqualToString:@"LocationChanged"])
            return DeviceCommand_UpdateDeviceLocation;
        else if([command isEqualToString:@"NotifyMe"])
            return DeviceCommand_NotifyMe;
    }
    else{
        return DeviceCommand_UpdateDeviceIndex;
    }
}
@end
