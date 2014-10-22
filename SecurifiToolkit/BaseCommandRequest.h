//
//  BaseCommandRequest.h
//
//  Created by sinclair on 10/22/14.
//
#import <Foundation/Foundation.h>

@class XMLWriter;

@interface BaseCommandRequest : NSObject

@property(readonly) unsigned int correlationId;

- (instancetype)init;

- (void)writeMobileInternalIndexElement:(XMLWriter *)writer;

@end