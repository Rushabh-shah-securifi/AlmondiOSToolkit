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

    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];
    [writer addElement:@"NewName" text:self.changedAlmondName];

    [self addMobileInternalIndexElement:writer];

    // close AlmondNameChange
    [writer endElement];
    // close root
    [writer endElement];
    
    return writer.toString;
}

@end
