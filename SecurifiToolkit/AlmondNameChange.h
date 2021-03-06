//
//  AlmondNameChange.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCommandRequest.h"
#import "SecurifiCommand.h"

@interface AlmondNameChange : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic, copy) NSString *changedAlmondName;

- (NSString *)toXml;
@end
