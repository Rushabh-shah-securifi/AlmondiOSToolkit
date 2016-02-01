//
//  RulesTimeElement.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 09/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RulesTimeElement : NSObject
@property (nonatomic)NSInteger range;
@property (nonatomic)NSInteger hours;
@property (nonatomic)NSInteger mins;

@property (nonatomic)NSString *monthOfYear;
@property (nonatomic)NSMutableArray *dayOfWeek;  //0 - 6 sun - mon - (0,1,4. .)
@property (nonatomic)NSString *dayOfMonth;//1 - 30/31
@property (nonatomic) BOOL isPresent;

@property (nonatomic)NSDate *dateFrom;
@property (nonatomic)NSDate *dateTo;

@property (nonatomic)int segmentType;

-(id)createNew;
@end
