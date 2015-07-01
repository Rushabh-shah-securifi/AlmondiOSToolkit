//
//  AlmondListResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlmondListResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) unsigned int deviceCount;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) NSMutableArray *almondPlusMACList;
@property(nonatomic, copy) NSString *action;
@end
