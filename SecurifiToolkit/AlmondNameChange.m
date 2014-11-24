//
//  AlmondNameChange.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "AlmondNameChange.h"
#import "SFIXmlWriter.h"

@implementation AlmondNameChange

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    
    [writer startElement:@"root"];
    [writer startElement:@"AlmondNameChange"];
    
    [writer element:@"AlmondplusMAC" text:self.almondMAC];
    [writer element:@"NewName" text:self.changedAlmondName];

    [self writeMobileInternalIndexElement:writer];

    // close AlmondNameChange
    [writer endElement];
    // close root
    [writer endElement];
    
    return writer.toString;
}

@end
