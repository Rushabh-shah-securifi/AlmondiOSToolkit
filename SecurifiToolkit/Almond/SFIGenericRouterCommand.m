//
//  SFIGenericRouterCommand.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIGenericRouterCommand.h"

@implementation SFIGenericRouterCommand

- (instancetype)init {
    self = [super init];
    if (self) {
        self.commandSuccess = YES; // default unless set to NO by parser or in error condition
    }

    return self;
}

@end
