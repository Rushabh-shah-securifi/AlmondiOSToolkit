//
//  CreateJSON.h
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericCommand.h"
#import "CommandTypes.h"
#import "AlmondPlusSDKConstants.h"

@interface CreateJSON : NSObject
+(NSMutableDictionary*) map;
+(BOOL) isDictionaryInitialized;
+(void) initializeDictionary;
+(NSString *)JSONString;
+(NSString*) withCommandString:(NSString*)commandString getJSONStringfromDictionary: (NSDictionary*)dictionary;
+(NSString*) getJSONStringfromDictionary: (NSMutableDictionary*)dictionary;
@end
