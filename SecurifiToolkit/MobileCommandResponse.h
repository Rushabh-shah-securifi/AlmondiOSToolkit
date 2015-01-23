//
//  MobileCommandResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiTypes.h"
#import "BaseCommandRequest.h"

@interface MobileCommandResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) sfi_id mobileInternalIndex;
@property(nonatomic, copy) NSString *reason;
@end
