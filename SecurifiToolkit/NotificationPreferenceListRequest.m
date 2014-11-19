//
//  NotificationPreferenceListRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 14/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "NotificationPreferenceListRequest.h"
#import "XMLWriter.h"

@implementation NotificationPreferenceListRequest
- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"NotificationPreferenceListRequest"];
    
    [writer writeStartElement:@"AlmondplusMAC"];
    [writer writeCharacters:self.almondplusMAC];
    [writer writeEndElement];
       
    
    [self writeMobileInternalIndexElement:writer];
    
    // close NotificationPreferenceListRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}

@end
