//
//  LoginResponse.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "LoginResponse.h"

@implementation LoginResponse

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isAccountActivated = YES;
        self.minsRemainingForUnactivatedAccount = 0;
    }

    return self;
}

@end
