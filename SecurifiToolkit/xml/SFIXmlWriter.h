//
//  SFIXmlWriter.h
//
//  Created by sinclair on 11/24/14.
//
#import <Foundation/Foundation.h>

@interface SFIXmlWriter : NSObject

// <elementName>text</elementName>
- (void)element:(NSString *)elementName text:(NSString*)text;

// <elementName....
- (void)startElement:(NSString *)elementName;

// </elementName>
- (void)endElement; // automatic end element (mirrors previous start element at the same level)

// <elementName name=value>
- (void)addAttribute:(NSString *)name value:(NSString *)value;

// <elementName>text</elementName>
- (void)addText:(NSString *)text;

// return the written xml string buffer
- (NSString *)toString;

// return the written xml as data, set to the encoding used in the writeStartDocumentWithEncodingAndVersion method (UTF-8 per default)
- (NSData *)toData;

@end