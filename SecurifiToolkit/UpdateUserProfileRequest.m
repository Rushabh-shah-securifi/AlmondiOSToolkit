//
//  UpdateUserProfileRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 18/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "UpdateUserProfileRequest.h"
#import "XMLWriter.h"

@implementation UpdateUserProfileRequest

-(NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"UpdateUserProfileRequest"];
    
    [writer writeStartElement:@"FirstName"];
    [writer writeCharacters:self.firstName];
    [writer writeEndElement];
    
    [writer writeStartElement:@"LastName"];
    [writer writeCharacters:self.lastName];
    [writer writeEndElement];
    
    [writer writeStartElement:@"AddressLine1"];
    [writer writeCharacters:self.addressLine1];
    [writer writeEndElement];
    
    [writer writeStartElement:@"AddressLine2"];
    [writer writeCharacters:self.addressLine2];
    [writer writeEndElement];
    
    [writer writeStartElement:@"AddressLine3"];
    [writer writeCharacters:self.addressLine3];
    [writer writeEndElement];
    
    [writer writeStartElement:@"Country"];
    [writer writeCharacters:self.country];
    [writer writeEndElement];
    
    [writer writeStartElement:@"ZipCode"];
    [writer writeCharacters:self.zipCode];
    [writer writeEndElement];

    [self writeMobileInternalIndexElement:writer];
    
    // close DeleteAccountRequest
    [writer writeEndElement];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}
@end
