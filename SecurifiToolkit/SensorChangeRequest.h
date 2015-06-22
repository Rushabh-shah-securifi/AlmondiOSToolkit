//
//  SensorChangeRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/01/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCommandRequest.h"
#import "SecurifiCommand.h"

@interface SensorChangeRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic) sfi_id deviceId;
@property(nonatomic, copy) NSString *changedName;
@property(nonatomic, copy) NSString *changedLocation;

- (NSString *)toXml;
- (NSData *)toJson;

@end
