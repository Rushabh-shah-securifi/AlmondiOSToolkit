//
//  SensorChangeResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/01/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SensorChangeResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) unsigned int mobileInternalIndex;
@end
