//
//  AlmondNameChange.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCommandRequest.h"
#import "SecurifiCommand.h"

@interface AlmondNameChange : BaseCommandRequest  <SecurifiCommand>
@property NSString *almondMAC;
@property NSString *changedAlmondName;

- (NSString*)toXml;
@end
