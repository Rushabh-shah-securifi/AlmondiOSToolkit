//
//  DeleteMeAsSecondaryUserRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 24/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "DeleteMeAsSecondaryUserRequest.h"
#import "SFIXmlWriter.h"

@implementation DeleteMeAsSecondaryUserRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    
    [writer startElement:@"root"];
    [writer startElement:@"DeleteMeAsSecondaryUserRequest"];
    
    [writer element:@"AlmondMAC" text:self.almondMAC];

    [self writeMobileInternalIndexElement:writer];
    
    // close DeleteMeAsSecondaryUserRequest
    [writer endElement];
    // close root
    [writer endElement];
    
    return writer.toString;
}
@end
