//
//  GenericCommand.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/15/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericCommand : NSObject

@property id command;
@property unsigned int commandType;

- (NSString *)debugDescription;

@end
