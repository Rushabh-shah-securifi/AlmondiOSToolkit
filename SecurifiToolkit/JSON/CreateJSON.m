//
//  CreateJSON.m
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "CreateJSON.h"

@implementation CreateJSON

static NSMutableDictionary* map;

+(NSString*) withCommandString:(NSString*)commandString getJSONStringfromDictionary: (NSMutableDictionary*)dictionary{
    
    [dictionary setObject:commandString forKey:@"CommandType"];
    return [self getJSONStringFromDictionary:dictionary];
}


+(NSString*) getJSONStringFromDictionary: (NSMutableDictionary*) dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:1
                                                         error:&error];
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
