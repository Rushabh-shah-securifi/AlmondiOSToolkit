//
// Created by Matthew Sinclair-Day on 2/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "AlmondModeRequest.h"
#import "SFIXmlWriter.h"


@implementation AlmondModeRequest

- (NSString *)toXml {
    /*
    <root>
    <AlmondModeRequest>
    <AlmondplusMAC>2511135876889</AlmondplusMAC>
    </AlmondModeRequest>
    </root>
     */

    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"AlmondModeRequest"];

    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];

    [writer endElement];
    [writer endElement];

    return writer.toString;
}

@end