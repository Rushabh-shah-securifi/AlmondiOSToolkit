//
//  AlmondAffiliationDataResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlmondAffiliationDataResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) unsigned int almondCount;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) NSMutableArray *almondList;
@end
