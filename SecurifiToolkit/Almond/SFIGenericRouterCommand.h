//
//  SFIGenericRouterCommand.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, SFIGenericRouterCommandType) {
    SFIGenericRouterCommandType_REBOOT                  = 1,
    SFIGenericRouterCommandType_CONNECTED_DEVICES       = 2,
    SFIGenericRouterCommandType_BLOCKED_MACS            = 3,
    SFIGenericRouterCommandType_BLOCKED_CONTENT         = 5,
    SFIGenericRouterCommandType_WIRELESS_SETTINGS       = 7,
    SFIGenericRouterCommandType_WIRELESS_SUMMARY        = 9,
    SFIGenericRouterCommandType_SEND_LOGS_RESPONSE      = 10,
    SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE = 11,
    
    SFIGenericRouterCommandType_ALMOND_PROPERTY = 20,
};

@interface SFIGenericRouterCommand : NSObject

@property(nonatomic, copy) NSString *almondMAC;

@property(nonatomic) id command;
@property(nonatomic) SFIGenericRouterCommandType commandType;

@property(nonatomic) BOOL commandSuccess;
@property(nonatomic) NSString *responseMessage;
@property(nonatomic) unsigned int completionPercentage;
@property(nonatomic) int mii;
@property(nonatomic) NSString *uptime;
@property(nonatomic) NSString *offlineSlaves;

@end
