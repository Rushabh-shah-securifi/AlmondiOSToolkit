//
//  MobileCommandRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIDevice.h"
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

//todo encapsulate this (a designated initializer)

@interface MobileCommandRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic) NSString *almondMAC;
@property(nonatomic) NSString *deviceID;
@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic) NSString *indexID;
@property(nonatomic) NSString *changedValue;
@end
