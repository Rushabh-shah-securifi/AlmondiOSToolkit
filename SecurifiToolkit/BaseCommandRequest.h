//
//  BaseCommandRequest.h
//
//  Created by sinclair on 10/22/14.
//
#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

@class SFIXmlWriter;

@interface BaseCommandRequest : NSObject

@property(nonatomic, readonly) sfi_id correlationId;

- (instancetype)init;

- (void)addMobileInternalIndexElement:(SFIXmlWriter *)writer;

@end