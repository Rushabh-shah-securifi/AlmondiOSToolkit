//
//  SFIButtonSubProperties.h
//  SecurifiApp
//
//  Created by Masood on 15/10/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SecurifiToolkit/SecurifiTypes.h"
#import "RulesTimeElement.h"
typedef NS_ENUM(int , Type) {
    Mode,
    Wifi,
    Device
};
@interface SFIButtonSubProperties : NSObject



@property(nonatomic) sfi_id deviceId;
@property(nonatomic) int index;
@property(nonatomic) NSString* matchData;
@property(nonatomic) NSString *delay; //to be used for actions
@property(nonatomic) NSString *eventType;
@property(nonatomic) int positionId; //for actioins
@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic) NSString *deviceName;
@property(nonatomic) NSString *iconName;
@property(nonatomic) NSString *displayText;
@property(nonatomic) enum Type type;
@property(nonatomic) RulesTimeElement *time;

@property bool isMode;
@property bool isWiFi;


- (SFIButtonSubProperties *)createNew;
@end
