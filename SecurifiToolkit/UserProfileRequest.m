//
//  SFIUserProfileRequest.m
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 15/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "UserProfileRequest.h"
#import "XMLWriter.h"

@implementation UserProfileRequest

- (NSString *)toXml {
    XMLWriter *writer = [XMLWriter new];
    writer.indentation = @"";
    writer.lineBreak = @"";
    
    [writer writeStartElement:@"root"];
    // close root
    [writer writeEndElement];
    
    return writer.toString;
}

@end
