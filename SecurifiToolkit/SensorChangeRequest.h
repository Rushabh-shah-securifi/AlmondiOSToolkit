//
//  SensorChangeRequest.h
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 20/01/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SensorChangeRequest : NSObject
@property NSString *almondMAC;
@property NSString *mobileInternalIndex;
@property NSString *deviceID;
@property NSString *changedName;
@property NSString *changedLocation;
@end
