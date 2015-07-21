//
//  GenericCommand.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandTypes.h"

@interface GenericCommand : NSObject

// convenience method for generating a command structure for sending to a web service that consumes JSON.
// the dictionary will be serialized as JSON (NSData)
+ (instancetype)jsonPayloadCommand:(NSDictionary *)payload commandType:(CommandType)type;

@property(nonatomic) id command;
@property(nonatomic) CommandType commandType;

- (NSString *)description;

- (NSString *)debugDescription;

@end
