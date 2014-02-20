//
//  DeviceValueResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceValueResponse : NSObject
@property BOOL isSuccessful;
@property unsigned int deviceCount;
@property NSString *reason;
@property NSMutableArray *deviceValueList;
@property NSString *almondMAC;
@end
