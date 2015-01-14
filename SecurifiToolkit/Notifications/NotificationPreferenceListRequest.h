//
//  NotificationPreferenceListRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 14/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface NotificationPreferenceListRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *almondplusMAC;

- (NSString *)toXml;
@end
