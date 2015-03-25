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

- (BOOL)isPageStateDefined;

+ (instancetype)parseJson:(NSData *)data;

@end