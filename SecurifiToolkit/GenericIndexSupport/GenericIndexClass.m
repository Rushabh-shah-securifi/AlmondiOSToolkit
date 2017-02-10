//
//  GenericIndexClass.m
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericIndexClass.h"
#import "AlmondJsonCommandKeyConstants.h"

@implementation GenericIndexClass
-(id)initWithLabel:(NSString*)label icon:(NSString*)icon type:(NSString*)type identifier:(NSString*)ID placement:(NSString*)placement values:(NSDictionary*)values formatter:(Formatter*)formatter layoutType:(NSString*)layoutType commandType:(DeviceCommandType)commandType readOnly:(BOOL)readOnly excludeFrom:(NSString *)excludeFrom showToggleInRules:(BOOL)showToggleInRules indexName:(NSString *)name categoryLabel:(NSString *)categoryLabel property:(NSString *)property header:(NSString *)header footer:(NSString *)footer elements:(NSString *)elements{
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
        self.readOnly = readOnly;
        self.excludeFrom = excludeFrom;
        self.showToggleInRules = showToggleInRules;
        self.name = name;
        
        self.categoryLabel = categoryLabel;
        self.property = property;
        self.header = header;
        self.footer = footer;
        self.elements = elements;
    }
    return self;
}

-(id)initWithGenericIndex:(GenericIndexClass*)genericIndex{
    self = [super init];
    if(self){
        self.groupLabel = genericIndex.groupLabel;
        self.icon = genericIndex.icon;
        self.type = genericIndex.type;
        self.ID = genericIndex.ID;
        self.placement = genericIndex.placement;
        self.values = genericIndex.values;
        self.formatter = [Formatter getFormatterCopy:genericIndex.formatter];
        self.layoutType = genericIndex.layoutType;
        self.commandType = genericIndex.commandType;
        self.readOnly = genericIndex.readOnly;
        self.excludeFrom = genericIndex.excludeFrom;
        self.showToggleInRules = genericIndex.showToggleInRules;
        self.rowID = genericIndex.rowID;
        
        self.categoryLabel = genericIndex.categoryLabel;
        self.property = genericIndex.property;
        self.header = genericIndex.header;
        self.footer = genericIndex.footer;
        self.elements = genericIndex.elements;
    }
    return self;
}


+(DeviceCommandType)getCommandType:(NSString*)command{
    if(command){
        if([command isEqualToString:NAME_CHANGED])
            return DeviceCommand_UpdateDeviceName;
        else if([command isEqualToString:LOCATION_CHANGED])
            return DeviceCommand_UpdateDeviceLocation;
        else if([command isEqualToString:NOTIFYME])
            return DeviceCommand_NotifyMe;
    }
    else{
        return DeviceCommand_UpdateDeviceIndex;
    }
}
@end
