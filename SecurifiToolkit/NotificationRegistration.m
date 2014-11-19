//
//  NotificationRegistration.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 06/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "NotificationRegistration.h"
#import "XMLWriter.h"

@implementation NotificationRegistration
- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"NotificationAddRegistration"];
    
    [writer writeStartElement:@"RegID"];
    [writer writeCharacters:self.regID];
    [writer writeEndElement];
    
    [writer writeStartElement:@"Platform"];
    [writer writeCharacters:self.platform];
    [writer writeEndElement];
    
    
    [self writeMobileInternalIndexElement:writer];
    
    // close NotificationAddRegistration
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}
@end
