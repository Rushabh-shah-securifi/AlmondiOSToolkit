//
//  BaseCommandRequest.h
//
//  Created by sinclair on 10/22/14.
//
#import <Foundation/Foundation.h>

@class SFIXmlWriter;

//todo where to place this?
// standard type used for ID values
typedef unsigned int sfi_id;

@interface BaseCommandRequest : NSObject

@property(nonatomic, readonly) sfi_id correlationId;

- (instancetype)init;

- (void)addMobileInternalIndexElement:(SFIXmlWriter *)writer;

@end