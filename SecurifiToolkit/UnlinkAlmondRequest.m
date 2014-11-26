//
//  UnlinkAlmondRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "UnlinkAlmondRequest.h"
#import "SFIXmlWriter.h"

@implementation UnlinkAlmondRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    
    [writer startElement:@"root"];
    [writer startElement:@"UnlinkAlmondRequest"];

    [writer addElement:@"AlmondMAC" text:self.almondMAC];
    [writer addElement:@"EmailID" text:self.emailID];
    [writer addElement:@"Password" text:self.password];

    [self addMobileInternalIndexElement:writer];
    
    // close UnlinkAlmondRequest
    [writer endElement];
    // close root
    [writer endElement];
    
    return writer.toString;
}

@end

