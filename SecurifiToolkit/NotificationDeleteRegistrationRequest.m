//
//  NotificationDeleteRegistrationRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 07/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "NotificationDeleteRegistrationRequest.h"
#import "XMLWriter.h"

@implementation NotificationDeleteRegistrationRequest
- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"NotificationDeleteRegistrationRequest"];
    
    [writer writeStartElement:@"RegID"];
    [writer writeCharacters:self.regID];
    [writer writeEndElement];
    
    [writer writeStartElement:@"Platform"];
    [writer writeCharacters:self.platform];
    [writer writeEndElement];
    
    
    [self writeMobileInternalIndexElement:writer];
    
    // close NotificationDeleteRegistrationRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}
@end
