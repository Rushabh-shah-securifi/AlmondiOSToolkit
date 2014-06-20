//
//  SFIDeviceKnownValues.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIDeviceKnownValues : NSObject <NSCoding>
@property unsigned int      index;
@property NSString          *valueName;
@property NSString          *valueType;
@property NSString          *value;
@property BOOL              isUpdating;

- (BOOL)boolValue;

@end
