//
//  GenericCommandRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "GenericCommandRequest.h"
#import "XMLWriter.h"

@implementation GenericCommandRequest


- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";

    [writer writeStartElement:@"root"];
    [writer writeStartElement:@"GenericCommandRequest"];

    [writer writeStartElement:@"AlmondplusMAC"];
    [writer writeCharacters:self.almondMAC];
    [writer writeEndElement];

    [writer writeStartElement:@"ApplicationID"];
    [writer writeCharacters:self.applicationID];
    [writer writeEndElement];

    [writer writeStartElement:@"MobileInternalIndex"];
    [writer writeCharacters:self.mobileInternalIndex];
    [writer writeEndElement];

    NSData *dataToEncode = [self.data dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encodedData = [dataToEncode base64EncodedDataWithOptions:0];
    NSString *encodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];

    [writer writeStartElement:@"Data"];
    [writer writeCharacters:encodedString];
    [writer writeEndElement];

    // close GenericCommandRequest
    [writer writeEndElement];
    // close root element
    [writer writeEndElement];

    return writer.toString;
}



@end
