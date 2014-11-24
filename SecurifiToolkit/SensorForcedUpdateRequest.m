//
//  DeviceDataForcedUpdateRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 15/01/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "SensorForcedUpdateRequest.h"
#import "SFIXmlWriter.h"

@implementation SensorForcedUpdateRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"DeviceDataForcedUpdate"];

    [writer element:@"AlmondplusMAC" text:self.almondMAC];

    [self writeMobileInternalIndexElement:writer];

    // close DeviceDataForcedUpdate
    [writer endElement];
    // close root element
    [writer endElement];

    return writer.toString;
}


@end
