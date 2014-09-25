//
//  DeleteMeAsSecondaryUserResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 24/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeleteMeAsSecondaryUserResponse : NSObject
@property BOOL isSuccessful;
@property(nonatomic) NSString *internalIndex;
@property NSString *reason;
@property int reasonCode;
@end
