//
//  MobileCommandRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "MobileCommandRequest.h"
#import "SFIXmlWriter.h"

@implementation MobileCommandRequest


- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"MobileCommand"];

    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];

    [writer startElement:@"Device"];
    [writer addAttribute:@"ID" value:self.deviceID];
    //
    [writer startElement:@"NewValue"];
    [writer addAttribute:@"Index" value:self.indexID];
    [writer addText:self.changedValue];
    [writer endElement];
    //
    // close Device
    [writer endElement];

    [self addMobileInternalIndexElement:writer];

    // close MobileCommand
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}


@end
