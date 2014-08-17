//
//  SFIDeviceValue.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIDeviceValue : NSObject <NSCoding>
@property unsigned int deviceID;
@property unsigned int valueCount;
@property NSMutableArray *knownValues;

// Ephemeral value holder useful for managing deleted or missing devices.
// Value is not persistent. Defaults to NO.
@property(nonatomic) BOOL isPresent;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

@end
