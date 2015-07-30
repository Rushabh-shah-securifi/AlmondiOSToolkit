//
//  ScenesListRequest.,
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 28.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "ScenesListRequest.h"
#import "SFIXmlWriter.h"

@implementation ScenesListRequest

- (NSString *)toXml {
    /*
     "{""MobileCommand"":""LIST_SCENE_REQUEST"",
     ""AlmondplusMAC"":""202010""}"
     */
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"LIST_SCENE_REQUEST"];

    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];


    //
    //

    // close Device
    [writer endElement];

    [self addMobileInternalIndexElement:writer];

    // close SensorChange
    [writer endElement];
    // close root
    [writer endElement];

    return writer.toString;
}
@end