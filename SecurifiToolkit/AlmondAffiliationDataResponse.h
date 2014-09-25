//
//  AlmondAffiliationDataResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 19/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlmondAffiliationDataResponse : NSObject
@property BOOL isSuccessful;
@property unsigned int almondCount;
@property NSString *reason;
@property NSMutableArray *almondList;
@end
