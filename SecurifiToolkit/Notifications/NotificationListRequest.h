//
// Created by Matthew Sinclair-Day on 3/23/15.
// Copyright (c) 2015 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

/*
command 800
<root>
    <PageState></PageState>
<root>
 */
@interface NotificationListRequest : BaseCommandRequest <SecurifiCommand>

// the page state to request or nil
@property(nonatomic, copy) NSString *pageState;

// an opaque token attached to the request and parroted back in the response
@property(nonatomic, copy) NSString *requestId;

@end