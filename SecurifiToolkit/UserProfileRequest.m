//
//  SFIUserProfileRequest.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 15/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "UserProfileRequest.h"
#import "SFIXmlWriter.h"

@implementation UserProfileRequest

- (NSString *)toXml {
    SFIXmlWriter *writer = [SFIXmlWriter new];
    
    [writer startElement:@"root"];
    [writer endElement];
    
    return writer.toString;
}

@end
