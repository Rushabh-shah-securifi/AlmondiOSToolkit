//
//  MobileCommandRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileCommandRequest : NSObject
@property NSString *almondMAC;
@property NSString *deviceID;
@property NSString *indexID;
@property NSString *changedValue;
@property NSString *internalIndex;
@end
