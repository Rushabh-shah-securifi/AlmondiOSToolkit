//
//  RouterCommandParser.h
//  TestApp
//
//  Created by Priya Yerunkar on 16/08/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFIGenericRouterCommand;
@class GenericCommandResponse;

// Parses the response for a generic router command
@interface RouterCommandParser : NSObject

// Parses the response payload and returns a router command. If the response is in error,
// a SFIGenericRouterCommand is still returned that indicates the error.
+ (SFIGenericRouterCommand *)parseRouterResponse:(GenericCommandResponse *)response;

@end
