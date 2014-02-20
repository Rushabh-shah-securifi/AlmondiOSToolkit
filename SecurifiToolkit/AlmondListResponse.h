//
//  AlmondListResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlmondListResponse : NSObject
@property BOOL isSuccessful;
@property unsigned int deviceCount;
@property NSString *reason;
@property NSMutableArray *almondPlusMACList;
@property NSString *action;
@end
