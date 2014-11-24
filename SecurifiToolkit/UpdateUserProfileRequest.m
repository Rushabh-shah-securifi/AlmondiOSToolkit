//
//  UpdateUserProfileRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 18/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "UpdateUserProfileRequest.h"
#import "SFIXmlWriter.h"

@implementation UpdateUserProfileRequest

-(NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    
    [writer startElement:@"root"];
    [writer startElement:@"UpdateUserProfileRequest"];

    [writer addElement:@"FirstName" text:self.firstName];
    [writer addElement:@"LastName" text:self.lastName];
    [writer addElement:@"AddressLine1" text:self.addressLine1];
    [writer addElement:@"AddressLine2" text:self.addressLine2];
    [writer addElement:@"AddressLine3" text:self.addressLine3];
    [writer addElement:@"Country" text:self.country];
    [writer addElement:@"ZipCode" text:self.zipCode];

    [self addMobileInternalIndexElement:writer];
    
    // close DeleteAccountRequest
    [writer endElement];
    // close root
    [writer endElement];
    
    return writer.toString;
}
@end
