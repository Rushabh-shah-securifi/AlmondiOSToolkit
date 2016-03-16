//
//  GenericIndexValue.h
//  SecurifiToolkit
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexClass.h"
#import "GenericValue.h"

@interface GenericIndexValue : UIViewController
@property GenericIndexClass *genericIndex;
@property GenericValue *genericValue;

-(id)initWithGenericIndex:(GenericIndexClass*)genericIndex genericValue:(GenericValue*)genericValue;
@end
