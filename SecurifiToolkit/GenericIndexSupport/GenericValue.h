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
@property BOOL isIconText;
@property NSString *toggleValue;
@property NSString *formatttedValue;
@property NSString *value;

-(id) initWithDisplayText:(NSString*) displayText icon:(NSString*)icon formattedValue:(NSString*)formattedValue toggleValue:(NSString*)toggleValue isIconText:(BOOL)isIconText;
-(id)initWithGenericValue:(GenericValue*)genericValue text:(NSString*)text;
@end
