//
// Created by Matthew Sinclair-Day on 3/23/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

// command code: 801
// a response payload to command 800
@interface NotificationListResponse : NSObject

@property(nonatomic, readonly) NSString *pageState;

// an opaque token attached to the request and parroted back in the response
@property(nonatomic, readonly) NSString *requestId;

@property(nonatomic, readonly) NSArray *notifications; // a list of SFINotification

// value indicating how many "new" notifications there are.
// Though new records are delivered first, those records may not fill entire page, or fit entirely in the page.
@property(nonatomic, readonly) NSUInteger newCount;

- (BOOL)isPageStateDefined;

+ (instancetype)parseJson:(NSData *)data;

@end