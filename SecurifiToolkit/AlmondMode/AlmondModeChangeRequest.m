//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import "AlmondModeChangeRequest.h"
#import "SFIXmlWriter.h"

@implementation AlmondModeChangeRequest

- (NSString *)toXml {
    /*
    command type : 61(635)

    "<root>
    <AlmondModeChange>
    <AlmondplusMAC>2335432485431</AlmondplusMAC>
    <AlmondMode>2</AlmondMode> // (2 = Home, 3 = Away)
    <ModeSetBy>emailid@example.com</ModeSetBy>
    <MobileInternalIndex>324</MobileInternalIndex>
    </AlmondModeChange>
    </root>"
     */

    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"AlmondModeChange"];

    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];
    [writer addElement:@"AlmondMode" intValue:self.mode];
    [writer addElement:@"ModeSetBy" text:self.userId];
    [self addMobileInternalIndexElement:writer];

    [writer endElement];
    [writer endElement];

    return writer.toString;
}

@end