//
//  GenericCommand.m
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "GenericCommand.h"

@implementation GenericCommand

+ (instancetype)jsonPayloadCommand:(NSDictionary *)payload commandType:(CommandType)commandType {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:&error];

    if (error) {
        NSLog(@"jsonPayloadCommand: Error serializing JSON, command:%i, payload:%@, error:%@", commandType, payload, error.description);
        return nil;
    }

    GenericCommand *cmd = [GenericCommand new];
    cmd.command = data;
    cmd.commandType = commandType;

    return cmd;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.command=%@", self.command];
    [description appendFormat:@", self.commandType=%u", self.commandType];
    [description appendString:@">"];
    return description;
}

- (NSString *)debugDescription {
    return [self description];
}

@end
