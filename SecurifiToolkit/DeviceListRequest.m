//
//  DeviceListRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "DeviceListRequest.h"
#import "SFIXmlWriter.h"

@implementation DeviceListRequest

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.almondMAC=%@", self.almondMAC];
    [description appendString:@">"];
    return description;
}

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"DeviceData"];

    [writer element:@"AlmondplusMAC" text:self.almondMAC];

    // close DeviceData
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}


@end
