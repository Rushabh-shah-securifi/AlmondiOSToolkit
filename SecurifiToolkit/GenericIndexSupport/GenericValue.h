//
//  GenericValue.h
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericValue : NSObject
@property NSString *displayText;
@property NSString *icon;
@property NSString *iconText;
@property NSString *toggleValue;
@property NSString *formatttedValue;
@property NSString *value;

- (id) initWithDisplayText:(NSString*)displayText icon:(NSString*)icon toggleValue:(NSString*)toggleValue value:(NSString*)value;
- (id)initWithGenericValue:(GenericValue*)genericValue text:(NSString*)text;
- (id)initWithDisplayText:(NSString*)displayText iconText:(NSString*)iconText value:(NSString*)value;
@end
