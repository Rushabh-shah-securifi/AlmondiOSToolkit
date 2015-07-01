//
//  DeviceValueRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "DeviceValueRequest.h"
#import "SFIXmlWriter.h"

@implementation DeviceValueRequest

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.almondMAC=%@", self.almondMAC];
    [description appendString:@">"];
    return description;
}

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"DeviceValue"];

    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];

    // close DeviceValue
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}


@end
