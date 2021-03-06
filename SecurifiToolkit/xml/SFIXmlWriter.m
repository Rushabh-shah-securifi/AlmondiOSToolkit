//
//  SFIXmlWriter.h
//
//  Created by sinclair on 11/24/14.
//
#import "SFIXmlWriter.h"
#import "XMLWriter.h"

@interface SFIXmlWriter ()
@property (nonatomic, readonly) XMLWriter *writer;
@end

@implementation SFIXmlWriter

- (instancetype)init {
    self = [super init];
    if (self) {
        _writer = [XMLWriter new];
        _writer.indentation = @"";
        _writer.lineBreak = @"";
    }

    return self;
}


- (void)addElement:(NSString *)elementName text:(NSString *)text {
    elementName = [self stringOrEmpty:elementName];
    text = [self stringOrEmpty:text];

    [self.writer writeStartElement:elementName];
    [self.writer writeCharacters:text];
    [self.writer writeEndElement];
}

- (void)addElement:(NSString *)elementName intValue:(NSInteger)value {
    NSString *str = [NSString stringWithFormat:@"%li", (long) value];
    [self addElement:elementName text:str];
}

- (void)startElement:(NSString *)elementName {
    elementName = [self stringOrEmpty:elementName];
    [self.writer writeStartElement:elementName];
}

- (void)endElement {
    [self.writer writeEndElement];
}

- (void)addAttribute:(NSString *)name value:(NSString *)value {
    name = [self stringOrEmpty:name];
    value = [self stringOrEmpty:value];
    [self.writer writeAttribute:name value:value];
}

- (void)addAttribute:(NSString *)name intValue:(int)value {
    NSString *string = [NSString stringWithFormat:@"%d", value];
    [self addAttribute:name value:string];
}

- (void)addAttribute:(NSString *)name integerValue:(NSInteger)value {
    NSString *string = [NSString stringWithFormat:@"%ld", (long) value];
    [self addAttribute:name value:string];
}

- (void)addText:(NSString *)text {
    text = [self stringOrEmpty:text];
    [self.writer writeCharacters:text];
}

- (NSString *)toString {
    return [self.writer toString];
}

- (NSData *)toData {
    return [self.writer toData];
}

- (NSString *)stringOrEmpty:(NSString*)str {
    if (str == nil) {
        NSString *xml = [self toString];
        NSLog(@"Unexpected nil value sent to XML writer; converting nil to empty string; the xml so far: '%@'", xml);
        return @"";
    }
    return str;
}

@end