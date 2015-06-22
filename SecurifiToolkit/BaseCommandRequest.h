//
//  BaseCommandRequest.h
//
//  Created by sinclair on 10/22/14.
//
#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"

@class SFIXmlWriter;

@interface BaseCommandRequest : NSObject

// property for tracking when this request was made; can be used for expiring it
@property(nonatomic, readonly) NSDate *created;

@property(nonatomic, readonly) sfi_id correlationId;

- (instancetype)init;

- (void)addMobileInternalIndexElement:(SFIXmlWriter *)writer;

// can be used to determine whether the request should be expired
- (BOOL)shouldExpireAfterSeconds:(NSTimeInterval)timeOutSecsAfterCreation;

// Called to check against standard expiration time, which is 5 seconds.
- (BOOL)isExpired;

- (NSData *)serializeJson:(NSDictionary *)payload;

@end