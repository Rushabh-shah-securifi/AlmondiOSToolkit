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
    
    [writer element:@"FirstName" text:self.firstName];
    [writer element:@"LastName" text:self.lastName];
    [writer element:@"AddressLine1" text:self.addressLine1];
    [writer element:@"AddressLine2" text:self.addressLine2];
    [writer element:@"AddressLine3" text:self.addressLine3];
    [writer element:@"Country" text:self.country];
    [writer element:@"ZipCode" text:self.zipCode];

    [self writeMobileInternalIndexElement:writer];
    
    // close DeleteAccountRequest
    [writer endElement];
    // close root
    [writer endElement];
    
    return writer.toString;
}
@end
