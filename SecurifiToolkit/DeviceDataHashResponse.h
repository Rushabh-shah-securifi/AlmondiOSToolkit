//
//  DeviceDataHashResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceDataHashResponse : NSObject
@property BOOL isSuccessful;
@property NSString *almondHash;
@property NSString *reason;
@end
