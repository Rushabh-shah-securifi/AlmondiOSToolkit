//
//  GenericCommandRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "GenericCommandRequest.h"
#import "SFIXmlWriter.h"

@implementation GenericCommandRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        // set non-null defaults; protect against segfaults when generating XML
        _almondMAC = @"";
        _applicationID = @"1001";
    }

    return self;
}


- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];

    [writer startElement:@"root"];
    [writer startElement:@"GenericCommandRequest"];

    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];
    [writer addElement:@"ApplicationID" text:self.applicationID];

    [self addMobileInternalIndexElement:writer];

    NSString *encodedString;
    if (self.data) {
        NSData *dataToEncode = [self.data dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encodedData = [dataToEncode base64EncodedDataWithOptions:0];
        encodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
    }
    else {
        encodedString = @"";
    }
    [writer addElement:@"Data" text:encodedString];

    // close GenericCommandRequest
    [writer endElement];
    // close root element
    [writer endElement];

    return writer.toString;
}

@end
