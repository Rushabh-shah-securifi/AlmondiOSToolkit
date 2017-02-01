//
//  DeviceIndex.m
//  SecurifiToolkit
//
//  Created by Masood on 16/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DeviceIndex.h"

@implementation DeviceIndex
/*
 "row_no": 5,
 "genericIndexID": "99",
 "AppLabel": "buzzer_timer",
 "min": "0",
 "max": "99999",
 "Placement": "Detail"
 */
-(id)initWithIndex:(NSString*)index genericIndex:(NSString*)genericIndex rowID:(NSString*)rowID placement:(NSString *)placement min:(NSString*)min max:(NSString*)max appLabel:(NSString *)appLabel{
    self = [super init];
    if(self){
        self.index = index;
        self.genericIndex = genericIndex;
        self.rowID = rowID;
        self.placement = placement;
        self.min = min;
        self.max = max;
        self.appLabel = appLabel;
    }
    return self;
}
@end
