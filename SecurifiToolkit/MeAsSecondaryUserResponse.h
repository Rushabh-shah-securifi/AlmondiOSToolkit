//
//  MeAsSecondaryUserResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 23/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeAsSecondaryUserResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) unsigned int almondCount;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) NSMutableArray *almondList;
@property(nonatomic) int reasonCode;
@end
