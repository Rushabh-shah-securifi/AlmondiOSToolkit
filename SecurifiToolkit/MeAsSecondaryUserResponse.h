//
//  MeAsSecondaryUserResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 23/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeAsSecondaryUserResponse : NSObject
@property BOOL isSuccessful;
@property unsigned int almondCount;
@property NSString *reason;
@property NSMutableArray *almondList;
@property int reasonCode;
@end
