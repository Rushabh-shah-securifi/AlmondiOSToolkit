//
//  SFIButtonSubProperties.h
//  SecurifiApp
//
//  Created by Masood on 15/10/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SecurifiToolkit/SecurifiTypes.h"

@interface SFIButtonSubProperties : NSObject
@property(nonatomic) sfi_id deviceId;
@property(nonatomic) int index;
@property(nonatomic) NSString* matchData;
@property(nonatomic) NSString *delay; //to be used for actions
@property(nonatomic) NSString *eventType;
@property(nonatomic) int positionId; //for actioins
@end
