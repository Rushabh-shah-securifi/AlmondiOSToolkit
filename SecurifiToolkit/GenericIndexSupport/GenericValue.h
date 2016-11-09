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
@property (nonatomic)NSString *transformedValue;
@property (nonatomic)NSString *notificationText;
@property (nonatomic)NSString *notificationPrefix;

-(id) initWithDisplayText:(NSString*)displayText icon:(NSString*)icon toggleValue:(NSString*)toggleValue value:(NSString*)value excludeFrom:(NSString*)excludeFrom eventType:(NSString *)eventType notificationText:(NSString *)notificationText;

- (id)initWithDisplayText:(NSString*)displayText iconText:(NSString*)iconText value:(NSString*)value excludeFrom:(NSString*)excludeFrom transformedValue:(NSString*)transformedValue prefix:(NSString *)notificationPrefix;

- (id)initWithDisplayText:(NSString*)displayText icon:(NSString*)icon toggleValue:(NSString*)toggleValue value:(NSString*)value excludeFrom:(NSString*)excludeFrom eventType:(NSString*)eventType transformedValue:(NSString*)transformedValue prefix:(NSString *)notificationPrefix;

- (id)initUnknownDevice;

- (id)initWithGenericValue:(GenericValue*)genericValue text:(NSString*)text;

- (id)initWithDisplayTextNotification:(NSString*)icon value:(NSString*)value prefix:(NSString *)notificationPrefix;

+(GenericValue*)getCopy:(GenericValue*)genVal;
@end
