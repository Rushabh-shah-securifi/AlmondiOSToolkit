//
//  DeviceIndex.m
//  SecurifiToolkit
//
//  Created by Masood on 16/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DeviceIndex.h"

@implementation DeviceIndex
-(id)initWithIndex:(NSString*)index genericIndex:(NSString*)genericIndex rowID:(NSString*)rowID{
    self = [super init];
    if(self){
        self.index = index;
        self.genericIndex = genericIndex;
        self.rowID = rowID;
    }
    return self;
}
@end
