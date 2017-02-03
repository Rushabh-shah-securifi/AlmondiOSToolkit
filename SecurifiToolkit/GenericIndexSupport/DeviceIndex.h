//
//  DeviceIndex.h
//  SecurifiToolkit
//
//  Created by Masood on 16/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceIndex : UIViewController
@property NSString *rowID;
@property NSString *genericIndex;
@property NSString *index;
@property NSString *placement;
@property (nonatomic) NSString *min;
@property (nonatomic) NSString *max;
@property (nonatomic) NSString *appLabel;

-(id)initWithIndex:(NSString*)index genericIndex:(NSString*)genericIndex rowID:(NSString*)rowID placement:(NSString *)placement min:(NSString*)min max:(NSString*)max appLabel:(NSString *)appLabel;
@end
