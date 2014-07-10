//
//  GenericCommand.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import "GenericCommand.h"

@implementation GenericCommand

- (NSString *)debugDescription {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.command=%@", self.command];
    [description appendFormat:@", self.commandType=%u", self.commandType];
    [description appendString:@">"];
    return description;
}

@end
