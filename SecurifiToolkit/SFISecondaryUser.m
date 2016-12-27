//
//  SFISecondaryUser.m
//  SecurifiToolkit
//
//  Created by K Murali Krishna on 27/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFISecondaryUser.h"

@implementation SFISecondaryUser


- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        self.emailId = [coder decodeObjectForKey:@"self.emailId"];
        self.userId = [coder decodeObjectForKey:@"self.userId"];
    }
    return self;
} 

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.emailId forKey:@"self.emailId"];
    [coder encodeObject:self.userId forKey:@"self.userId"];
}


- (id)copyWithZone:(NSZone *)zone {
    SFISecondaryUser *copy = (SFISecondaryUser *) [[[self class] allocWithZone:zone] init];
    
    if (copy != nil) {
        copy.emailId = self.emailId;
        copy.userId = self.userId;
    }
    
    return copy;
}

@end
