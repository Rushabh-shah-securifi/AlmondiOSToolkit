//
//  GenericIndexClass.h
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Formatter.h"

typedef NS_ENUM(int, DeviceCommandType){
    DeviceCommand_UpdateDeviceIndex,
    DeviceCommand_UpdateDeviceName,
    DeviceCommand_UpdateDeviceLocation,
    DeviceCommand_NotifyMe
};

@interface GenericIndexClass : NSObject
@property(nonatomic) NSString *groupLabel;
@property(nonatomic) NSString *icon;
@property(nonatomic) NSString* type;
@property(nonatomic) NSString *ID;
@property(nonatomic) NSString *placement;
@property(nonatomic) NSDictionary *values;
@property(nonatomic) Formatter *formatter;
@property(nonatomic) NSString* layoutType;
@property(nonatomic) DeviceCommandType commandType;
@property(nonatomic) BOOL readOnly;
@property(nonatomic) NSString *excludeFrom;
@property(nonatomic) NSString *rowID;
@property(nonatomic) BOOL showToggleInRules;
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *categoryLabel;

-(id)initWithLabel:(NSString*)label icon:(NSString*)icon type:(NSString*)type identifier:(NSString*)ID placement:(NSString*)placement values:(NSDictionary*)values formatter:(Formatter*)formatter layoutType:(NSString*)layoutType commandType:(DeviceCommandType)commandType readOnly:(BOOL)readOnly excludeFrom:(NSString *)excludeFrom showToggleInRules:(BOOL)showToggleInRules indexName:(NSString *)name categoryLabel:(NSString *)categoryLabel;

-(id)initWithGenericIndex:(GenericIndexClass*)genericIndex;

+(DeviceCommandType)getCommandType:(NSString*)command;
@end
