//
//  SFIDeviceValue.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIDeviceValue : NSObject <NSCoding>
@property unsigned int      deviceID;
@property unsigned int      valueCount;
@property NSMutableArray   *knownValues;

//For Deletion Handling
@property BOOL isPresent;

@end
