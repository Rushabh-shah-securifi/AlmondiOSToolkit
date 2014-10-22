//
//  BaseCommandRequest.h
//
//  Created by sinclair on 10/22/14.
//

#import "BaseCommandRequest.h"
#import "XMLWriter.h"

@implementation BaseCommandRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        // correlation id sent to cloud and returned in response
        _correlationId = (arc4random() % 1000) + 1;
    }

    return self;
}

- (void)writeMobileInternalIndexElement:(XMLWriter *)writer {
    NSString *value = [NSString stringWithFormat:@"%d", _correlationId];

    [writer writeStartElement:@"MobileInternalIndex"];
    [writer writeCharacters:value];
    [writer writeEndElement];
}

@end