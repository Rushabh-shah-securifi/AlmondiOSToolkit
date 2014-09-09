//
//  SensorChangeRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/01/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"

@interface SensorChangeRequest : NSObject <SecurifiCommand>
@property NSString *almondMAC;
@property NSString *mobileInternalIndex;
@property NSString *deviceID;
@property NSString *changedName;
@property NSString *changedLocation;

- (NSString*)toXml;

@end
