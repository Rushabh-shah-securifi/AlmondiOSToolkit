//
//  UnlinkAlmondRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface UnlinkAlmondRequest : BaseCommandRequest <SecurifiCommand>
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic, copy) NSString *emailID;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) NSString *internalIndex;

- (NSString *)toXml;
@end
