//
//  MobileCommandResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseCommandRequest.h"

@interface MobileCommandResponse : NSObject
@property BOOL isSuccessful;
@property sfi_id mobileInternalIndex;
@property (copy) NSString *reason;
@end
