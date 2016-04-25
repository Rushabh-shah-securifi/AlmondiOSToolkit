//
//  GenericValue.h
//  SecurifiApp
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericValue : NSObject
@property (nonatomic)NSString *displayText;
@property (nonatomic)NSString *icon;
@property (nonatomic)NSString *iconText;
@property (nonatomic)NSString *toggleValue;
@property (nonatomic)NSString *value;
@property (nonatomic)NSString *excludeFrom;
@property (nonatomic)NSString *eventType;

- (id) initWithDisplayText:(NSString*)displayText icon:(NSString*)icon toggleValue:(NSString*)toggleValue value:(NSString*)value excludeFrom:(NSString*)excludeFrom eventType:(NSString*)eventType;

- (id)initWithGenericValue:(GenericValue*)genericValue text:(NSString*)text;

- (id)initWithDisplayText:(NSString*)displayText iconText:(NSString*)iconText value:(NSString*)value excludeFrom:(NSString*)excludeFrom;
@end
