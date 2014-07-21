//
//  DeviceListRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "DeviceListRequest.h"

@implementation DeviceListRequest

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.almondMAC=%@", self.almondMAC];
    [description appendString:@">"];
    return description;
}


@end
